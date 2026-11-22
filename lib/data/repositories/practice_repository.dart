import 'package:drift/drift.dart';

import '../../core/constants/pitch.dart';
import '../../domain/session.dart';
import '../db/app_database.dart';

/// 今日概览（首页四宫格）。
class TodayStats {
  const TodayStats({this.total = 0, this.correct = 0, this.avgReactionMs = 0, this.streakDays = 0});

  final int total;
  final int correct;
  final int avgReactionMs;
  final int streakDays;

  int get accuracy => total == 0 ? 0 : (correct * 100 / total).round();
}

/// 会话写入与统计 —— 制作文档 6.5.3 / 6.5.4。
///
/// 写入时机：**会话结束单事务批量写**（文档 6.5.4 的结论 B），
/// 答题过程中只在内存里累积 AnswerLog，结算时一次落库。
class PracticeRepository {
  PracticeRepository(this._db);

  final AppDatabase _db;

  /// 写会话 + 全部逐题记录 + 错题增量，返回 sessionId。
  Future<int> finishSession({
    required SessionConfig config,
    required List<AnswerLog> logs,
    required DateTime startedAt,
    required DateTime endedAt,
  }) {
    return _db.transaction(() async {
      final correct = logs.where((l) => l.isCorrect).length;
      final nonTimeout = logs.where((l) => !l.isTimeout).toList();
      final avg = nonTimeout.isEmpty
          ? 0
          : (nonTimeout.map((l) => l.reactionMs).reduce((a, b) => a + b) / nonTimeout.length).round();

      final sessionId = await _db.into(_db.practiceSession).insert(
            PracticeSessionCompanion.insert(
              mode: config.mode.name,
              levelId: config.groupId,
              startedAt: startedAt.millisecondsSinceEpoch,
              endedAt: endedAt.millisecondsSinceEpoch,
              total: logs.length,
              correct: correct,
              avgReactionMs: avg,
            ),
          );

      if (logs.isNotEmpty) {
        await _db.batch((b) {
          for (final log in logs) {
            b.insert(
              _db.answerRecord,
              AnswerRecordCompanion.insert(
                sessionId: sessionId,
                // 存「题目目标音」而不是用户按下的音：错题统计与 Top5 都要按目标音聚合
                midi: log.expectedMidi,
                clef: log.clef.name,
                source: log.source.name,
                isCorrect: log.isCorrect ? 1 : 0,
                isTimeout: Value(log.isTimeout ? 1 : 0),
                reactionMs: log.reactionMs,
                answeredAt: endedAt.millisecondsSinceEpoch,
              ),
            );
          }
        });
      }

      await _applyWrongNotes(logs);
      return sessionId;
    });
  }

  /// 错题增量：同一 (midi, clef) 累加 wrong_count，答对则 streak+1，连续 2 次置 mastered。
  Future<void> _applyWrongNotes(List<AnswerLog> logs) async {
    // 先按 (midi, clef) 聚合本局结果，减少读写次数
    final deltas = <String, ({int midi, Clef clef, int wrongs, int rights})>{};
    for (final log in logs) {
      final key = '${log.expectedMidi}:${log.clef.name}';
      final cur = deltas[key] ?? (midi: log.expectedMidi, clef: log.clef, wrongs: 0, rights: 0);
      deltas[key] = log.isCorrect
          ? (midi: cur.midi, clef: cur.clef, wrongs: cur.wrongs, rights: cur.rights + 1)
          : (midi: cur.midi, clef: cur.clef, wrongs: cur.wrongs + 1, rights: cur.rights);
    }

    for (final d in deltas.values) {
      final existing = await (_db.select(_db.wrongNote)
            ..where((t) => t.midi.equals(d.midi) & t.clef.equals(d.clef.name)))
          .getSingleOrNull();

      if (existing == null) {
        if (d.wrongs == 0) continue; // 一次都没错的音不进错题本
        await _db.into(_db.wrongNote).insert(
              WrongNoteCompanion.insert(
                midi: d.midi,
                clef: d.clef.name,
                wrongCount: d.wrongs,
                rightStreak: 0,
                lastWrongAt: DateTime.now().millisecondsSinceEpoch,
                mastered: const Value(0),
              ),
            );
        continue;
      }

      final newStreak = d.wrongs > 0 ? 0 : existing.rightStreak + d.rights;
      await (_db.update(_db.wrongNote)
            ..where((t) => t.midi.equals(d.midi) & t.clef.equals(d.clef.name)))
          .write(
        WrongNoteCompanion(
          wrongCount: Value(existing.wrongCount + d.wrongs),
          rightStreak: Value(newStreak),
          lastWrongAt: d.wrongs > 0
              ? Value(DateTime.now().millisecondsSinceEpoch)
              : Value(existing.lastWrongAt),
          mastered: Value(newStreak >= 2 ? 1 : 0),
        ),
      );
    }
  }

  /// 今日三指标（首页四宫格）。
  Future<TodayStats> today(DateTime now) async {
    final dayStart = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final dayEnd = dayStart + const Duration(days: 1).inMilliseconds;
    final rows = await _db.customSelect(
      'SELECT COUNT(*) AS total, '
      'COALESCE(SUM(is_correct), 0) AS ok, '
      'COALESCE(AVG(CASE WHEN is_timeout = 0 THEN reaction_ms END), 0) AS avg_ms '
      'FROM answer_record WHERE answered_at >= ? AND answered_at < ?',
      variables: [Variable.withInt(dayStart), Variable.withInt(dayEnd)],
    ).get();
    final row = rows.first;
    return TodayStats(
      total: row.read<int>('total'),
      correct: row.read<int>('ok'),
      avgReactionMs: row.read<double>('avg_ms').round(),
      streakDays: await _streakDays(now),
    );
  }

  /// 连续打卡天数：今天没练也不算断签（制作文档 7.5）。
  ///
  /// 用本地日期做桶（而不是 epochDay）：东八区的本地零点并不是 86400000 的整数倍，
  /// 直接用毫秒除法会把「今天」算到昨天，导致连续 1 天恒为 0。
  Future<int> _streakDays(DateTime now) async {
    final rows = await _db.select(_db.practiceSession).get();
    final days = rows
        .map((r) => _dayKey(DateTime.fromMillisecondsSinceEpoch(r.startedAt)))
        .toSet();
    var cursor = DateTime(now.year, now.month, now.day);
    if (!days.contains(_dayKey(cursor))) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    var streak = 0;
    while (days.contains(_dayKey(cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  static int _dayKey(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

  // ───────────────────────── M3：错题本与统计 ─────────────────────────

  /// 错题池（默认只取未掌握的），按错误次数降序。
  Future<List<WrongNoteRow>> wrongPool({bool includeMastered = false, int limit = 200}) async {
    final query = _db.select(_db.wrongNote)
      ..orderBy([(t) => OrderingTerm.desc(t.wrongCount)])
      ..limit(limit);
    if (!includeMastered) {
      query.where((t) => t.mastered.equals(0));
    }
    return query.get();
  }

  /// Top N 错音（按音高合并谱号，符合「这个音总认错」的感知）。
  Future<List<({int midi, int wrongCount})>> topWrong({int limit = 5}) async {
    final rows = await _db.customSelect(
      'SELECT midi, SUM(wrong_count) AS wc FROM wrong_note '
      'WHERE mastered = 0 GROUP BY midi ORDER BY wc DESC, midi ASC LIMIT ?',
      variables: [Variable.withInt(limit)],
    ).get();
    return rows.map((r) => (midi: r.read<int>('midi'), wrongCount: r.read<int>('wc'))).toList();
  }

  /// 近 N 天每日题量（含今天，缺失日补 0）。
  Future<List<DayCount>> dailyCounts({int days = 7, DateTime? now}) async {
    final today = now ?? DateTime.now();
    final start = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: days - 1));
    final rows = await _db.customSelect(
      'SELECT answered_at, is_correct FROM answer_record WHERE answered_at >= ?',
      variables: [Variable.withInt(start.millisecondsSinceEpoch)],
    ).get();

    final buckets = <int, DayCount>{
      for (var i = 0; i < days; i++)
        _dayKey(start.add(Duration(days: i))): DayCount(
          day: start.add(Duration(days: i)),
          total: 0,
          correct: 0,
        ),
    };
    for (final r in rows) {
      final ts = r.read<int>('answered_at');
      final ok = r.read<int>('is_correct');
      final key = _dayKey(DateTime.fromMillisecondsSinceEpoch(ts));
      final bucket = buckets[key];
      if (bucket == null) continue;
      buckets[key] = DayCount(day: bucket.day, total: bucket.total + 1, correct: bucket.correct + ok);
    }
    return buckets.values.toList()..sort((a, b) => a.day.compareTo(b.day));
  }

  /// 各级别正确率（JOIN 会话表拿 level_id）。
  Future<Map<String, ({int total, int correct})>> levelAccuracy() async {
    final rows = await _db.customSelect(
      'SELECT s.level_id AS lv, COUNT(*) AS total, COALESCE(SUM(a.is_correct), 0) AS ok '
      'FROM answer_record a JOIN practice_session s ON s.id = a.session_id '
      'GROUP BY s.level_id',
    ).get();
    return {
      for (final r in rows)
        r.read<String>('lv'): (total: r.read<int>('total'), correct: r.read<int>('ok')),
    };
  }

  /// 手动标记掌握 / 撤销。
  Future<void> setMastered(int midi, Clef clef, {required bool mastered}) async {
    await (_db.update(_db.wrongNote)
          ..where((t) => t.midi.equals(midi) & t.clef.equals(clef.name)))
        .write(WrongNoteCompanion(mastered: Value(mastered ? 1 : 0)));
  }

  /// 清空练习记录（会话 + 逐题 + 错题）。
  Future<void> clearAll() async {
    await _db.transaction(() async {
      await _db.delete(_db.answerRecord).go();
      await _db.delete(_db.practiceSession).go();
      await _db.delete(_db.wrongNote).go();
    });
  }

  /// 只清空错题本。
  Future<void> clearWrongNotes() async {
    await _db.delete(_db.wrongNote).go();
  }
}

/// 单日题量。
class DayCount {
  const DayCount({required this.day, required this.total, required this.correct});

  final DateTime day;
  final int total;
  final int correct;

  int get accuracy => total == 0 ? 0 : (correct * 100 / total).round();
}
