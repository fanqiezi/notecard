import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'app_database.g.dart';

/// 本地库 —— 制作文档 6.5。
///
/// schemaVersion 从 1 开始；`answer_record.source` 已在 v1 定义里，不产生迁移。
@DriftDatabase(tables: [PracticeSession, AnswerRecord, WrongNote])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _open());

  @override
  int get schemaVersion => 2;

  static QueryExecutor _open() => driftDatabase(
        name: 'notecard',
        native: const DriftNativeOptions(shareAcrossIsolates: true),
      );

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _createIndexes();
        },
        onUpgrade: (m, from, to) async {
          // v2：answer_record 增加 is_timeout，区分超时与答错
          if (from < 2) {
            await m.addColumn(answerRecord, answerRecord.isTimeout);
          }
          await _createIndexes();
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<void> _createIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_answer_answered ON answer_record(answered_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_answer_session ON answer_record(session_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_session_started ON practice_session(started_at)',
    );
  }

  /// 骨架期只需要一个「库能用」的探针：三张表的行数。
  Future<Map<String, int>> tableCounts() async {
    final sessions = await practiceSession.count().getSingle();
    final answers = await answerRecord.count().getSingle();
    final wrongs = await wrongNote.count().getSingle();
    return {
      'practice_session': sessions,
      'answer_record': answers,
      'wrong_note': wrongs,
    };
  }
}
