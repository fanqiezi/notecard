import 'dart:math';

import '../core/constants/note_groups.dart';
import '../core/constants/pitch.dart';

/// 题库生成器 —— 制作文档 7.3。
///
/// 规则：
///   1. 从分组的候选集随机取，避免与上一题相同（最多重抽 20 次，仍相同则顺延一个）
///   2. 选项模式的干扰项优先取「同分组、相邻半音」，分组不足 6 个时用全音区兜底
///   3. 错题专项：候选集来自错题本，谱号按音高决定
class QuestionGenerator {
  QuestionGenerator({required NoteGroup group, Random? random})
      : group = group,
        _rng = random ?? Random(),
        _pool = List<int>.of(group.midis),
        _optionPool = group.midis.length >= 6 ? List<int>.of(group.midis) : Groups.naturals,
        clefOf = group.clefFor;

  /// 错题专项：候选集外部传入。
  QuestionGenerator.custom({
    required List<int> pool,
    required this.clefOf,
    List<int>? optionPool,
    Random? random,
  })  : group = null,
        _rng = random ?? Random(),
        _pool = List<int>.of(pool),
        _optionPool = List<int>.of(optionPool ?? Groups.naturals);

  /// 分组（错题专项为 null）。
  final NoteGroup? group;
  final Clef Function(int midi) clefOf;
  final Random _rng;
  final List<int> _pool;
  final List<int> _optionPool;
  int? _lastMidi;
  int _seq = 0;

  List<int> get pool => List.unmodifiable(_pool);
  List<int> get optionPool => List.unmodifiable(_optionPool);

  /// 生成下一题。
  ({int midi, Clef clef, int seq}) next(int presentedAtMs) {
    assert(_pool.isNotEmpty, '空题库');
    var midi = _pool[_rng.nextInt(_pool.length)];
    for (var i = 0; i < 20 && midi == _lastMidi; i++) {
      midi = _pool[_rng.nextInt(_pool.length)];
    }
    if (midi == _lastMidi && _pool.length > 1) {
      midi = _pool[(_pool.indexOf(_lastMidi!) + 1) % _pool.length];
    }
    _lastMidi = midi;
    return (midi: midi, clef: clefOf(midi), seq: _seq++);
  }

  /// 选项模式：答案 + 5 个干扰项。
  List<int> choicesFor(int answerMidi) {
    final others = _optionPool.where((m) => m != answerMidi).toList()..shuffle(_rng);
    final near = others.where((m) => (m - answerMidi).abs() <= 7).toList();
    final picked = <int>{answerMidi};
    for (final m in [...near, ...others]) {
      if (picked.length >= 6) break;
      picked.add(m);
    }
    var offset = 1;
    while (picked.length < 6) {
      final candidate = answerMidi + (offset.isOdd ? offset : -offset);
      if (candidate > 24 && candidate < 96) picked.add(candidate);
      offset++;
    }
    return picked.toList()..shuffle(_rng);
  }
}
