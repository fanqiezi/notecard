import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/constants/note_groups.dart';
import '../../core/constants/note_name.dart';
import '../../core/constants/pitch.dart';
import '../../core/theme/semantic_colors.dart';
import '../../core/providers.dart';
import '../../core/theme/spacing.dart';
import '../../data/midi/midi_service.dart';
import '../../data/prefs/settings_store.dart';
import '../../domain/session.dart';
import '../../router/app_router.dart';
import '../midi/midi_controller.dart';
import 'practice_controller.dart';
import 'widgets/piano_keyboard.dart';
import 'widgets/staff_canvas.dart';

/// S3 练习页 —— 制作文档 5.2 的四段式布局。
class PracticePage extends ConsumerStatefulWidget {
  const PracticePage({
    super.key,
    required this.groupId,
    this.mode = PracticeMode.count,
    this.count = 10,
    this.input = InputSource.touch,
  });

  final String groupId;
  final PracticeMode mode;
  final int count;
  final InputSource input;

  @override
  ConsumerState<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends ConsumerState<PracticePage> {
  late int _octaveBase;
  StreamSubscription<int>? _midiSub;
  StreamSubscription<MidiKeyEvent>? _midiRawSub;
  int? _liveMidi;

  @override
  void initState() {
    super.initState();
    _octaveBase = _defaultOctaveBase(widget.groupId);
    // 音频预热：把首次点键的冷启动延迟挪到进页时（制作文档 6.4.2）
    unawaited(ref.read(audioServiceProvider).init());
    // MIDI：设置移调 + 订阅已规范化的音高流（制作文档 6.9.4）
    final settings = ref.read(settingsControllerProvider).value;
    ref.read(midiServiceProvider).setTranspose(settings?.midiTranspose ?? 0);
    _midiSub = ref.read(midiServiceProvider).notes.listen((midi) {
      ref.read(practiceControllerProvider.notifier).press(midi, source: InputSource.midi);
    });
    // 原始事件：五线谱上的「音符显示」（设置项）
    // 没进过设备页也要能连上琴
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(midiControllerProvider.notifier).ensureScanned();
    });
    _midiRawSub = ref.read(midiServiceProvider).events.listen((e) {
      if (!mounted) return;
      final show = ref.read(settingsControllerProvider).value?.showLiveNote ?? true;
      if (!show) return;
      setState(() {
        if (e.isOn) {
          _liveMidi = e.midi;
        } else if (_liveMidi == e.midi) {
          _liveMidi = null;
        }
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(practiceControllerProvider.notifier).start(
            SessionConfig(
              groupId: widget.groupId,
              mode: widget.mode,
              count: widget.count,
              input: widget.input,
            ),
          );
    });
  }

  @override
  void dispose() {
    _midiSub?.cancel();
    _midiRawSub?.cancel();
    super.dispose();
  }

  /// 键盘默认落在分组音域中位数所在的八度。
  static int _defaultOctaveBase(String groupId) {
    final midis = Groups.byId(groupId).midis;
    if (midis.isEmpty) return 60;
    final sorted = [...midis]..sort();
    final median = sorted[sorted.length ~/ 2];
    return (median ~/ 12 * 12).clamp(12, 108);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(practiceControllerProvider);
    final theme = Theme.of(context);
    final group = Groups.byId(widget.groupId);
    final settings = ref.watch(settingsControllerProvider).value ?? const AppSettings();

    ref.listen<PracticeState>(practiceControllerProvider, (prev, next) {
      if (next.finished && !(prev?.finished ?? false) && mounted) {
        context.pushReplacement(Routes.result);
      }
      // 自动切到当前音符所在的八度分组（设置项，默认开）
      final questionChanged = next.currentMidi != null && next.index != prev?.index;
      if (questionChanged) {
        final auto = ref.read(settingsControllerProvider).value?.autoFollowOctave ?? true;
        if (auto) {
          final base = ((next.currentMidi! ~/ 12) * 12).clamp(12, 108);
          if (base != _octaveBase) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _octaveBase = base);
            });
          }
        }
      }
    });

    final accent = switch (state.phase) {
      Phase.correct => context.semantic.success,
      Phase.wrong || Phase.timeout => theme.colorScheme.error,
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('${group.title} · ${_modeLabel()}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            ref.read(practiceControllerProvider.notifier).abort();
            context.pop();
          },
        ),
        actions: [
          // 练习中随手可关音效（与设置页同一个偏好，默认开）
          IconButton(
            tooltip: settings.soundEnabled ? '关闭音效' : '开启音效',
            icon: Icon(settings.soundEnabled ? Icons.volume_up : Icons.volume_off),
            onPressed: () => ref
                .read(settingsControllerProvider.notifier)
                .patch((s) => s.copyWith(soundEnabled: !s.soundEnabled)),
          ),
          if (ref.watch(midiControllerProvider).connected)
            Padding(
              padding: const EdgeInsets.only(right: Gap.s),
              child: Center(
                child: Row(
                  children: [
                    const Icon(Icons.piano, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      ref.watch(midiControllerProvider).connectedName ?? 'MIDI',
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ),
          if (state.config?.mode == PracticeMode.timed)
            Padding(
              padding: const EdgeInsets.only(right: Gap.l),
              child: Center(
                child: Text(
                  '${(state.remainingMs / 1000).ceil()}s',
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _ProgressStrip(state: state),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Gap.l),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: Radii.card,
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Stack(
                  children: [
                    if (state.currentMidi != null && state.currentClef != null)
                      Padding(
                        padding: const EdgeInsets.all(Gap.m),
                        // 新题淡入 + 轻微放大（150ms，一次性动画）
                        child: TweenAnimationBuilder<double>(
                          key: ValueKey(state.index),
                          tween: Tween(begin: 0.94, end: 1),
                          duration: Motion.short,
                          curve: Motion.standard,
                          builder: (context, v, child) => Opacity(
                            opacity: v,
                            child: Transform.scale(scale: v, child: child),
                          ),
                          child: StaffCanvas(
                            midi: state.currentMidi!,
                            clef: state.currentClef!,
                            accent: accent,
                            showNoteName: state.phase != Phase.answering,
                            solfege: settings.noteNameStyle == NoteNameStyle.solfege,
                            liveMidi: settings.showLiveNote ? _liveMidi : null,
                          ),
                        ),
                      ),
                    Positioned(
                      left: Gap.m,
                      right: Gap.m,
                      bottom: Gap.m,
                      child: AnimatedSwitcher(
                        duration: Motion.short,
                        switchInCurve: Motion.standard,
                        child: _FeedbackBanner(key: ValueKey(state.phase), state: state),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: Gap.m),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Gap.l),
              child: widget.input == InputSource.choice
                  ? _ChoiceGrid(
                      options: state.options,
                      enabled: state.phase == Phase.answering,
                      onPick: (midi) => ref
                          .read(practiceControllerProvider.notifier)
                          .press(midi, source: InputSource.choice),
                    )
                  : Column(
                      children: [
                        _OctaveBar(
                          label: '${NoteNaming.of(_octaveBase)}–${NoteNaming.of(_octaveBase + 12)}',
                          onDown: _octaveBase > 12
                              ? () => setState(() => _octaveBase -= 12)
                              : null,
                          onUp: _octaveBase < 108
                              ? () => setState(() => _octaveBase += 12)
                              : null,
                        ),
                        const SizedBox(height: Gap.s),
                        Expanded(
                          child: PianoKeyboard(
                            baseMidi: _octaveBase,
                            enabled: state.phase == Phase.answering,
                            pressedMidi: state.phase == Phase.correct || state.phase == Phase.wrong
                                ? state.pressedMidi
                                : null,
                            correctMidi: state.phase == Phase.wrong || state.phase == Phase.timeout
                                ? state.currentMidi
                                : null,
                            onKeyDown: (midi) =>
                                ref.read(practiceControllerProvider.notifier).press(midi),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: Gap.m),
        ],
      ),
    );
  }

  String _modeLabel() => switch (widget.mode) {
        PracticeMode.timed => '限时 60s',
        PracticeMode.wrong => '错题专项',
        PracticeMode.count => '题量 ${widget.count}',
      };
}

class _ProgressStrip extends StatelessWidget {
  const _ProgressStrip({required this.state});

  final PracticeState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = state.config?.mode == PracticeMode.timed ? 1 : state.total;
    final progress = total <= 1 ? 0.0 : (state.index / total).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.fromLTRB(Gap.l, Gap.s, Gap.l, Gap.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: theme.dividerColor,
            ),
          ),
          const SizedBox(height: Gap.s),
          Row(
            children: [
              Text(
                state.config?.mode == PracticeMode.timed
                    ? '已答 ${state.answered} 题'
                    : '第 ${state.index + 1}/${state.total} 题',
                style: theme.textTheme.labelSmall,
              ),
              const SizedBox(width: Gap.m),
              if (state.combo >= 2)
                Text(
                  'COMBO ×${state.combo}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: context.semantic.streak,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const Spacer(),
              Text(
                state.currentClef == Clef.bass ? '低音谱' : '高音谱',
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({super.key, required this.state});

  final PracticeState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = context.semantic;
    final (text, color, icon) = switch (state.phase) {
      Phase.correct => ('正确！', semantic.success, Icons.check_circle),
      Phase.wrong => ('× 答案是 ${state.currentMidi == null ? '' : NoteNaming.of(state.currentMidi!)}',
          theme.colorScheme.error, Icons.cancel),
      Phase.timeout => ('⏱ 超时，答案是 ${state.currentMidi == null ? '' : NoteNaming.of(state.currentMidi!)}',
          semantic.warning, Icons.timer_off),
      _ => ('', Colors.transparent, Icons.circle),
    };
    if (text.isEmpty) return const SizedBox.shrink();
    return AnimatedOpacity(
      duration: Motion.short,
      opacity: 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Gap.m, vertical: Gap.s),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: Radii.card,
          border: Border.all(color: color, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: Gap.s),
            Text(text, style: theme.textTheme.bodyMedium?.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

class _OctaveBar extends StatelessWidget {
  const _OctaveBar({required this.label, this.onDown, this.onUp});

  final String label;
  final VoidCallback? onDown;
  final VoidCallback? onUp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: onDown,
          visualDensity: VisualDensity.compact,
        ),
        Text('八度 $label', style: theme.textTheme.labelSmall),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: onUp,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}

class _ChoiceGrid extends StatelessWidget {
  const _ChoiceGrid({required this.options, required this.enabled, required this.onPick});

  final List<int> options;
  final bool enabled;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: Gap.s,
      crossAxisSpacing: Gap.s,
      childAspectRatio: 2.6,
      children: [
        for (final midi in options)
          OutlinedButton(
            onPressed: enabled ? () => onPick(midi) : null,
            child: Text(NoteNaming.of(midi)),
          ),
      ],
    );
  }
}
