// 分组常量用 oct_c4 / region_low 这类命名，与产品、文档保持一致。
// ignore_for_file: constant_identifier_names

import 'package:material_ui/material_ui.dart';

import 'note_name.dart';
import 'pitch.dart';

/// 三个难度层级 —— 对齐口袋五线谱「单音练习」的 初级 / 中级 / 高级。
enum GroupTier {
  beginner('初级'),
  intermediate('中级'),
  advanced('高级');

  const GroupTier(this.label);
  final String label;
}

/// 一个练习分组。
///
/// 与旧的「6 个固定级别」相比，这里的分组只描述**候选音集合**，
/// 谱号按音高决定（midi ≥ 60 用高音谱），所以同一分组里可以混谱表。
@immutable
class NoteGroup {
  const NoteGroup({
    required this.id,
    required this.title,
    required this.section,
    required this.tier,
    required this.midis,
  });

  final String id;
  final String title;

  /// 分组所在的小节标题，如「常用音符」「音区练习」。
  final String section;
  final GroupTier tier;
  final List<int> midis;

  /// 谱号规则：C4 及以上用高音谱，其余低音谱（制作文档 6.3.5）。
  Clef clefFor(int midi) => midi >= 60 ? Clef.treble : Clef.bass;

  /// 形如「C2–B2 | 音符数量 7」。
  String get subtitle {
    if (midis.isEmpty) return '音符数量 0';
    return '${NoteNaming.range(midis)} | 音符数量 ${midis.length}';
  }
}

/// 一个八度的自然音（C–B）。
List<int> _octave(int octave) {
  const semitones = [0, 2, 4, 5, 7, 9, 11];
  final base = (octave + 1) * 12;
  return [for (final s in semitones) base + s];
}

abstract final class Groups {
  /// 钢琴 88 键的全部白键：A0(21) – C8(108)，共 52 个。
  static final List<int> naturals = () {
    final list = <int>[21, 23]; // A0, B0
    for (var oct = 1; oct <= 7; oct++) {
      list.addAll(_octave(oct));
    }
    list.add(108); // C8
    return list;
  }();

  // ─────────── 初级：按八度分组 ───────────
  static final octA0 = NoteGroup(
    id: 'octA0',
    title: '大字二组',
    section: '其他音符',
    tier: GroupTier.beginner,
    midis: const [21, 23],
  );

  static final oct1 = NoteGroup(
    id: 'oct1',
    title: '大字一组',
    section: '其他音符',
    tier: GroupTier.beginner,
    midis: _octave(1),
  );

  static final oct2 = NoteGroup(
    id: 'oct2',
    title: '大字组',
    section: '常用音符',
    tier: GroupTier.beginner,
    midis: _octave(2),
  );

  static final oct3 = NoteGroup(
    id: 'oct3',
    title: '小字组',
    section: '常用音符',
    tier: GroupTier.beginner,
    midis: _octave(3),
  );

  static final oct4 = NoteGroup(
    id: 'oct4',
    title: '小字一组',
    section: '常用音符',
    tier: GroupTier.beginner,
    midis: _octave(4),
  );

  static final oct5 = NoteGroup(
    id: 'oct5',
    title: '小字二组',
    section: '常用音符',
    tier: GroupTier.beginner,
    midis: _octave(5),
  );

  static final oct6 = NoteGroup(
    id: 'oct6',
    title: '小字三组',
    section: '常用音符',
    tier: GroupTier.beginner,
    midis: _octave(6),
  );

  static final oct7 = NoteGroup(
    id: 'oct7',
    title: '小字四组',
    section: '其他音符',
    tier: GroupTier.beginner,
    midis: _octave(7),
  );

  static final oct8 = NoteGroup(
    id: 'oct8',
    title: '小字五组',
    section: '其他音符',
    tier: GroupTier.beginner,
    midis: const [108],
  );

  // ─────────── 中级：音区 + 谱表位置（与参考 App 的 16 / 21 / 15 一致） ───────────
  static final regionLow = NoteGroup(
    id: 'region_low',
    title: '低音区',
    section: '音区练习',
    tier: GroupTier.intermediate,
    midis: [...naturals.where((m) => m <= 47)],
  );

  static final regionMid = NoteGroup(
    id: 'region_mid',
    title: '中音区',
    section: '音区练习',
    tier: GroupTier.intermediate,
    midis: [...naturals.where((m) => m >= 48 && m <= 83)],
  );

  static final regionHigh = NoteGroup(
    id: 'region_high',
    title: '高音区',
    section: '音区练习',
    tier: GroupTier.intermediate,
    midis: [...naturals.where((m) => m >= 84)],
  );

  /// staffStep < 0：低音谱 A0–F2，高音谱 C4–D4（共 15）。
  static final posBelow = NoteGroup(
    id: 'pos_below',
    title: '下加线',
    section: '分组练习',
    tier: GroupTier.intermediate,
    midis: const [
      21, 23, 24, 26, 28, 29, 31, 33, 35, 36, 38, 40, 41, // 低音谱 A0–F2
      60, 62, // 高音谱 C4–D4
    ],
  );

  /// 0 ≤ staffStep ≤ 8：谱表内（共 18）。
  static final posMiddle = NoteGroup(
    id: 'pos_middle',
    title: '中间线',
    section: '分组练习',
    tier: GroupTier.intermediate,
    midis: const [
      43, 45, 47, 48, 50, 52, 53, 55, 57, // 低音谱 G2–A3
      64, 65, 67, 69, 71, 72, 74, 76, 77, // 高音谱 E4–F5
    ],
  );

  /// staffStep > 8：低音谱 B3，高音谱 G5–C8（共 19）。
  static final posAbove = NoteGroup(
    id: 'pos_above',
    title: '上加线',
    section: '分组练习',
    tier: GroupTier.intermediate,
    midis: const [
      59,
      79, 81, 83, 84, 86, 88, 89, 91, 93, 95,
      96, 98, 100, 101, 103, 105, 107, 108,
    ],
  );

  // ─────────── 高级：全音区 52 ───────────
  static final full = NoteGroup(
    id: 'full',
    title: '全音区',
    section: '全音区',
    tier: GroupTier.advanced,
    midis: naturals,
  );

  static final all = [
    // 顺序即 UI 顺序：常用音符 → 其他音符
    oct2, oct3, oct4, oct5, oct6,
    octA0, oct1, oct7, oct8,
    regionLow, regionMid, regionHigh,
    posBelow, posMiddle, posAbove,
    full,
  ];

  static NoteGroup byId(String id) => all.firstWhere(
        (g) => g.id == id,
        orElse: () => oct4,
      );

  static NoteGroup? tryById(String id) {
    for (final g in all) {
      if (g.id == id) return g;
    }
    return null;
  }

  static List<NoteGroup> ofTier(GroupTier tier) => all.where((g) => g.tier == tier).toList();

  /// 同一 tier 内按 section 分组，保持声明顺序。
  static Map<String, List<NoteGroup>> sectionsOf(GroupTier tier) {
    final map = <String, List<NoteGroup>>{};
    for (final g in ofTier(tier)) {
      map.putIfAbsent(g.section, () => []).add(g);
    }
    return map;
  }
}
