/// MIDI 事件规范化 —— 制作文档 7.8 的纯函数版本。
///
/// 放在 domain 层是为了能直接单测：不依赖插件、不依赖平台。
class MidiNoteFilter {
  MidiNoteFilter({this.transpose = 0, this.debounceMs = 300});

  /// 移调（八度），−2…+2。小键盘靠它弹到 C2–C4。
  int transpose;

  /// 去抖窗口：一次判定后的这段时间内的事件只发声、不判定。
  int debounceMs;

  int _lastAcceptedMs = -1 << 30;

  /// 返回规范化后的音高；返回 null 表示这条事件不该产生答案。
  int? accept({
    required bool isNoteOn,
    required int note,
    required int velocity,
    required int nowMs,
  }) {
    if (!isNoteOn) return null; // Note Off / CC / PitchBend 一律忽略
    if (velocity == 0) return null; // velocity 0 即松键（部分键盘的约定）
    if (nowMs - _lastAcceptedMs < debounceMs) return null; // 去抖
    final accepted = (note + 12 * transpose).clamp(0, 127);
    _lastAcceptedMs = nowMs;
    return accepted;
  }

  /// 换设备或开始新会话时重置，避免上一场的去抖窗口影响第一次按键。
  void reset() => _lastAcceptedMs = -1 << 30;
}
