import 'package:material_ui/material_ui.dart';

import '../../../core/constants/note_name.dart';
import '../../../core/constants/pitch.dart';
import '../../../core/theme/semantic_colors.dart';
import '../../../core/theme/spacing.dart';

/// 钢琴键盘 —— 制作文档 5.5。
///
/// 一屏 8 个白键（C…C），键宽 = (W − 32) / 8；黑键宽 0.62×白键、高 0.62×键盘高。
/// 白键左右各外扩 1.5dp 热区补到 44dp；黑键热区外扩到 40dp。
class PianoKeyboard extends StatelessWidget {
  const PianoKeyboard({
    super.key,
    required this.baseMidi,
    required this.onKeyDown,
    this.pressedMidi,
    this.correctMidi,
    this.enabled = true,
    this.onOctaveDown,
    this.onOctaveUp,
    this.octaveLabel,
  });

  /// 最左侧 C 的 MIDI（如 60 = C4）。
  final int baseMidi;
  final ValueChanged<int> onKeyDown;
  final int? pressedMidi;
  final int? correctMidi;
  final bool enabled;
  final VoidCallback? onOctaveDown;
  final VoidCallback? onOctaveUp;
  final String? octaveLabel;

  static const _whiteOffsets = [0, 2, 4, 5, 7, 9, 11, 12];
  static const _blackOffsets = [1, 3, 6, 8, 10];
  static const _blackAfterWhite = [0, 1, 3, 4, 5];
  static const _pitchClasses = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];

  /// 给 TalkBack 用的音名：自然音跟随当前记法，黑键沿用带升号写法。
  static String _noteLabel(int midi) {
    if (Pitch.isNatural(midi)) return NoteNaming.of(midi);
    return '${_pitchClasses[midi % 12]}${midi ~/ 12 - 1}';
  }

  /// 白键上印的字：跟随记法并带组号角标（小字组上标 c¹、大字组下标 C₁）。
  static String _whiteLabel(int midi) => NoteNaming.marked(midi);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = context.semantic;

    return LayoutBuilder(
      builder: (context, constraints) {
        final keyboardWidth = constraints.maxWidth - Gap.l * 2;
        final whiteW = (keyboardWidth / 8).clamp(38.0, 64.0);
        final totalW = whiteW * 8;
        final leftPad = (constraints.maxWidth - totalW) / 2;
        final whiteH = constraints.maxHeight;
        final blackH = whiteH * 0.62;
        final blackW = whiteW * 0.62;

        Color whiteColor(int midi) {
          if (!enabled) return semantic.keyWhite.withValues(alpha: 0.6);
          if (pressedMidi == midi) return semantic.keyPressed;
          if (correctMidi == midi) return semantic.successSoft;
          return semantic.keyWhite;
        }

        Color blackColor(int midi) {
          if (!enabled) return semantic.keyBlack.withValues(alpha: 0.6);
          if (pressedMidi == midi) return semantic.keyPressed;
          if (correctMidi == midi) return semantic.successSoft;
          return semantic.keyBlack;
        }

        return Stack(
          children: [
            // 白键
            for (var i = 0; i < 8; i++)
              Positioned(
                left: leftPad + i * whiteW,
                top: 0,
                width: whiteW,
                height: whiteH,
                child: Semantics(
                  label: '${_noteLabel(baseMidi + _whiteOffsets[i])} 白键，双击作答',
                  button: true,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: enabled ? (_) => onKeyDown(baseMidi + _whiteOffsets[i]) : null,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 0.75),
                      decoration: BoxDecoration(
                        color: whiteColor(baseMidi + _whiteOffsets[i]),
                        border: Border.all(color: theme.dividerColor, width: 1.5),
                        borderRadius:
                            const BorderRadius.vertical(bottom: Radius.circular(Radii.sm)),
                      ),
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.only(bottom: Gap.s),
                      child: Text(
                        _whiteLabel(baseMidi + _whiteOffsets[i]),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            // 黑键
            for (final i in _blackAfterWhite)
              Positioned(
                left: leftPad + (i + 1) * whiteW - blackW / 2,
                top: 0,
                width: blackW,
                height: blackH,
                child: Semantics(
                  label: '${_noteLabel(baseMidi + _blackOffsets[_blackAfterWhite.indexOf(i)])} 黑键',
                  button: true,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: enabled
                        ? (_) =>
                            onKeyDown(baseMidi + _blackOffsets[_blackAfterWhite.indexOf(i)])
                        : null,
                    child: Container(
                      decoration: BoxDecoration(
                        color: blackColor(
                            baseMidi + _blackOffsets[_blackAfterWhite.indexOf(i)]),
                        borderRadius:
                            const BorderRadius.vertical(bottom: Radius.circular(Radii.sm)),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
