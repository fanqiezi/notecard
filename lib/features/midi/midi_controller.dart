import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/midi/midi_service.dart';
import '../../data/prefs/settings_store.dart';

/// MIDI 连接状态 —— S9 与练习页共用。
class MidiState {
  const MidiState({
    this.busy = false,
    this.error,
    this.devices = const [],
    this.connectedId,
    this.connectedName,
  });

  final bool busy;
  final String? error;
  final List<MidiDeviceInfo> devices;
  final String? connectedId;
  final String? connectedName;

  bool get connected => connectedId != null;

  MidiState copyWith({
    bool? busy,
    String? error,
    bool clearError = false,
    List<MidiDeviceInfo>? devices,
    String? connectedId,
    String? connectedName,
    bool clearConnected = false,
  }) {
    return MidiState(
      busy: busy ?? this.busy,
      error: clearError ? null : (error ?? this.error),
      devices: devices ?? this.devices,
      connectedId: clearConnected ? null : (connectedId ?? this.connectedId),
      connectedName: clearConnected ? null : (connectedName ?? this.connectedName),
    );
  }
}

class MidiController extends Notifier<MidiState> {
  StreamSubscription<String>? _disconnectSub;
  StreamSubscription<void>? _setupSub;
  Timer? _refreshDebounce;
  bool _refreshing = false;
  String? _connectedStableKey;

  @override
  MidiState build() {
    final service = ref.read(midiServiceProvider);
    // 插拔线时插件会推设备掉线，界面要跟着回到「未连接」
    _disconnectSub = service.disconnected.listen((id) {
      if (state.connectedId == id) {
        _connectedStableKey = null;
        state = state.copyWith(busy: false, clearConnected: true);
      }
    });
    // 设备列表变化（插线）→ 重新扫描，命中「我的设备」就自动连上
    _setupSub = service.setupChanged.listen((_) => _scheduleRefresh());
    ref.onDispose(() {
      _disconnectSub?.cancel();
      _setupSub?.cancel();
      _refreshDebounce?.cancel();
    });
    return const MidiState();
  }

  MidiInput get _service => ref.read(midiServiceProvider);

  static String _stableKeyOf(MidiDeviceInfo d) =>
      '${d.kind.toLowerCase()}::${d.name.toLowerCase().trim()}';

  /// 进入练习页时确保扫过一次（用户可能从不打开设备页）。
  Future<void> ensureScanned() async {
    if (_refreshing) return;
    if (state.devices.isEmpty) await refresh();
  }

  /// 插件插拔时会连续推好几个事件，去抖后只扫一次。
  void _scheduleRefresh() {
    _refreshDebounce?.cancel();
    _refreshDebounce = Timer(const Duration(milliseconds: 400), () {
      refresh();
    });
  }

  Future<void> refresh() async {
    if (_refreshing) return;
    _refreshing = true;
    state = state.copyWith(busy: true, clearError: true);
    try {
      final settings = await _readSettings();
      var devices = await _service.refresh();
      // 冷启动时 Android MIDI 服务尚未枚举完，devices 常常先返回空列表。
      // 只有「确实有想自动连的设备」时才重试，避免没琴的用户白等 1.4s。
      final wantsAuto = settings.midiAutoConnect && settings.lastMidiDevice != null;
      for (var i = 0; i < 4 && wantsAuto && devices.isEmpty; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 350));
        devices = await _service.refresh();
      }
      state = state.copyWith(busy: false, devices: devices, clearError: true);
      await _autoConnectIfNeeded(devices, settings);
    } catch (e) {
      state = state.copyWith(busy: false, error: '扫描失败：$e');
    } finally {
      _refreshing = false;
    }
  }

  Future<void> connect(MidiDeviceInfo device) async {
    state = state.copyWith(busy: true, clearError: true);
    try {
      await _service.connect(device);
      _connectedStableKey = _stableKeyOf(device);
      state = state.copyWith(
        busy: false,
        connectedId: device.id,
        connectedName: device.name,
        clearError: true,
      );
      await _rememberDevice(device);
    } catch (e) {
      state = state.copyWith(busy: false, error: '连接失败：$e');
    }
  }

  /// 自动连接「我的设备」里最近用过的、当前在线的设备。
  Future<void> _autoConnectIfNeeded(List<MidiDeviceInfo> devices, AppSettings settings) async {
    if (state.connectedId != null) return;
    if (!settings.midiAutoConnect) return;
    final target = settings.lastMidiDevice;
    if (target == null) return;
    // 不能按 id 比：Android 每次插拔都会换 id，同一台琴对不上。
    // 按「传输方式 + 名称」匹配，连上后再把新 id 写回记录。
    for (final d in devices) {
      if (_stableKeyOf(d) == target.stableKey) {
        await connect(d);
        return;
      }
    }
  }

  /// 必须等设置从 shared_preferences 读完：页面打开时 refresh 立刻跑，
  /// 用 .value 会拿到 null，自动连接永远不生效。
  Future<AppSettings> _readSettings() async {
    try {
      return await ref.read(settingsControllerProvider.future);
    } catch (e) {
      debugPrint('读取设置失败（自动连接降级为默认）：$e');
      return const AppSettings();
    }
  }

  /// 把设备记进「我的设备」（去重 + 按最近使用排序 + 上限 20）。
  Future<void> _rememberDevice(MidiDeviceInfo device) async {
    try {
      await ref.read(settingsControllerProvider.future);
      final key = _stableKeyOf(device);
      await ref.read(settingsControllerProvider.notifier).patch((s) {
        final rest = s.savedMidiDevices.where((d) => d.stableKey != key).toList();
        final record = MidiDeviceRecord(
          id: device.id,
          name: device.name,
          kind: device.kind,
          lastAt: DateTime.now().millisecondsSinceEpoch,
        );
        return s.copyWith(savedMidiDevices: [record, ...rest].take(20).toList());
      });
    } catch (e) {
      debugPrint('记住 MIDI 设备失败：$e');
    }
  }

  /// 从「我的设备」里删除；如果正连着它，先断开。
  Future<void> forgetDevice(String stableKey) async {
    if (_connectedStableKey == stableKey) await disconnect();
    try {
      await ref.read(settingsControllerProvider.future);
      await ref.read(settingsControllerProvider.notifier).patch(
            (s) => s.copyWith(
              savedMidiDevices: s.savedMidiDevices.where((d) => d.stableKey != stableKey).toList(),
            ),
          );
    } catch (e) {
      debugPrint('删除 MIDI 设备失败：$e');
    }
  }

  Future<void> disconnect() async {
    // 无论插件侧成不成功，本地状态都必须回到「未连接」，
    // 否则界面会一直显示已连接（插件在设备掉线时 disconnectDevice 会抛）。
    try {
      await _service.disconnect();
    } catch (e) {
      debugPrint('断开 MIDI 失败（已忽略，状态仍清空）：$e');
    }
    _connectedStableKey = null;
    state = state.copyWith(busy: false, clearConnected: true, clearError: true);
  }
}

final midiControllerProvider =
    NotifierProvider<MidiController, MidiState>(MidiController.new);
