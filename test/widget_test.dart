// 冒烟测试：骨架导航 + 进入练习后能清理计时器。
// 领域逻辑（音高映射、题库、错题调度）见 test/domain/。

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:notecard/app.dart';

void main() {
  testWidgets('首屏渲染出主页与 4 个 Tab', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: NoteCardApp()));
    await tester.pumpAndSettle();

    expect(find.text('音符卡'), findsOneWidget);
    expect(find.text('继续练习'), findsOneWidget);
    expect(find.text('练习'), findsOneWidget);
    expect(find.text('错题本'), findsOneWidget);
    expect(find.text('统计'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('切到错题本能看到空态', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: NoteCardApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('错题本'));
    await tester.pumpAndSettle();

    expect(find.text('还没有错题'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('首页「开始练习」进入练习页并出题', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: NoteCardApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('开始练习'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('第 1/10 题'), findsOneWidget);

    // 卸载以触发 onDispose，取消出题/超时计时器，避免 pending timer 报错
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('点难度卡进入单音练习分组页', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: NoteCardApp()));
    await tester.pumpAndSettle();

    expect(find.text('初级'), findsOneWidget);
    await tester.tap(find.text('初级'));
    await tester.pumpAndSettle();

    expect(find.text('单音练习'), findsOneWidget);
    expect(find.text('大字组'), findsOneWidget);
    expect(find.text('小字一组'), findsOneWidget);
    // 练习设置区在列表下方，首屏不渲染；只校验吸底按钮带上了所选分组
    expect(find.textContaining('开始练习 · 大字组'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
