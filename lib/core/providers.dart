import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/audio/audio_service.dart';
import '../data/db/app_database.dart';
import '../data/midi/midi_service.dart';
import '../data/prefs/settings_store.dart';
import '../data/repositories/practice_repository.dart';

/// 本地库单例。惰性创建，第一次读统计/错题时才真正打开。
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// 会话写入与统计查询。
final practiceRepositoryProvider = Provider<PracticeRepository>(
  (ref) => PracticeRepository(ref.watch(databaseProvider)),
);

/// 数据版本号：每写一次会话 +1，让统计类 provider 自动失效重算。
class DbTick extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final dbTickProvider = NotifierProvider<DbTick, int>(DbTick.new);

/// 今日概览（首页四宫格）。
final todayStatsProvider = FutureProvider<TodayStats>((ref) {
  ref.watch(dbTickProvider);
  return ref.watch(practiceRepositoryProvider).today(DateTime.now());
});

/// 错题池（未掌握）。
final wrongPoolProvider = FutureProvider<List<WrongNoteRow>>((ref) {
  ref.watch(dbTickProvider);
  return ref.watch(practiceRepositoryProvider).wrongPool();
});

/// 近 7 天题量。
final dailyCountsProvider = FutureProvider<List<DayCount>>((ref) {
  ref.watch(dbTickProvider);
  return ref.watch(practiceRepositoryProvider).dailyCounts();
});

/// 各级别正确率。
final levelAccuracyProvider = FutureProvider<Map<String, ({int total, int correct})>>((ref) {
  ref.watch(dbTickProvider);
  return ref.watch(practiceRepositoryProvider).levelAccuracy();
});

/// Top5 错音。
final topWrongProvider = FutureProvider<List<({int midi, int wrongCount})>>((ref) {
  ref.watch(dbTickProvider);
  return ref.watch(practiceRepositoryProvider).topWrong();
});

/// 错题专项练习的题池：由 S5 在跳转前写入，控制器 start 时读取。
class WrongPracticePool extends Notifier<List<int>> {
  @override
  List<int> build() => const [];

  void set(List<int> midis) => state = List.unmodifiable(midis);
}

final wrongPracticePoolProvider =
    NotifierProvider<WrongPracticePool, List<int>>(WrongPracticePool.new);

/// 设置项（读写都走这里，写回 shared_preferences）。
class SettingsController extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() => SettingsStore.load();

  /// 不用 update 这个名字：AsyncNotifier 自带 update，会签名冲突
  Future<void> patch(AppSettings Function(AppSettings current) transform) async {
    final current = state.value ?? const AppSettings();
    final next = transform(current);
    state = AsyncData(next);
    await SettingsStore.save(next);
  }
}

/// 音频服务（进程级单例：引擎初始化贵，不能随页面重建）。
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(service.dispose);
  // 音效开关默认开；设置一变就同步到引擎，关掉后 play() 直接返回
  ref.listen<AsyncValue<AppSettings>>(
    settingsControllerProvider,
    (previous, next) {
      final sound = next.value?.soundEnabled;
      if (sound != null) service.soundEnabled = sound;
    },
    fireImmediately: true,
  );
  return service;
});

/// MIDI 服务（进程级单例：插件内部有连接状态，不能随页面创建销毁）。
final midiServiceProvider = Provider<MidiInput>((ref) {
  final service = MidiService();
  ref.onDispose(service.dispose);
  return service;
});

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, AppSettings>(SettingsController.new);
