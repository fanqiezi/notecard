import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/note_groups.dart';
import '../../core/constants/pitch.dart';
import '../../core/providers.dart';
import '../../domain/question_generator.dart';
import '../../domain/session.dart';

/// 会话状态 —— 制作文档 5.3 / 7.6。
class PracticeState {
  const PracticeState({
    this.config,
    this.phase = Phase.idle,
    this.currentMidi,
    this.currentClef,
    this.options = const [],
    this.index = 0,
    this.total = 0,
    this.correct = 0,
    this.wrong = 0,
    this.timedOut = 0,
    this.combo = 0,
    this.maxCombo = 0,
    this.pressedMidi,
    this.elapsedMs = 0,
    this.remainingMs = 0,
    this.logs = const [],
    this.finished = false,
  });

  final SessionConfig? config;
  final Phase phase;
  final int? currentMidi;
  final Clef? currentClef;

  /// 选项模式下的 6 个候选。
  final List<int> options;

  final int index;
  final int total;
  final int correct;
  final int wrong;
  final int timedOut;
  final int combo;
  final int maxCombo;

  /// 用户按下的音（错答时用于高亮错误键）。
  final int? pressedMidi;

  final int elapsedMs;
  final int remainingMs;
  final List<AnswerLog> logs;
  final bool finished;

  int get answered => correct + wrong + timedOut;
  int get accuracy => answered == 0 ? 0 : (correct * 100 / answered).round();
  int get avgReactionMs {
    final valid = logs.where((l) => !l.isTimeout).map((l) => l.reactionMs).toList();
    if (valid.isEmpty) return 0;
    return (valid.reduce((a, b) => a + b) / valid.length).round();
  }

  PracticeState copyWith({
    SessionConfig? config,
    Phase? phase,
    int? currentMidi,
    Clef? currentClef,
    List<int>? options,
    int? index,
    int? total,
    int? correct,
    int? wrong,
    int? timedOut,
    int? combo,
    int? maxCombo,
    int? pressedMidi,
    bool clearPressed = false,
    int? elapsedMs,
    int? remainingMs,
    List<AnswerLog>? logs,
    bool? finished,
  }) {
    return PracticeState(
      config: config ?? this.config,
      phase: phase ?? this.phase,
      currentMidi: currentMidi ?? this.currentMidi,
      currentClef: currentClef ?? this.currentClef,
      options: options ?? this.options,
      index: index ?? this.index,
      total: total ?? this.total,
      correct: correct ?? this.correct,
      wrong: wrong ?? this.wrong,
      timedOut: timedOut ?? this.timedOut,
      combo: combo ?? this.combo,
      maxCombo: maxCombo ?? this.maxCombo,
      pressedMidi: clearPressed ? null : (pressedMidi ?? this.pressedMidi),
      elapsedMs: elapsedMs ?? this.elapsedMs,
      remainingMs: remainingMs ?? this.remainingMs,
      logs: logs ?? this.logs,
      finished: finished ?? this.finished,
    );
  }
}

/// 单题超时 —— 制作文档 4.6 定为 10 秒。
const kQuestionTimeoutMs = 10000;

/// 判定后的反馈停留时长 —— 制作文档 5.3。
const kFeedbackDuration = {
  Phase.correct: Duration(milliseconds: 600),
  Phase.wrong: Duration(milliseconds: 800),
  Phase.timeout: Duration(milliseconds: 900),
};

/// 限时模式总时长。
const kTimedModeTotalMs = 60000;

class PracticeController extends Notifier<PracticeState> {
  final Stopwatch _clock = Stopwatch();
  QuestionGenerator? _generator;
  Timer? _feedbackTimer;
  Timer? _questionTimer;
  Timer? _ticker;
  int _presentedAtMs = 0;
  int _inputLockUntilMs = 0;
  DateTime? _startedAt;

  @override
  PracticeState build() {
    ref.onDispose(_cancelAll);
    return const PracticeState();
  }

  void start(SessionConfig config) {
    _cancelAll();
    if (config.mode == PracticeMode.wrong) {
      final pool = ref.read(wrongPracticePoolProvider);
      _generator = pool.isEmpty
          ? QuestionGenerator(group: config.group)
          : QuestionGenerator.custom(
              pool: pool,
              clefOf: (midi) => midi >= 60 ? Clef.treble : Clef.bass,
              optionPool: Groups.naturals,
            );
    } else {
      _generator = QuestionGenerator(group: config.group);
    }
    _startedAt = DateTime.now();
    _clock
      ..reset()
      ..start();
    state = PracticeState(
      config: config,
      total: config.mode == PracticeMode.timed ? 999 : config.count,
      phase: Phase.answering,
      remainingMs: config.mode == PracticeMode.timed ? kTimedModeTotalMs : 0,
    );
    _startTimedClockIfNeeded(config);
    _present();
  }

  void _startTimedClockIfNeeded(SessionConfig config) {
    if (config.mode != PracticeMode.timed) return;
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (state.finished) return;
      final remaining = kTimedModeTotalMs - _clock.elapsedMilliseconds;
      if (remaining <= 0) {
        _finish();
      } else {
        state = state.copyWith(
          elapsedMs: _clock.elapsedMilliseconds,
          remainingMs: remaining,
        );
      }
    });
  }

  void _present() {
    final config = state.config!;
    final gen = _generator!;
    final q = gen.next(_clock.elapsedMilliseconds);
    _presentedAtMs = _clock.elapsedMilliseconds;
    // 出题后 200ms 内忽略输入，防手快连点
    _inputLockUntilMs = _presentedAtMs + 200;
    state = state.copyWith(
      phase: Phase.answering,
      currentMidi: q.midi,
      currentClef: q.clef,
      options: config.input == InputSource.choice ? gen.choicesFor(q.midi) : const [],
      clearPressed: true,
    );
    _questionTimer?.cancel();
    _questionTimer = Timer(const Duration(milliseconds: kQuestionTimeoutMs), _onTimeout);
  }

  /// 用户按键（或选项）。
  void press(int midi, {InputSource source = InputSource.touch}) {
    if (state.phase != Phase.answering || state.finished) return;
    final now = _clock.elapsedMilliseconds;
    if (now < _inputLockUntilMs) return;

    final expected = state.currentMidi;
    if (expected == null) return;
    // 按下即发声（制作文档 5.4）
    ref.read(audioServiceProvider).play(midi);
    final isCorrect = midi == expected;
    final reaction = now - _presentedAtMs;
    _questionTimer?.cancel();

    final log = AnswerLog(
      midi: midi,
      expectedMidi: expected,
      clef: state.currentClef!,
      isCorrect: isCorrect,
      isTimeout: false,
      reactionMs: reaction,
      source: source,
    );

    if (isCorrect) {
      final combo = state.combo + 1;
      state = state.copyWith(
        phase: Phase.correct,
        pressedMidi: midi,
        correct: state.correct + 1,
        combo: combo,
        maxCombo: combo > state.maxCombo ? combo : state.maxCombo,
        logs: [...state.logs, log],
      );
      _scheduleAdvance(Phase.correct);
    } else {
      state = state.copyWith(
        phase: Phase.wrong,
        pressedMidi: midi,
        wrong: state.wrong + 1,
        combo: 0,
        logs: [...state.logs, log],
      );
      _scheduleAdvance(Phase.wrong);
    }
  }

  void _onTimeout() {
    if (state.phase != Phase.answering || state.finished) return;
    final expected = state.currentMidi;
    if (expected == null) return;
    final log = AnswerLog(
      midi: -1,
      expectedMidi: expected,
      clef: state.currentClef!,
      isCorrect: false,
      isTimeout: true,
      reactionMs: kQuestionTimeoutMs,
      source: InputSource.touch,
    );
    state = state.copyWith(
      phase: Phase.timeout,
      timedOut: state.timedOut + 1,
      combo: 0,
      logs: [...state.logs, log],
    );
    _scheduleAdvance(Phase.timeout);
  }

  void _scheduleAdvance(Phase phase) {
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(kFeedbackDuration[phase]!, _advance);
  }

  void _advance() {
    if (state.finished) return;
    final nextIndex = state.index + 1;
    final config = state.config!;
    final reachedEnd = config.mode == PracticeMode.count && nextIndex >= config.count;
    if (reachedEnd) {
      _finish();
      return;
    }
    state = state.copyWith(index: nextIndex);
    _present();
  }

  /// 中途退出。
  void abort() => _finish(aborted: true);

  void _finish({bool aborted = false}) {
    _cancelTimers();
    final config = state.config;
    // 中途退出且一题没答的不落库，避免污染统计
    if (config != null && state.logs.isNotEmpty) {
      final startedAt = _startedAt ?? DateTime.now();
      final logs = state.logs;
      unawaited(() async {
        try {
          await ref.read(practiceRepositoryProvider).finishSession(
                config: config,
                logs: logs,
                startedAt: startedAt,
                endedAt: DateTime.now(),
              );
          ref.read(dbTickProvider.notifier).bump();
        } catch (e) {
          // 落库失败不影响结算展示（制作文档 6.7：成绩可见但未保存）
          debugPrint('会话落库失败: $e');
        }
      }());
    }
    state = state.copyWith(
      phase: Phase.finished,
      finished: true,
      elapsedMs: _clock.elapsedMilliseconds,
      remainingMs: 0,
    );
  }

  void _cancelTimers() {
    _feedbackTimer?.cancel();
    _questionTimer?.cancel();
    _ticker?.cancel();
  }

  void _cancelAll() {
    _cancelTimers();
    _clock.stop();
  }
}

final practiceControllerProvider =
    NotifierProvider<PracticeController, PracticeState>(PracticeController.new);
