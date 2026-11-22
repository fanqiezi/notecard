import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/constants/note_groups.dart';
import '../../core/constants/note_name.dart';
import '../../core/providers.dart';
import '../../core/theme/semantic_colors.dart';
import '../../core/theme/spacing.dart';
import '../../data/repositories/practice_repository.dart';

/// S7 统计 —— 制作文档 5.2 / 3.5。
class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final today = switch (ref.watch(todayStatsProvider)) {
      AsyncData(:final value) => value,
      _ => const TodayStats(),
    };
    final days = ref.watch(dailyCountsProvider).value ?? const <DayCount>[];
    final levels = ref.watch(levelAccuracyProvider).value ?? const <String, ({int total, int correct})>{};
    final topWrong = ref.watch(topWrongProvider).value ?? const <({int midi, int wrongCount})>[];

    return Scaffold(
      appBar: AppBar(title: const Text('统计')),
      body: ListView(
        padding: Gap.page,
        children: [
          Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                Expanded(
                  child: _MetricCard(
                    value: switch (i) {
                      0 => '${today.total}',
                      1 => today.total == 0 ? '—' : '${today.accuracy}%',
                      _ => today.avgReactionMs == 0
                          ? '—'
                          : '${(today.avgReactionMs / 1000).toStringAsFixed(1)}s',
                    },
                    label: ['今日题量', '正确率', '平均反应'][i],
                  ),
                ),
                if (i != 2) const SizedBox(width: Gap.s),
              ],
            ],
          ),
          const SizedBox(height: Gap.l),
          Container(
            padding: const EdgeInsets.all(Gap.l),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: Radii.card,
              border: Border.all(color: theme.dividerColor),
            ),
            child: Row(
              children: [
                Icon(Icons.local_fire_department, color: context.semantic.streak),
                const SizedBox(width: Gap.s),
                Text('连续打卡 ${today.streakDays} 天', style: theme.textTheme.bodyMedium),
                const Spacer(),
                Text('今天${today.total == 0 ? '还没练' : '已打卡'}',
                    style: theme.textTheme.labelSmall),
              ],
            ),
          ),
          const SizedBox(height: Gap.xl),
          Text('近 7 天练习量', style: theme.textTheme.titleMedium),
          const SizedBox(height: Gap.s),
          Container(
            height: 176,
            padding: const EdgeInsets.all(Gap.l),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: Radii.card,
              border: Border.all(color: theme.dividerColor),
            ),
            child: _WeekChart(days: days),
          ),
          const SizedBox(height: Gap.xl),
          Text('各难度正确率', style: theme.textTheme.titleMedium),
          const SizedBox(height: Gap.s),
          Container(
            padding: const EdgeInsets.all(Gap.l),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: Radii.card,
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              children: [
                for (final tier in GroupTier.values) _tierRow(theme, tier, levels),
              ],
            ),
          ),
          const SizedBox(height: Gap.xl),
          Text('Top5 错音', style: theme.textTheme.titleMedium),
          const SizedBox(height: Gap.s),
          if (topWrong.isEmpty)
            Text('还没有错音，保持住', style: theme.textTheme.bodySmall)
          else
            Wrap(
              spacing: Gap.s,
              runSpacing: Gap.s,
              children: [
                for (final w in topWrong)
                  Chip(
                    label: Text('${NoteNaming.of(w.midi)} · ${w.wrongCount} 次'),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          const SizedBox(height: Gap.xl),
        ],
      ),
    );
  }

  /// 按难度层级聚合（分组变多了，逐组展示会把页面撑爆）。
  Widget _tierRow(
    ThemeData theme,
    GroupTier tier,
    Map<String, ({int total, int correct})> levels,
  ) {
    final ids = Groups.ofTier(tier).map((g) => g.id).toSet();
    var total = 0;
    var correct = 0;
    levels.forEach((id, stat) {
      if (ids.contains(id)) {
        total += stat.total;
        correct += stat.correct;
      }
    });
    final accuracy = total == 0 ? 0 : (correct * 100 / total).round();
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.m),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text(tier.label, style: theme.textTheme.labelSmall)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: accuracy / 100,
                minHeight: 8,
                backgroundColor: theme.dividerColor,
              ),
            ),
          ),
          const SizedBox(width: Gap.s),
          SizedBox(
            width: 52,
            child: Text(
              total == 0 ? '未开始' : '$accuracy%',
              style: theme.textTheme.labelSmall,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: Gap.m),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: Radii.card,
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          Text(value, style: theme.textTheme.titleLarge),
          const SizedBox(height: Gap.xs),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

/// 近 7 天柱状图：不引图表库，20 行以内手写足够（制作文档 6.1 的选择）。
class _WeekChart extends StatelessWidget {
  const _WeekChart({required this.days});

  final List<DayCount> days;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (days.isEmpty) {
      return Center(child: Text('还没有数据', style: theme.textTheme.labelSmall));
    }
    final maxTotal = days.map((d) => d.total).fold<int>(0, (a, b) => a > b ? a : b);
    const barMax = 96.0;
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final d in days)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          d.total == 0 ? '' : '${d.total}',
                          style: theme.textTheme.labelSmall,
                        ),
                        const SizedBox(height: 2),
                        Container(
                          height: maxTotal == 0 ? 2 : (d.total / maxTotal) * barMax,
                          decoration: BoxDecoration(
                            color: d.total == 0
                                ? theme.dividerColor
                                : theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: Gap.s),
        Row(
          children: [
            for (final d in days)
              Expanded(
                child: Text(
                  '${d.day.month}/${d.day.day}',
                  style: theme.textTheme.labelSmall,
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
