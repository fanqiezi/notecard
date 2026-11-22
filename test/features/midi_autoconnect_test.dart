import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:notecard/core/providers.dart';
import 'package:notecard/data/midi/midi_service.dart';
import 'package:notecard/data/prefs/settings_store.dart';
import 'package:notecard/features/midi/midi_controller.dart';

const _yamaha = MidiDeviceInfo(
  id: '8#port=0',
  name: 'Yamaha Digital Piano',
  kind: 'native',
);

/// 可手动触发掉线、可控制「前几次扫描为空」的假实现。
class _FakeMidi implements MidiInput {
  final _disconnectCtl = StreamController<String>.broadcast();
  final _setupCtl = StreamController<void>.broadcast();

  /// 前 N 次 refresh 返回空列表，模拟冷启动时 Android MIDI 尚未枚举完。
  int emptyRefreshes = 0;
  MidiDeviceInfo device = _yamaha;

  int refreshCalls = 0;
  int connectCalls = 0;
  String? connectedId;

  @override
  Stream<int> get notes => const Stream.empty();

  @override
  Stream<MidiKeyEvent> get events => const Stream.empty();

  @override
  Stream<String> get disconnected => _disconnectCtl.stream;

  @override
  Stream<void> get setupChanged => _setupCtl.stream;

  @override
  Future<List<MidiDeviceInfo>> refresh() async {
    refreshCalls++;
    if (refreshCalls <= emptyRefreshes) return const [];
    return [device];
  }

  @override
  Future<void> connect(MidiDeviceInfo device) async {
    connectCalls++;
    connectedId = device.id;
  }

  @override
  Future<void> disconnect() async => connectedId = null;

  @override
  void setTranspose(int octaves) {}

  @override
  Future<void> dispose() async {
    await _disconnectCtl.close();
    await _setupCtl.close();
  }

  void emitDisconnect(String id) => _disconnectCtl.add(id);

  void emitSetupChanged() => _setupCtl.add(null);
}

MidiDeviceRecord _record() => const MidiDeviceRecord(
      id: '8#port=0',
      name: 'Yamaha Digital Piano',
      kind: 'native',
      lastAt: 1,
    );

/// 设置已加载：自动连接开、我的设备里有 Yamaha。
class _LoadedSettings extends SettingsController {
  @override
  Future<AppSettings> build() async => AppSettings(
        midiAutoConnect: true,
        savedMidiDevices: [_record()],
      );
}

/// 设置加载慢：验证 refresh 会等它。
class _SlowSettings extends SettingsController {
  @override
  Future<AppSettings> build() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return AppSettings(midiAutoConnect: true, savedMidiDevices: [_record()]);
  }
}

void main() {
  test('设备掉线事件一到，状态立刻回到未连接', () async {
    final fake = _FakeMidi();
    final container = ProviderContainer(
      overrides: [midiServiceProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);

    final notifier = container.read(midiControllerProvider.notifier);
    await notifier.connect(_yamaha);
    expect(container.read(midiControllerProvider).connected, isTrue);

    fake.emitDisconnect('8#port=0');
    await Future<void>.delayed(Duration.zero);

    expect(container.read(midiControllerProvider).connected, isFalse);
  });

  test('refresh 会等设置加载完再自动连接上次设备', () async {
    final fake = _FakeMidi();
    final container = ProviderContainer(
      overrides: [
        midiServiceProvider.overrideWithValue(fake),
        settingsControllerProvider.overrideWith(_SlowSettings.new),
      ],
    );
    addTearDown(container.dispose);

    await container.read(midiControllerProvider.notifier).refresh();
    await Future<void>.delayed(const Duration(milliseconds: 80));

    expect(fake.connectCalls, 1, reason: '应按上次设备自动连一次');
    expect(fake.connectedId, '8#port=0');
  });

  test('设置已就绪时也能自动连接', () async {
    final fake = _FakeMidi();
    final container = ProviderContainer(
      overrides: [
        midiServiceProvider.overrideWithValue(fake),
        settingsControllerProvider.overrideWith(_LoadedSettings.new),
      ],
    );
    addTearDown(container.dispose);

    await container.read(midiControllerProvider.notifier).refresh();
    await Future<void>.delayed(Duration.zero);
    expect(fake.connectCalls, 1);
  });

  test('重插后设备 id 变化（17#port=0 → 18#port=0）仍能自动连接', () async {
    final fake = _FakeMidi()
      ..device = const MidiDeviceInfo(
        id: '18#port=0',
        name: 'Yamaha Digital Piano',
        kind: 'native',
      );
    final container = ProviderContainer(
      overrides: [
        midiServiceProvider.overrideWithValue(fake),
        settingsControllerProvider.overrideWith(_LoadedSettings.new),
      ],
    );
    addTearDown(container.dispose);

    await container.read(midiControllerProvider.notifier).refresh();
    await Future<void>.delayed(Duration.zero);

    expect(fake.connectCalls, 1, reason: '按名称匹配，不应因 id 变化而放弃');
    expect(fake.connectedId, '18#port=0');
  });
  test('冷启动前几次扫描为空时会重试，最终仍能自动连上', () async {
    final fake = _FakeMidi()..emptyRefreshes = 2;
    final container = ProviderContainer(
      overrides: [
        midiServiceProvider.overrideWithValue(fake),
        settingsControllerProvider.overrideWith(_LoadedSettings.new),
      ],
    );
    addTearDown(container.dispose);

    await container.read(midiControllerProvider.notifier).refresh();
    // 每次重试间隔 350ms，第 3 次才拿到设备
    await Future<void>.delayed(const Duration(milliseconds: 1100));

    expect(fake.refreshCalls, greaterThanOrEqualTo(3));
    expect(fake.connectCalls, 1, reason: '扫描到设备后应自动连上');
  });

  test('插线事件会触发重新扫描并自动连接', () async {
    final fake = _FakeMidi()..emptyRefreshes = 1;
    final container = ProviderContainer(
      overrides: [
        midiServiceProvider.overrideWithValue(fake),
        settingsControllerProvider.overrideWith(_LoadedSettings.new),
      ],
    );
    addTearDown(container.dispose);

    // 先建好控制器（订阅 setupChanged），此时还没连接
    container.read(midiControllerProvider);
    await Future<void>.delayed(Duration.zero);
    expect(fake.connectCalls, 0);

    // 模拟插线：插件推 setupChanged，去抖 400ms 后重新扫描
    fake.emitSetupChanged();
    await Future<void>.delayed(const Duration(milliseconds: 900));

    expect(fake.connectCalls, 1, reason: '插线后应自动扫描并连上我的设备');
  });
}
