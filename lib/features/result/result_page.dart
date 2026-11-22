import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/constants/note_name.dart';
import '../../core/theme/semantic_colors.dart';
import '../../core/theme/spacing.dart';
import '../../router/app_router.dart';
import '../practice/practice_controller.dart';

/// S4 结算 —— 制作文档 5.2。
class ResultPage extends ConsumerWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(practiceControllerProvider);
    final theme = Theme.of(context);
    final config = state.config;
    final minutes = state.elapsedMs ~/ 60000;
    final seconds = (state.elapsedMs % 60000) ~/ 1000;

    final stats = <(String, String)>[
      ('${state.correct}', '正确'),
      ('${state.wrong}', '错误'),
      ('${state.timedOut}', '超时'),
      (state.avgReactionMs == 0 ? '—' : '${(state.avgReactionMs / 1000).toStringAsFixed(1)}s', '平均反应'),
    ];

    final wrongNotes = state.logs.where((l) => !l.isCorrect).map((l) => l.expectedMidi).toSet().toList()
      ..sort();

    return Scaffold(
      appBar: AppBar(title: const Text('结算'), automaticallyImplyLeading: false),
      body: ListView(
        padding: Gap.page,
        children: [
          const SizedBox(height: Gap.l),
          Center(
            child: SizedBox(
              width: 176,
              height: 176,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 176,
                    height: 176,
                    child: CircularProgressIndicator(
                      value: state.answered == 0 ? 0 : state.correct / state.answered,
                      strokeWidth: 12,
                      backgroundColor: theme.dividerColor,
                      color: context.semantic.success,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${state.accuracy}%', style: theme.textTheme.displaySmall),
                      const SizedBox(height: Gap.xs),
                      Text('正确率', style: theme.textTheme.labelSmall),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Gap.xl),
          Row(
            children: [
              for (var i = 0; i < stats.length; i++) ...[
                Expanded(child: _StatCard(value: stats[i].$1, label: stats[i].$2)),
                if (i != stats.length - 1) const SizedBox(width: Gap.s),
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
                Icon(Icons.bolt, size: 20, color: context.semantic.streak),
                const SizedBox(width: Gap.s),
                Text('本局最高连击 ×${state.maxCombo}', style: theme.textTheme.bodyMedium),
                const Spacer(),
                Text(
                  '用时 ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: Gap.l),
          Text(
            '本局错音：${wrongNotes.isEmpty ? '无' : wrongNotes.map(NoteNaming.of).join(' ')}',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(Gap.l),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.go(Routes.practice),
                child: const Text('返回主页'),
              ),
            ),
            const SizedBox(width: Gap.m),
            Expanded(
              child: FilledButton(
                onPressed: config == null
                    ? null
                    : () => context.pushReplacement(Routes.sessionPath(config)),
                child: const Text('再来一组'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: Gap.l),
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
