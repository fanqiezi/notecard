/// 谱号。
enum Clef { treble, bass }

/// 音高工具：MIDI ↔ 音名 ↔ dIndex，纯函数，可直接单测。
///
/// 规则见制作文档 7.2：
///   letterIndex: C=0 D=1 E=2 F=3 G=4 A=5 B=6
///   dIndex = octave*7 + letterIndex
///   高音谱基线 E4 = 30，低音谱基线 G2 = 18
abstract final class Pitch {
  static const List<int> _semitone = [0, 2, 4, 5, 7, 9, 11];
  static const Map<int, int> _pcToLetter = {0: 0, 2: 1, 4: 2, 5: 3, 7: 4, 9: 5, 11: 6};
  static const List<String> _letters = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];

  static const int trebleBase = 30; // E4
  static const int bassBase = 18; // G2

  static bool isNatural(int midi) => _pcToLetter.containsKey(midi % 12);

  static int octaveOf(int midi) => midi ~/ 12 - 1;

  static int letterIndexOf(int midi) {
    final idx = _pcToLetter[midi % 12];
    if (idx == null) {
      throw ArgumentError.value(midi, 'midi', '黑键不属于本期题库');
    }
    return idx;
  }

  static int dIndex(int midi) => octaveOf(midi) * 7 + letterIndexOf(midi);

  static int midiOfDIndex(int dIndex) => (dIndex ~/ 7 + 1) * 12 + _semitone[dIndex % 7];

  static int staffStep(int midi, Clef clef) =>
      dIndex(midi) - (clef == Clef.treble ? trebleBase : bassBase);

  static String name(int midi) => '${_letters[letterIndexOf(midi)]}${octaveOf(midi)}';

  static const List<String> solfege = ['do', 're', 'mi', 'fa', 'sol', 'la', 'si'];

  static String solfegeName(int midi) => '${solfege[letterIndexOf(midi)]}${octaveOf(midi)}';
}
