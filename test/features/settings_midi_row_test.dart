import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:notecard/core/providers.dart';
import 'package:notecard/core/theme/app_theme.dart';
import 'package:notecard/data/db/app_database.dart';
import 'package:notecard/features/midi/midi_controller.dart';
import 'package:notecard/features/settings/settings_page.dart';

/// 假装已经连上键盘。
class _ConnectedMidi extends MidiController {
  @override
  MidiState build() => const MidiState(
        connectedId: '8#port=0',
        connectedName: 'Yamaha Corporation Digital Piano',
      );
}

void main() {
  testWidgets('设置页的 MIDI 行跟随连接状态，不再写死「未连接」', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          midiControllerProvider.overrideWith(_ConnectedMidi.new),
          databaseProvider.overrideWithValue(db),
        ],
        child: MaterialApp(theme: AppTheme.light(), home: const SettingsPage()),
      ),
    );
    await tester.pumpAndSettle();
    // 设置页很长，MIDI 行在首屏之外，先滚过去
    await tester.dragUntilVisible(
      find.text('MIDI 键盘'),
      find.byType(ListView),
      const Offset(0, -220),
    );
    await tester.pumpAndSettle();

    expect(find.text('MIDI 键盘'), findsOneWidget);
    expect(find.text('Yamaha Corporation Digital Piano'), findsOneWidget);
    expect(find.text('未连接'), findsNothing);
  });

  testWidgets('未连接时仍然显示「未连接」', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(theme: AppTheme.light(), home: const SettingsPage()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(
      find.text('MIDI 键盘'),
      find.byType(ListView),
      const Offset(0, -220),
    );
    await tester.pumpAndSettle();

    expect(find.text('未连接'), findsOneWidget);
  });
}
