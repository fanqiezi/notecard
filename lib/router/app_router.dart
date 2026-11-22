import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/note_groups.dart';
import '../domain/session.dart';
import '../features/home/home_page.dart';
import '../features/midi/midi_page.dart';
import '../features/navigation/app_shell.dart';
import '../features/practice/practice_page.dart';
import '../features/practice/practice_setup_page.dart';
import '../features/result/result_page.dart';
import '../features/settings/settings_page.dart';
import '../features/statistics/statistics_page.dart';
import '../features/wrong_book/wrong_book_page.dart';

/// 路由表 —— 制作文档 5.1。
///
/// 4 个 Tab 用 StatefulShellRoute 各自保留栈；S2/S3/S4/S9 走顶层路由，
/// 这样它们盖在 Tab 之上、不显示底部导航（与线框图一致）。
abstract final class Routes {
  static const practice = '/practice';
  static const wrongBook = '/wrong-book';
  static const statistics = '/statistics';
  static const settings = '/settings';

  static const setup = '/setup';
  static const session = '/session';
  static const result = '/result';
  static const midi = '/midi';

  /// 由会话配置拼出练习页路径（再来一组 / 开始练习都走这里）。
  static String sessionPath(SessionConfig config) {
    final mode = switch (config.mode) {
      PracticeMode.timed => 'timed',
      PracticeMode.wrong => 'wrong',
      PracticeMode.count => 'count',
    };
    final input = config.input == InputSource.choice ? 'choice' : 'keyboard';
    return '$session?group=${config.groupId}&mode=$mode&count=${config.count}&input=$input';
  }
}

/// 每次调用都返回全新实例。
///
/// 不做成全局 final 的原因：GoRouter 自身持有导航状态，全局单例会让
/// widget 测试之间互相污染（上一个用例停在 /wrong-book，下一个用例启动就不在首页）。
GoRouter createRouter({String initialLocation = Routes.practice}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.practice, builder: (context, state) => const HomePage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.wrongBook, builder: (context, state) => const WrongBookPage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.statistics, builder: (context, state) => const StatisticsPage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.settings, builder: (context, state) => const SettingsPage()),
            ],
          ),
        ],
      ),
      GoRoute(
        path: Routes.setup,
        builder: (context, state) {
          final tierName = state.uri.queryParameters['tier'];
          final tier = GroupTier.values.firstWhere(
            (t) => t.name == tierName,
            orElse: () => GroupTier.beginner,
          );
          return PracticeSetupPage(initialTier: tier);
        },
      ),
      GoRoute(
        path: Routes.session,
        builder: (context, state) {
          final q = state.uri.queryParameters;
          final mode = switch (q['mode']) {
            'timed' => PracticeMode.timed,
            'wrong' => PracticeMode.wrong,
            _ => PracticeMode.count,
          };
          final input = q['input'] == 'choice' ? InputSource.choice : InputSource.touch;
          return PracticePage(
            groupId: q['group'] ?? 'oct4',
            mode: mode,
            count: int.tryParse(q['count'] ?? '') ?? 10,
            input: input,
          );
        },
      ),
      GoRoute(path: Routes.result, builder: (context, state) => const ResultPage()),
      GoRoute(path: Routes.midi, builder: (context, state) => const MidiPage()),
    ],
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final router = createRouter();
  ref.onDispose(router.dispose);
  return router;
});
