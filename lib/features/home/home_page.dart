import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/constants/note_groups.dart';
import '../../core/providers.dart';
import '../../core/theme/semantic_colors.dart';
import '../../core/theme/spacing.dart';
import '../../data/repositories/practice_repository.dart';
import '../../domain/session.dart';
import '../../router/app_router.dart';

/// S1 主页 —— 制作文档 5.2。
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final stats = switch (ref.watch(todayStatsProvider)) {
      AsyncData(:final value) => value,
      _ => const TodayStats(),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('音符卡'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: Gap.l),
            child: Row(
              children: [
                Icon(Icons.local_fire_department, size: 20, color: context.semantic.streak),
                const SizedBox(width: Gap.xs),
                Text('${stats.streakDays} 天', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: Gap.page,
        children: [
          _ContinueCard(
            stats: stats,
            onStart: () => context.push(Routes.sessionPath(const SessionConfig(groupId: 'oct4'))),
          ),
          const SizedBox(height: Gap.m),
          _TodayGrid(stats: stats),
          const SizedBox(height: Gap.xl),
          Text('难度', style: theme.textTheme.titleMedium),
          const SizedBox(height: Gap.s),
          for (final tier in GroupTier.values) ...[
            _TierCard(
              tier: tier,
              onTap: () => context.push('${Routes.setup}?tier=${tier.name}'),
            ),
            const SizedBox(height: Gap.m),
          ],
          const SizedBox(height: Gap.l),
        ],
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  const _TierCard({required this.tier, required this.onTap});

  final GroupTier tier;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groups = Groups.ofTier(tier);
    final totalNotes = groups.fold<int>(0, (sum, g) => sum + g.midis.length);
    final all = groups.expand((g) => g.midis).toSet().toList()..sort();

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: Radii.card,
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.card,
        child: Container(
          padding: const EdgeInsets.all(Gap.l),
          decoration: BoxDecoration(
            borderRadius: Radii.card,
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.music_note, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: Gap.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tier.label, style: theme.textTheme.titleMedium),
                    const SizedBox(height: Gap.xs),
                    Text(
                      '${groups.length} 个分组 · ${all.length} 个音'
                      '${totalNotes > 0 ? '' : ''}',
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.stats, required this.onStart});

  final TodayStats stats;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hint = stats.total == 0
        ? '今天还没练 · 建议 10 题，约 1 分钟'
        : '今天已练 ${stats.total} 题 · 正确率 ${stats.accuracy}%';
    return Container(
      padding: Gap.card,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: Radii.card,
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('继续练习', style: theme.textTheme.titleMedium),
              const Spacer(),
              Text('小字一组 · C4–B4', style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: Gap.s),
          Text(hint, style: theme.textTheme.bodySmall),
          const SizedBox(height: Gap.l),
          FilledButton(onPressed: onStart, child: const Text('开始练习')),
        ],
      ),
    );
  }
}

class _TodayGrid extends StatelessWidget {
  const _TodayGrid({required this.stats});

  final TodayStats stats;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('${stats.total}', '今日题量'),
      (stats.total == 0 ? '—' : '${stats.accuracy}%', '正确率'),
      (stats.avgReactionMs == 0 ? '—' : '${(stats.avgReactionMs / 1000).toStringAsFixed(1)}s', '平均反应'),
      ('${stats.streakDays}', '连续天数'),
    ];
    final theme = Theme.of(context);
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: Gap.m),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: Radii.card,
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                children: [
                  Text(items[i].$1, style: theme.textTheme.titleLarge),
                  const SizedBox(height: Gap.xs),
                  Text(items[i].$2, style: theme.textTheme.labelSmall),
                ],
              ),
            ),
          ),
          if (i != items.length - 1) const SizedBox(width: Gap.s),
        ],
      ],
    );
  }
}
