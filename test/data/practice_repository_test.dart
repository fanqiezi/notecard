import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notecard/core/constants/pitch.dart';
import 'package:notecard/data/db/app_database.dart';
import 'package:notecard/data/repositories/practice_repository.dart';
import 'package:notecard/domain/session.dart';

AnswerLog _log(int expected, {required bool correct, bool timeout = false, int reaction = 2000}) {
  return AnswerLog(
    midi: correct ? expected : expected + 2,
    expectedMidi: expected,
    clef: Clef.treble,
    isCorrect: correct,
    isTimeout: timeout,
    reactionMs: timeout ? 10000 : reaction,
    source: InputSource.touch,
  );
}

void main() {
  late AppDatabase db;
  late PracticeRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = PracticeRepository(db);
  });

  tearDown(() async => db.close());

  test('finishSession 一次事务写完会话、逐题与错题', () async {
    final now = DateTime.now();
    final id = await repo.finishSession(
      config: const SessionConfig(groupId: 'oct4'),
      logs: [
        _log(64, correct: false), // E4 错
        _log(64, correct: false), // E4 再错
        _log(67, correct: true, reaction: 1200), // G4 对
      ],
      startedAt: now.subtract(const Duration(seconds: 30)),
      endedAt: now,
    );

    expect(id, greaterThan(0));
    final counts = await db.tableCounts();
    expect(counts['practice_session'], 1);
    expect(counts['answer_record'], 3);
    expect(counts['wrong_note'], 1);

    final session = await db.select(db.practiceSession).getSingle();
    expect(session.total, 3);
    expect(session.correct, 1);
    expect(session.avgReactionMs, 1733); // (2000+2000+1200)/3
  });

  test('错题按 (midi, clef) 累加，不进未错的音', () async {
    final now = DateTime.now();
    await repo.finishSession(
      config: const SessionConfig(groupId: 'oct4'),
      logs: [_log(64, correct: false), _log(64, correct: false), _log(67, correct: true)],
      startedAt: now,
      endedAt: now,
    );
    final wrong = await db.select(db.wrongNote).getSingle();
    expect(wrong.midi, 64);
    expect(wrong.clef, 'treble');
    expect(wrong.wrongCount, 2);
    expect(wrong.mastered, 0);
  });

  test('超时按错误计入，但不进平均反应时间', () async {
    final now = DateTime.now();
    await repo.finishSession(
      config: const SessionConfig(groupId: 'oct4'),
      logs: [
        _log(64, correct: false, timeout: true),
        _log(67, correct: true, reaction: 1500),
      ],
      startedAt: now,
      endedAt: now,
    );
    final session = await db.select(db.practiceSession).getSingle();
    expect(session.correct, 1);
    expect(session.avgReactionMs, 1500); // 超时那题被排除
    final wrong = await db.select(db.wrongNote).getSingle();
    expect(wrong.midi, 64);
  });

  test('连续答对两次置 mastered，并从今日统计中保持可见（历史仍在）', () async {
    final now = DateTime.now();
    // 先错两次，再对两次
    await repo.finishSession(
      config: const SessionConfig(groupId: 'oct4'),
      logs: [_log(64, correct: false), _log(64, correct: false)],
      startedAt: now,
      endedAt: now,
    );
    await repo.finishSession(
      config: const SessionConfig(groupId: 'oct4'),
      logs: [_log(64, correct: true), _log(64, correct: true)],
      startedAt: now,
      endedAt: now,
    );
    final wrong = await db.select(db.wrongNote).getSingle();
    expect(wrong.wrongCount, 2);
    expect(wrong.rightStreak, 2);
    expect(wrong.mastered, 1);
  });

  test('今日统计与打卡', () async {
    final now = DateTime.now();
    await repo.finishSession(
      config: const SessionConfig(groupId: 'oct4'),
      logs: [_log(64, correct: false), _log(67, correct: true, reaction: 1000)],
      startedAt: now,
      endedAt: now,
    );
    final stats = await repo.today(now);
    expect(stats.total, 2);
    expect(stats.correct, 1);
    expect(stats.accuracy, 50);
    expect(stats.avgReactionMs, 1500);
    expect(stats.streakDays, 1);
  });

  // ─────────────── M3：错题本与统计 ───────────────

  test('近 7 天题量：固定 7 个桶，今天的量落在最后一格', () async {
    final now = DateTime.now();
    await repo.finishSession(
      config: const SessionConfig(groupId: 'oct4'),
      logs: [_log(64, correct: false), _log(67, correct: true)],
      startedAt: now,
      endedAt: now,
    );
    final days = await repo.dailyCounts(now: now);
    expect(days.length, 7);
    expect(days.last.total, 2);
    expect(days.last.correct, 1);
    expect(days.take(6).every((d) => d.total == 0), isTrue);
  });

  test('各级别正确率按 level_id 分组', () async {
    final now = DateTime.now();
    await repo.finishSession(
      config: const SessionConfig(groupId: 'oct4'),
      logs: [_log(64, correct: true), _log(67, correct: false)],
      startedAt: now,
      endedAt: now,
    );
    await repo.finishSession(
      config: const SessionConfig(groupId: 'oct5'),
      logs: [_log(72, correct: true)],
      startedAt: now,
      endedAt: now,
    );
    final levels = await repo.levelAccuracy();
    expect(levels['oct4']!.total, 2);
    expect(levels['oct4']!.correct, 1);
    expect(levels['oct5']!.total, 1);
    expect(levels['oct5']!.correct, 1);
  });

  test('Top5 错音按音高合并、按次数降序', () async {
    final now = DateTime.now();
    await repo.finishSession(
      config: const SessionConfig(groupId: 'oct4'),
      logs: [_log(64, correct: false), _log(64, correct: false), _log(67, correct: false)],
      startedAt: now,
      endedAt: now,
    );
    final top = await repo.topWrong();
    expect(top.first.midi, 64);
    expect(top.first.wrongCount, 2);
    expect(top[1].midi, 67);
  });

  test('标记已掌握后从错题池移出，但仍留在 Top 统计里', () async {
    final now = DateTime.now();
    await repo.finishSession(
      config: const SessionConfig(groupId: 'oct4'),
      logs: [_log(64, correct: false)],
      startedAt: now,
      endedAt: now,
    );
    expect((await repo.wrongPool()).length, 1);
    await repo.setMastered(64, Clef.treble, mastered: true);
    expect(await repo.wrongPool(), isEmpty);
    expect((await repo.wrongPool(includeMastered: true)).length, 1);
  });

  test('清空：clearWrongNotes 只清错题，clearAll 全清', () async {
    final now = DateTime.now();
    Future<void> write() => repo.finishSession(
          config: const SessionConfig(groupId: 'oct4'),
          logs: [_log(64, correct: false)],
          startedAt: now,
          endedAt: now,
        );

    await write();
    await repo.clearWrongNotes();
    var counts = await db.tableCounts();
    expect(counts['wrong_note'], 0);
    expect(counts['practice_session'], 1);

    await repo.clearAll();
    counts = await db.tableCounts();
    expect(counts['practice_session'], 0);
    expect(counts['answer_record'], 0);
    expect(counts['wrong_note'], 0);
  });
}
