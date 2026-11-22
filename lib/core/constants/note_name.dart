import 'pitch.dart';

/// 音名记法。
///
/// - [chinese]：中国科学音高记号法 —— 中央 C 记作 `c1`，大写表示大字组、小写表示小字组。
///   例：A0→A2、C1→C1、C2→C、C3→c、C4→c1、C8→c5。
/// - [international]：国际科学音高记号法（SPN）—— 中央 C 记作 `C4`，A0 / C8 直接带八度号。
enum PitchNotation {
  chinese('中国科学音高记号法'),
  international('国际记法');

  const PitchNotation(this.label);
  final String label;
}

/// 全局当前记法。
///
/// 做成静态是因为展示点分散在谱面 / 键盘 / 错题本 / 统计 / 结算等 8 处，
/// 逐个透传 settings 会污染所有组件签名；由 `NoteCardApp` 在设置变化时同步一次。
abstract final class NoteNaming {
  static PitchNotation notation = PitchNotation.chinese;

  static const List<String> _lower = ['c', 'd', 'e', 'f', 'g', 'a', 'b'];

  /// 中国科学音高记号法：o ≤ 2 用大写（大字组），o ≥ 3 用小写（小字组）。
  static String chinese(int midi) {
    final letter = _lower[Pitch.letterIndexOf(midi)];
    final octave = Pitch.octaveOf(midi);
    if (octave <= 2) {
      final suffix = octave == 2 ? '' : '${2 - octave}'; // C2→C，C1→C1，A0→A2
      return '${letter.toUpperCase()}$suffix';
    }
    final suffix = octave == 3 ? '' : '${octave - 3}'; // C3→c，C4→c1，C8→c5
    return '$letter$suffix';
  }

  /// 按当前记法输出音名。
  static String of(int midi, {bool solfege = false}) {
    if (solfege) return Pitch.solfegeName(midi);
    return notation == PitchNotation.chinese ? chinese(midi) : Pitch.name(midi);
  }

  static const List<String> _sup = ['⁰', '¹', '²', '³', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹'];
  static const List<String> _sub = ['₀', '₁', '₂', '₃', '₄', '₅', '₆', '₇', '₈', '₉'];

  /// 带角标的音名，用于键盘白键这类空间紧张的位置。
  ///
  /// 中国记法按乐理惯例：**小字组用上标**（c¹、c²），**大字组用下标**（C₁、C₂），
  /// 大字组与小字组本身不带数字。国际记法直接输出 C4 / A0。
  static String marked(int midi) {
    if (notation == PitchNotation.international) return Pitch.name(midi);
    final letter = _lower[Pitch.letterIndexOf(midi)];
    final octave = Pitch.octaveOf(midi);
    if (octave <= 2) {
      if (octave == 2) return letter.toUpperCase(); // 大字组
      return '${letter.toUpperCase()}${_sub[2 - octave]}';
    }
    if (octave == 3) return letter; // 小字组
    final n = octave - 3;
    return '$letter${n < 10 ? _sup[n] : n}';
  }

  /// 音域标签，如 `A2–c5`（中国记法）或 `A0–C8`（国际记法）。
  static String range(List<int> midis) {
    if (midis.isEmpty) return '—';
    final sorted = [...midis]..sort();
    return '${of(sorted.first)}–${of(sorted.last)}';
  }
}
