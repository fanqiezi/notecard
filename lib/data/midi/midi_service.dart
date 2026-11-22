import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:flutter_midi_command/flutter_midi_command_messages.dart';

import '../../domain/midi_filter.dart';

/// 一台 MIDI 输入设备（脱离插件类型的轻量表示）。
class MidiDeviceInfo {
  const MidiDeviceInfo({required this.id, required this.name, required this.kind});

  final String id;
  final String name;

  /// native / BLE / virtual …
  final String kind;
}

/// 测试框的时间格式：HH:mm:ss.SSS
String formatMidiEventTime(DateTime t) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(t.hour)}:${two(t.minute)}:${two(t.second)}.${t.millisecond.toString().padLeft(3, '0')}';
}

/// 一次原始按键事件（未移调、未去抖），设备页的测试框用。
class MidiKeyEvent {
  const MidiKeyEvent({required this.midi, required this.isOn, required this.velocity, required this.at});

  final int midi;
  final bool isOn;
  final int velocity;
  final DateTime at;
}

/// MIDI 输入抽象：练习页只依赖它，测试用 Fake 注入。
abstract interface class MidiInput {
  /// 已移调、已去抖的音高流（答题用）。
  Stream<int> get notes;

  /// 原始按键事件流（未移调、未去抖），设备页测试框用。
  Stream<MidiKeyEvent> get events;

  /// 设备掉线事件（携带设备 id）：拔线 / 设备自己断开时插件会推，界面要立刻回到未连接。
  Stream<String> get disconnected;

  /// 设备列表变化（插拔线都会触发），用于重新扫描与自动连接。
  Stream<void> get setupChanged;

  Future<List<MidiDeviceInfo>> refresh();

  Future<void> connect(MidiDeviceInfo device);

  Future<void> disconnect();

  void setTranspose(int octaves);

  Future<void> dispose();
}

/// 真实实现：flutter_midi_command（底层 android.media.midi）。
///
/// 制作文档 6.9：只启用原生 USB 传输，排除 BLE（BLE 要额外权限，且插件有扫描 bug）。
class MidiService implements MidiInput {
  MidiService({MidiNoteFilter? filter}) : _filter = filter ?? MidiNoteFilter();

  /// 连接成功后的回调，用来把「上次设备」写进设置。
  void Function(MidiDeviceInfo device)? onConnected;

  final MidiNoteFilter _filter;
  final StreamController<int> _notes = StreamController<int>.broadcast();
  final StreamController<MidiKeyEvent> _events = StreamController<MidiKeyEvent>.broadcast();
  final StreamController<String> _disconnectedCtl = StreamController<String>.broadcast();
  final StreamController<void> _setupCtl = StreamController<void>.broadcast();
  StreamSubscription<MidiConnectionState>? _deviceConnSub;
  StreamSubscription<dynamic>? _setupSub;
  bool _disconnectEmitted = false;
  final Map<String, MidiDevice> _byId = {};

  MidiCommand? _command;
  StreamSubscription<MidiDataReceivedEvent>? _subscription;
  String? _connectedId;

  @override
  Stream<int> get notes => _notes.stream;

  @override
  Stream<MidiKeyEvent> get events => _events.stream;

  @override
  Stream<String> get disconnected => _disconnectedCtl.stream;

  @override
  Stream<void> get setupChanged => _setupCtl.stream;

  void _emitDisconnected(String id) {
    if (_disconnectEmitted) return;
    _disconnectEmitted = true;
    _connectedId = null;
    if (!_disconnectedCtl.isClosed) _disconnectedCtl.add(id);
  }

  bool get isInitialized => _command != null;

  MidiCommand _ensure() {
    final existing = _command;
    if (existing != null) return existing;

    final command = MidiCommand();
    // 不启用 BLE：manifest 里没有蓝牙权限，启用会在运行期抛错
    try {
      command.configureTransportPolicy(
        const MidiTransportPolicy(excludedTransports: {MidiTransport.ble}),
      );
    } catch (_) {
      // 老版本没有 transport policy 时忽略
    }
    _subscription = command.onMidiDataReceived?.listen(_onEvent);
    // 插拔线：设备列表变化后如果当前设备不在了，就判定为掉线
    _setupSub = command.onMidiSetupChanged?.listen((_) async {
      if (!_setupCtl.isClosed) _setupCtl.add(null);
      final id = _connectedId;
      if (id == null) return;
      final list = await command.devices ?? const <MidiDevice>[];
      if (!list.any((d) => d.id == id)) _emitDisconnected(id);
    });
    _command = command;
    return command;
  }

  void _onEvent(MidiDataReceivedEvent event) {
    final message = event.message;
    // 先发原始事件（测试框要看按下/抬起，包括 velocity=0 的松键）
    if (message is NoteOnMessage) {
      _emitRaw(message.note, message.velocity > 0, message.velocity);
      if (message.velocity == 0) return; // velocity 0 = 松键，不参与答题
    } else if (message is NoteOffMessage) {
      _emitRaw(message.note, false, message.velocity);
      return;
    } else {
      return;
    }
    final accepted = _filter.accept(
      isNoteOn: true,
      note: message.note,
      velocity: message.velocity,
      nowMs: DateTime.now().millisecondsSinceEpoch,
    );
    if (accepted != null && !_notes.isClosed) {
      _notes.add(accepted);
    }
  }

  void _emitRaw(int note, bool isOn, int velocity) {
    if (_events.isClosed) return;
    _events.add(MidiKeyEvent(midi: note, isOn: isOn, velocity: velocity, at: DateTime.now()));
  }

  @override
  Future<List<MidiDeviceInfo>> refresh() async {
    final command = _ensure();
    final devices = await command.devices ?? const <MidiDevice>[];
    _byId
      ..clear()
      ..addEntries(devices.map((d) => MapEntry(d.id, d)));
    return devices
        .map((d) => MidiDeviceInfo(
              id: d.id,
              // 有些键盘报空名字，回退成 id；名字里可能带换行（Yamaha 就是）
              name: _cleanName(d.name, d.id),
              kind: d.type.wireValue,
            ))
        .toList();
  }

  static String _cleanName(String raw, String id) => cleanMidiDeviceName(raw, id);

  @override
  Future<void> connect(MidiDeviceInfo device) async {
    final command = _ensure();
    // 设备对象可能在刷新后失效，先按 id 找最新的
    final target = _byId[device.id];
    if (target == null) {
      throw StateError('设备已断开：${device.name}');
    }
    await command.connectToDevice(target);
    _connectedId = device.id;
    _disconnectEmitted = false;
    _filter.reset();
    // 设备自己断开（拔线/关机）时插件会推状态，必须回传给 UI
    await _deviceConnSub?.cancel();
    _deviceConnSub = target.onConnectionStateChanged.listen((state) {
      if (state == MidiConnectionState.disconnected) _emitDisconnected(device.id);
    });
    onConnected?.call(device);
  }

  @override
  Future<void> disconnect() async {
    final id = _connectedId;
    final target = id == null ? null : _byId[id];
    // 插件在「设备已掉线」时会抛异常，不能让它阻断本地状态清理
    if (target != null) {
      try {
        _command?.disconnectDevice(target);
      } catch (e) {
        debugPrint('MIDI disconnectDevice 抛异常（已忽略）：$e');
      }
    }
    _connectedId = null;
  }

  @override
  void setTranspose(int octaves) => _filter.transpose = octaves.clamp(-2, 2);

  @override
  Future<void> dispose() async {
    await _subscription?.cancel();
    await disconnect();
    _command?.dispose();
    _command = null;
    await _deviceConnSub?.cancel();
    await _setupSub?.cancel();
    await _notes.close();
    await _events.close();
    await _disconnectedCtl.close();
    await _setupCtl.close();
  }
}

/// 设备名清洗：MIDI 设备名里常带换行（Yamaha 报的是 "Yamaha Corporation\nDigital Piano"），
/// 直接渲染会把卡片撑成两行、把右侧按钮挤出边界。统一压成单空格。
String cleanMidiDeviceName(String raw, String id) {
  final cleaned = raw
      .replaceAll(RegExp(r'[\r\n\t]+'), ' ')
      .replaceAll(RegExp(r' {2,}'), ' ')
      .trim();
  return cleaned.isEmpty ? 'MIDI 设备 ($id)' : cleaned;
}