import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

/// 钢琴音效 —— 制作文档 6.4。
///
/// 采样只存 C2–C6 每 3 个半音一个（Salamander 在 Tone.js 的网格），
/// 其余音高用 `setRelativePlaySpeed` 变速补足；因为采样点密，最大偏移 1.5 个半音，
/// 变速带来的音色失真在识谱练习里可以接受。
///
/// 注意：引擎必须**惰性获取**。`SoLoud.instance` 在 `flutter test` 的宿主机上没有原生库
/// （error 126），若写在字段初始化里，Provider 会直接进入 error state，整棵页面树都渲染不出来。
class AudioService {
  AudioService();

  /// 采样点（MIDI）。
  static const List<int> sampleMidis = [
    21, 24, 27, 30, 33, // A0–A1
    36, 39, 42, 45,
    48, 51, 54, 57,
    60, 63, 66, 69,
    72, 75, 78, 81,
    84, 87, 90, 93, // C6–A6
    96, 99, 102, 105, 108, // C7–C8
  ];

  final Map<int, AudioSource> _sources = {};
  SoLoud? _engine;

  bool _initialized = false;
  bool _available = false;
  bool soundEnabled = true;

  bool get available => _available;

  /// 启动预热：初始化引擎 + 预载全部采样 + 0 音量播一次建轨。
  ///
  /// 制作文档 6.4.2：把「第一次点琴键」的冷启动延迟（150–400ms）挪到进页时。
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      final engine = SoLoud.instance;
      _engine = engine;
      // 4.x 没有 lowLatency 开关：默认就走 AAudio/OpenSL 的低延迟路径
      await engine.init(sampleRate: 44100, bufferSize: 2048);
      for (final midi in sampleMidis) {
        _sources[midi] = await engine.loadAsset(
          'assets/audio/piano_${midi.toString().padLeft(3, '0')}.mp3',
          mode: LoadMode.memory,
        );
      }
      // 预热：0 音量播一下 C4，强制建轨与首包解码
      final warm = engine.play(_sources[60]!, volume: 0);
      engine.stop(warm);
      _available = true;
    } catch (e) {
      // 音频初始化失败只降级，不阻塞答题（制作文档 6.4.4）
      _available = false;
      debugPrint('音频初始化失败，已降级为静音：$e');
    }
  }

  /// 播放某个音高（自动选最近采样 + 变速）。
  void play(int midi) {
    if (!_available || !soundEnabled) return;
    final engine = _engine;
    if (engine == null) return;
    final sample = _nearestSample(midi);
    final source = _sources[sample];
    if (source == null) return;
    final speed = math.pow(2, (midi - sample) / 12).toDouble().clamp(0.5, 2.0);
    try {
      final handle = engine.play(source, volume: 0.9);
      if ((speed - 1.0).abs() > 0.001) {
        engine.setRelativePlaySpeed(handle, speed);
      }
    } catch (e) {
      debugPrint('播放失败：$e');
    }
  }

  static int _nearestSample(int midi) {
    var best = sampleMidis.first;
    var bestDistance = 999;
    for (final s in sampleMidis) {
      final d = (s - midi).abs();
      if (d < bestDistance) {
        bestDistance = d;
        best = s;
      }
    }
    return best;
  }

  Future<void> dispose() async {
    final engine = _engine;
    if (!_available || engine == null) return;
    for (final source in _sources.values) {
      await engine.disposeSource(source);
    }
    _sources.clear();
    engine.deinit();
    _available = false;
  }
}
