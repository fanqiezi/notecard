import 'package:drift/drift.dart';

/// 练习会话 —— 制作文档 6.5.1。
///
/// 表名由类名 snake_case 推导：PracticeSession → practice_session。
/// （drift 2.35 没有 @TableName 注解，靠命名对齐最省事。）
@DataClassName('PracticeSessionRow')
class PracticeSession extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// count / timed / wrong
  TextColumn get mode => text()();

  /// L1…L6 / wrong
  TextColumn get levelId => text()();

  IntColumn get startedAt => integer()();
  IntColumn get endedAt => integer()();
  IntColumn get total => integer()();
  IntColumn get correct => integer()();
  IntColumn get avgReactionMs => integer()();
}

/// 逐题记录。`source` 在 M0 就建进表，避免 M2.5 再改 schema。
@DataClassName('AnswerRecordRow')
class AnswerRecord extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(PracticeSession, #id)();
  IntColumn get midi => integer()();

  /// treble / bass
  TextColumn get clef => text()();

  /// touch / midi / choice
  TextColumn get source => text()();
  IntColumn get isCorrect => integer()();

  /// 超时单独记一列：结算页要区分「答错」与「超时」，且平均反应时间不含超时题。
  IntColumn get isTimeout => integer().withDefault(const Constant(0))();
  IntColumn get reactionMs => integer()();
  IntColumn get answeredAt => integer()();
}

/// 错题本。主键 (midi, clef)，连续答对 2 次置 mastered = 1。
@DataClassName('WrongNoteRow')
class WrongNote extends Table {
  IntColumn get midi => integer()();
  TextColumn get clef => text()();
  IntColumn get wrongCount => integer()();
  IntColumn get rightStreak => integer()();
  IntColumn get lastWrongAt => integer()();
  IntColumn get mastered => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {midi, clef};
}
