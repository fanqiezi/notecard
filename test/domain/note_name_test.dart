import 'package:flutter_test/flutter_test.dart';
import 'package:notecard/core/constants/note_name.dart';

void main() {
  group('中国科学音高记号法（默认记法）', () {
    test('各组边界：A0→A2、C1→C1、C2→C、C3→c、C4→c1、C5→c2、C8→c5', () {
      expect(NoteNaming.chinese(21), 'A2'); // A0
      expect(NoteNaming.chinese(23), 'B2'); // B0
      expect(NoteNaming.chinese(24), 'C1'); // C1
      expect(NoteNaming.chinese(36), 'C'); // C2
      expect(NoteNaming.chinese(43), 'G'); // G2
      expect(NoteNaming.chinese(48), 'c'); // C3
      expect(NoteNaming.chinese(55), 'g'); // G3
      expect(NoteNaming.chinese(60), 'c1'); // C4 中央 C
      expect(NoteNaming.chinese(69), 'a1'); // A4
      expect(NoteNaming.chinese(72), 'c2'); // C5
      expect(NoteNaming.chinese(84), 'c3'); // C6
      expect(NoteNaming.chinese(108), 'c5'); // C8
    });

    test('默认就是中国记法，可切回国际记法', () {
      expect(NoteNaming.notation, PitchNotation.chinese);
      expect(NoteNaming.of(60), 'c1');
      NoteNaming.notation = PitchNotation.international;
      expect(NoteNaming.of(60), 'C4');
      expect(NoteNaming.of(21), 'A0');
      NoteNaming.notation = PitchNotation.chinese; // 复位，避免影响其它用例
    });

    test('键盘角标：小字组上标、大字组下标、整组不带数字', () {
      expect(NoteNaming.marked(21), 'A₂'); // A0 大字二组
      expect(NoteNaming.marked(24), 'C₁'); // C1 大字一组
      expect(NoteNaming.marked(36), 'C'); // C2 大字组
      expect(NoteNaming.marked(48), 'c'); // C3 小字组
      expect(NoteNaming.marked(60), 'c¹'); // C4 小字一组
      expect(NoteNaming.marked(72), 'c²'); // C5 小字二组
      expect(NoteNaming.marked(108), 'c⁵'); // C8 小字五组
      NoteNaming.notation = PitchNotation.international;
      expect(NoteNaming.marked(60), 'C4');
      expect(NoteNaming.marked(21), 'A0');
      NoteNaming.notation = PitchNotation.chinese;
    });
    test('音域标签跟着记法走', () {
      expect(NoteNaming.range([21, 108]), 'A2–c5');
      NoteNaming.notation = PitchNotation.international;
      expect(NoteNaming.range([21, 108]), 'A0–C8');
      NoteNaming.notation = PitchNotation.chinese;
    });
  });
}