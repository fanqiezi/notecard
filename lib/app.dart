import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'core/constants/note_name.dart';
import 'core/providers.dart';
import 'core/theme/app_theme.dart';
import 'features/midi/midi_controller.dart';
import 'router/app_router.dart';

class NoteCardApp extends ConsumerStatefulWidget {
  const NoteCardApp({super.key});

  @override
  ConsumerState<NoteCardApp> createState() => _NoteCardAppState();
}

class _NoteCardAppState extends ConsumerState<NoteCardApp> {
  @override
  void initState() {
    super.initState();
    // 启动即扫描 MIDI：这样重开 App 就能自动连回上次的琴，
    // 不必先进设备页；同时建立插拔监听（控制器 build 里订阅）。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(midiControllerProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsControllerProvider);
    // 设置还没读出来时先跟随系统，避免启动闪烁
    final themeMode = settings.value?.themeMode ?? ThemeMode.system;
    // 音名记法：全局同步一次，谱面/键盘/统计等展示点直接读 NoteNaming
    NoteNaming.notation = settings.value?.pitchNotation ?? PitchNotation.chinese;

    return MaterialApp.router(
      title: '音符卡',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
