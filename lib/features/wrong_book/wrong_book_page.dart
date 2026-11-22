import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/constants/note_name.dart';
import '../../core/constants/pitch.dart';
import '../../core/providers.dart';
import '../../core/theme/spacing.dart';
import '../../data/db/app_database.dart';
import '../../domain/session.dart';
import '../../router/app_router.dart';

/// S5 错题本 —— 制作文档 5.2 / 3.4。
class WrongBookPage extends ConsumerStatefulWidget {
  const WrongBookPage({super.key});

  @override
  ConsumerState<WrongBookPage> createState() => _WrongBookPageState();
}

class _WrongBookPageState extends ConsumerState<WrongBookPage> {
  final Set<String> _selected = {};

  static String _key(WrongNoteRow r) => '${r.midi}:${r.clef}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final async = ref.watch(wrongPoolProvider);
    final notes = async.value ?? const <WrongNoteRow>[];

    // 数据刷新后清理已不存在的选中项
    _selected.removeWhere((k) => !notes.any((r) => _key(r) == k));

    final treble = notes.where((r) => r.clef == 'treble').toList();
    final bass = notes.where((r) => r.clef == 'bass').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('错题本'),
        actions: [
          if (notes.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  if (_selected.length == notes.length) {
                    _selected.clear();
                  } else {
                    _selected
                      ..clear()
                      ..addAll(notes.map(_key));
                  }
                });
              },
              child: Text(_selected.length == notes.length ? '取消全选' : '全选'),
            ),
          const SizedBox(width: Gap.s),
        ],
      ),
      body: notes.isEmpty ? const _EmptyState() : _list(theme, treble, bass),
      bottomNavigationBar: notes.isEmpty
          ? null
          : SafeArea(
              minimum: const EdgeInsets.all(Gap.l),
              child: FilledButton(
                onPressed: _selected.isEmpty ? null : _startPractice,
                child: Text(_selected.isEmpty ? '请选择错题' : '开始专项练习（${_selected.length} 条）'),
              ),
            ),
    );
  }

  Widget _list(ThemeData theme, List<WrongNoteRow> treble, List<WrongNoteRow> bass) {
    return ListView(
      padding: Gap.page,
      children: [
        if (treble.isNotEmpty) _group(theme, '高音谱', treble),
        if (bass.isNotEmpty) _group(theme, '低音谱', bass),
        const SizedBox(height: Gap.m),
        Text(
          '长按可标记「已掌握」，连续答对 2 次也会自动移出。',
          style: theme.textTheme.labelSmall,
        ),
      ],
    );
  }

  Widget _group(ThemeData theme, String label, List<WrongNoteRow> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: Gap.s, top: Gap.s),
          child: Row(
            children: [
              Text(label, style: theme.textTheme.titleMedium),
              const SizedBox(width: Gap.s),
              Text('${rows.length} 条', style: theme.textTheme.labelSmall),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: Radii.card,
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                _row(theme, rows[i]),
              ],
            ],
          ),
        ),
        const SizedBox(height: Gap.l),
      ],
    );
  }

  Widget _row(ThemeData theme, WrongNoteRow row) {
    final k = _key(row);
    final selected = _selected.contains(k);
    return InkWell(
      onTap: () => setState(() => selected ? _selected.remove(k) : _selected.add(k)),
      onLongPress: () async {
        await ref.read(practiceRepositoryProvider).setMastered(
              row.midi,
              row.clef == 'treble' ? Clef.treble : Clef.bass,
              mastered: true,
            );
        ref.read(dbTickProvider.notifier).bump();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${NoteNaming.of(row.midi)} 已标记为掌握')),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Gap.m, vertical: Gap.m),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 22,
              color: selected ? theme.colorScheme.primary : theme.dividerColor,
            ),
            const SizedBox(width: Gap.m),
            SizedBox(
              width: 44,
              child: Text(NoteNaming.of(row.midi), style: theme.textTheme.titleMedium),
            ),
            Text('错 ${row.wrongCount} 次', style: theme.textTheme.labelSmall),
            const Spacer(),
            Text(_relativeTime(row.lastWrongAt), style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }

  void _startPractice() {
    final notes = ref.read(wrongPoolProvider).value ?? const <WrongNoteRow>[];
    final pool = notes.where((r) => _selected.contains(_key(r))).map((r) => r.midi).toSet().toList()
      ..sort();
    ref.read(wrongPracticePoolProvider.notifier).set(pool);
    context.push(
      Routes.sessionPath(
        const SessionConfig(groupId: 'oct4', mode: PracticeMode.wrong, count: 10),
      ),
    );
  }

  static String _relativeTime(int epochMs) {
    final diff = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(epochMs));
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes} 分钟前';
    if (diff.inDays < 1) return '${diff.inHours} 小时前';
    if (diff.inDays < 30) return '${diff.inDays} 天前';
    return '${(diff.inDays / 30).floor()} 个月前';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: Gap.page,
      children: [
        Container(
          padding: const EdgeInsets.all(Gap.xl),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: Radii.card,
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            children: [
              Icon(Icons.menu_book_outlined,
                  size: 48, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(height: Gap.m),
              Text('还没有错题', style: theme.textTheme.titleMedium),
              const SizedBox(height: Gap.xs),
              Text('练一组，答错的音会自动收进来',
                  style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
              const SizedBox(height: Gap.l),
              FilledButton(
                onPressed: () => context.go(Routes.practice),
                child: const Text('去练习'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
