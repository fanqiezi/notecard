import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:notecard/core/providers.dart';
import 'package:notecard/core/theme/app_theme.dart';
import 'package:notecard/data/midi/midi_service.dart';
import 'package:notecard/data/prefs/settings_store.dart';
import 'package:notecard/features/midi/midi_page.dart';

class _FakeMidi implements MidiInput {
  final _disconnectCtl = StreamController<String>.broadcast();
  final _setupCtl = StreamController<void>.broadcast();

  @override
  Stream<int> get notes => const Stream.empty();
  @override
  Stream<MidiKeyEvent> get events => const Stream.empty();
  @override
  Stream<String> get disconnected => _disconnectCtl.stream;
  @override
  Stream<void> get setupChanged => _setupCtl.stream;
  @override
  Future<List<MidiDeviceInfo>> refresh() async => const [
        MidiDeviceInfo(id: '8#port=0', name: 'Yamaha Digital Piano', kind: 'native'),
      ];
  @override
  Future<void> connect(MidiDeviceInfo device) async {}
  @override
  Future<void> disconnect() async {}
  @override
  void setTranspose(int octaves) {}
  @override
  Future<void> dispose() async {}
}

class _SavedSettings extends SettingsController {
  @override
  Future<AppSettings> build() async => const AppSettings(
        savedMidiDevices: [
          MidiDeviceRecord(id: '8#port=0', name: 'Yamaha Digital Piano', kind: 'native', lastAt: 1),
          MidiDeviceRecord(id: '5#port=0', name: '旧键盘', kind: 'native', lastAt: 2),
        ],
      );
}

void main() {
  testWidgets('我的设备：显示状态与三个按钮，信息弹窗可打开', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          midiServiceProvider.overrideWithValue(_FakeMidi()),
          settingsControllerProvider.overrideWith(_SavedSettings.new),
        ],
        child: MaterialApp(theme: AppTheme.light(), home: const MidiPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('我的设备'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();

    expect(find.text('我的设备'), findsOneWidget);
    expect(find.text('2 台'), findsOneWidget);
    expect(find.text('Yamaha Digital Piano'), findsWidgets);
    expect(find.text('旧键盘'), findsOneWidget);

    // 三个按钮都在
    expect(find.byTooltip('连接'), findsNWidgets(2));
    expect(find.byTooltip('信息'), findsNWidgets(2));
    expect(find.byTooltip('删除'), findsNWidgets(2));

    // 信息弹窗
    await tester.tap(find.byTooltip('信息').first);
    await tester.pumpAndSettle();
    expect(find.text('设备 ID'), findsOneWidget);
    expect(find.text('8#port=0'), findsOneWidget);
    await tester.tap(find.text('关闭'));
    await tester.pumpAndSettle();

    // 删除确认
    await tester.tap(find.byTooltip('删除').first);
    await tester.pumpAndSettle();
    expect(find.text('删除设备？'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
  });
}
