import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:notecard/core/providers.dart';
import 'package:notecard/data/midi/midi_service.dart';
import 'package:notecard/features/midi/midi_controller.dart';

/// 断开时必定抛异常 —— 模拟「设备已经掉线、插件 disconnectDevice 抛错」。
class _ThrowingMidi implements MidiInput {
  @override
  Stream<int> get notes => const Stream.empty();

  @override
  Stream<MidiKeyEvent> get events => const Stream.empty();

  @override
  Stream<String> get disconnected => const Stream.empty();

  @override
  Stream<void> get setupChanged => const Stream.empty();

  @override
  Future<List<MidiDeviceInfo>> refresh() async => const [];

  @override
  Future<void> connect(MidiDeviceInfo device) async {}

  @override
  Future<void> disconnect() async => throw StateError('device already gone');

  @override
  void setTranspose(int octaves) {}

  @override
  Future<void> dispose() async {}
}

void main() {
  test('插件断开抛异常时，本地状态仍要回到未连接', () async {
    final container = ProviderContainer(
      overrides: [midiServiceProvider.overrideWithValue(_ThrowingMidi())],
    );
    addTearDown(container.dispose);

    final notifier = container.read(midiControllerProvider.notifier);
    await notifier.connect(
      const MidiDeviceInfo(id: '8#port=0', name: 'Yamaha Digital Piano', kind: 'native'),
    );
    expect(container.read(midiControllerProvider).connected, isTrue);

    // disconnect 内部会抛，但不应该把界面卡在「已连接」
    await notifier.disconnect();
    expect(container.read(midiControllerProvider).connected, isFalse);
    expect(container.read(midiControllerProvider).connectedName, isNull);
  });

  test('按键测试的时间精确到毫秒', () {
    final t = DateTime(2026, 11, 22, 20, 5, 7, 42);
    expect(formatMidiEventTime(t), '20:05:07.042');
    expect(formatMidiEventTime(DateTime(2026, 11, 22, 9, 0, 0, 999)), '09:00:00.999');
  });
}
