import 'package:flutter_test/flutter_test.dart';
import 'package:notecard/core/constants/note_groups.dart';
import 'package:notecard/core/constants/pitch.dart';
import 'package:notecard/domain/question_generator.dart';

void main() {
  group('Pitch 映射（制作文档 7.2）', () {
    test('C2–C6 段的 29 个自然音双向恒等（全音域 52 个的子集）', () {
      const expected = {
        36: 'C2', 38: 'D2', 40: 'E2', 41: 'F2', 43: 'G2', 45: 'A2', 47: 'B2',
        48: 'C3', 50: 'D3', 52: 'E3', 53: 'F3', 55: 'G3', 57: 'A3', 59: 'B3',
        60: 'C4', 62: 'D4', 64: 'E4', 65: 'F4', 67: 'G4', 69: 'A4', 71: 'B4',
        72: 'C5', 74: 'D5', 76: 'E5', 77: 'F5', 79: 'G5', 81: 'A5', 83: 'B5',
        84: 'C6',
      };
      expect(expected.length, 29);
      for (final entry in expected.entries) {
        expect(Pitch.name(entry.key), entry.value);
        expect(Pitch.midiOfDIndex(Pitch.dIndex(entry.key)), entry.key);
      }
    });

    test('黑键不属于本期题库', () {
      expect(Pitch.isNatural(61), isFalse);
      expect(() => Pitch.name(61), throwsArgumentError);
    });

    test('高音谱基线 E4 = 0，低音谱基线 G2 = 0', () {
      expect(Pitch.staffStep(64, Clef.treble), 0);
      expect(Pitch.staffStep(43, Clef.bass), 0);
    });

    test('C4 在高音谱 −2（下加一线）、低音谱 +10（上加一线）', () {
      expect(Pitch.staffStep(60, Clef.treble), -2);
      expect(Pitch.staffStep(60, Clef.bass), 10);
    });
  });

  group('分组结构（对齐口袋五线谱单音练习）', () {
    test('全音域是 88 键钢琴的 52 个白键（A0–C8）', () {
      expect(Groups.naturals.length, 52);
      expect(Groups.naturals.first, 21); // A0
      expect(Groups.naturals.last, 108); // C8
    });

    test('初级 9 个八度分组覆盖全部 52 个自然音，且互不重叠', () {
      final beginner = Groups.ofTier(GroupTier.beginner);
      expect(beginner.length, 9);
      final all = beginner.expand((g) => g.midis).toList();
      expect(all.length, all.toSet().length, reason: '分组之间不能有重复音');
      expect(all.toSet(), Groups.naturals.toSet());
    });

    test('中级「音区」三分组是 16 / 21 / 15，合计 52 且不重叠', () {
      final regions = [Groups.regionLow, Groups.regionMid, Groups.regionHigh];
      expect(regions.map((g) => g.midis.length), [16, 21, 15]);
      final all = regions.expand((g) => g.midis).toList();
      expect(all.length, 52);
      expect(all.toSet().length, 52);
    });

    test('中级「上/中/下加线」是 15 / 18 / 19，合起来是 52 个音', () {
      final positions = [Groups.posBelow, Groups.posMiddle, Groups.posAbove];
      expect(positions.map((g) => g.midis.length), [15, 18, 19]);
      expect(positions.fold<int>(0, (s, g) => s + g.midis.length), 52);
      for (final midi in Groups.posBelow.midis) {
        expect(Pitch.staffStep(midi, midi >= 60 ? Clef.treble : Clef.bass), lessThan(0));
      }
      for (final midi in Groups.posMiddle.midis) {
        final step = Pitch.staffStep(midi, midi >= 60 ? Clef.treble : Clef.bass);
        expect(step, inInclusiveRange(0, 8));
      }
      for (final midi in Groups.posAbove.midis) {
        expect(Pitch.staffStep(midi, midi >= 60 ? Clef.treble : Clef.bass), greaterThan(8));
      }
    });

    test('高级全音区 = 52 个音', () {
      expect(Groups.full.midis.length, 52);
      expect(Groups.byId('full').subtitle, contains('音符数量 52'));
    });

    test('未知分组 id 回退到小字一组', () {
      expect(Groups.byId('nope').id, Groups.oct4.id);
    });
  });

  group('QuestionGenerator', () {
    test('只出该分组的音', () {
      final gen = QuestionGenerator(group: Groups.oct3);
      final allowed = Groups.oct3.midis.toSet();
      for (var i = 0; i < 200; i++) {
        expect(allowed, contains(gen.next(i).midi));
      }
    });

    test('单音分组（仅 C8）也能出题', () {
      final gen = QuestionGenerator(group: Groups.oct8);
      expect(gen.next(0).midi, 108);
    });

    test('相邻不重复', () {
      final gen = QuestionGenerator(group: Groups.oct4);
      var prev = -1;
      for (var i = 0; i < 300; i++) {
        final cur = gen.next(i).midi;
        expect(cur, isNot(prev));
        prev = cur;
      }
    });

    test('选项恒为 6 个且包含答案（分组不足 6 音时用全音区兜底）', () {
      for (final group in [Groups.oct8, Groups.octA0, Groups.full]) {
        final gen = QuestionGenerator(group: group);
        for (final answer in group.midis) {
          final choices = gen.choicesFor(answer);
          expect(choices.length, 6, reason: group.id);
          expect(choices.toSet().length, 6, reason: group.id);
          expect(choices, contains(answer), reason: group.id);
        }
      }
    });
  });
}
