import '../core/constants/note_groups.dart';
import '../core/constants/pitch.dart';

/// 练习模式 —— 制作文档 3.2。
enum PracticeMode { count, timed, wrong }

/// 答题输入来源 —— 制作文档 6.9.4。
enum InputSource { touch, midi, choice }

/// 单题。
class NoteQuestion {
  const NoteQuestion({
    required this.seq,
    required this.midi,
    required this.clef,
    required this.presentedAtMs,
  });

  final int seq;
  final int midi;
  final Clef clef;
  final int presentedAtMs;

  String get noteName => Pitch.name(midi);

  @override
  String toString() => 'Q$seq $noteName ($clef)';
}

/// 会话配置。
class SessionConfig {
  const SessionConfig({
    required this.groupId,
    this.mode = PracticeMode.count,
    this.count = 10,
    this.input = InputSource.touch,
  });

  final String groupId;
  final PracticeMode mode;
  final int count;
  final InputSource input;

  NoteGroup get group => Groups.byId(groupId);

  SessionConfig copyWith({
    String? groupId,
    PracticeMode? mode,
    int? count,
    InputSource? input,
  }) =>
      SessionConfig(
        groupId: groupId ?? this.groupId,
        mode: mode ?? this.mode,
        count: count ?? this.count,
        input: input ?? this.input,
      );
}

/// 一次答题的结果（M2 落库时按 answer_record 字段写）。
class AnswerLog {
  const AnswerLog({
    required this.midi,
    required this.expectedMidi,
    required this.clef,
    required this.isCorrect,
    required this.isTimeout,
    required this.reactionMs,
    required this.source,
  });

  final int midi;
  final int expectedMidi;
  final Clef clef;
  final bool isCorrect;
  final bool isTimeout;
  final int reactionMs;
  final InputSource source;
}

/// 会话阶段 —— 制作文档 5.3 的状态机（presenting 合并进 answering，用输入锁代替）。
enum Phase { idle, answering, correct, wrong, timeout, finished }
