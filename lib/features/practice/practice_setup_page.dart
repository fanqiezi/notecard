import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/constants/note_groups.dart';
import '../../core/providers.dart';
import '../../core/theme/spacing.dart';
import '../../data/prefs/settings_store.dart';
import '../../domain/session.dart';
import '../../router/app_router.dart';

/// S2 练习配置 —— 对齐口袋五线谱「单音练习」的 初级/中级/高级 + 分组列表。
class PracticeSetupPage extends ConsumerStatefulWidget {
  const PracticeSetupPage({super.key, this.initialTier = GroupTier.beginner});

  final GroupTier initialTier;

  @override
  ConsumerState<PracticeSetupPage> createState() => _PracticeSetupPageState();
}

class _PracticeSetupPageState extends ConsumerState<PracticeSetupPage> {
  late GroupTier _tier;
  late String _groupId;
  bool _timed = false;
  int _count = 10;
  bool _keyboard = true;

  @override
  void initState() {
    super.initState();
    _tier = widget.initialTier;
    _groupId = Groups.ofTier(_tier).first.id;
    // 默认答题方式跟随设置（制作文档 3.6：设置里改了下一次练习生效）
    final settings = ref.read(settingsControllerProvider).value;
    if (settings != null) {
      _keyboard = settings.answerInput == AnswerInput.keyboard;
    }
  }

  void _selectTier(GroupTier tier) {
    setState(() {
      _tier = tier;
      _groupId = Groups.ofTier(tier).first.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sections = Groups.sectionsOf(_tier);

    return Scaffold(
      appBar: AppBar(title: const Text('单音练习')),
      body: ListView(
        padding: Gap.page,
        children: [
          // 难度三档
          Container(
            padding: const EdgeInsets.all(Gap.xs),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: Radii.card,
            ),
            child: Row(
              children: [
                for (final tier in GroupTier.values)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectTier(tier),
                      child: AnimatedContainer(
                        duration: Motion.short,
                        padding: const EdgeInsets.symmetric(vertical: Gap.m),
                        decoration: BoxDecoration(
                          color: _tier == tier ? theme.colorScheme.surface : Colors.transparent,
                          borderRadius: BorderRadius.circular(Radii.sm),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          tier.label,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: _tier == tier
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: _tier == tier ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Gap.l),
          for (final entry in sections.entries) ...[
            Padding(
              padding: const EdgeInsets.only(top: Gap.s, bottom: Gap.s),
              child: Text(entry.key, style: theme.textTheme.titleMedium),
            ),
            for (final group in entry.value) ...[
              _GroupTile(
                group: group,
                selected: _groupId == group.id,
                onTap: () => setState(() => _groupId = group.id),
              ),
              const SizedBox(height: Gap.s),
            ],
            const SizedBox(height: Gap.m),
          ],
          const SizedBox(height: Gap.s),
          Text('练习设置', style: theme.textTheme.titleMedium),
          const SizedBox(height: Gap.s),
          Row(
            children: [
              Expanded(
                child: _ModeChip(
                  label: '题量',
                  selected: !_timed,
                  onTap: () => setState(() => _timed = false),
                ),
              ),
              const SizedBox(width: Gap.s),
              Expanded(
                child: _ModeChip(
                  label: '限时 60s',
                  selected: _timed,
                  onTap: () => setState(() => _timed = true),
                ),
              ),
            ],
          ),
          if (!_timed) ...[
            const SizedBox(height: Gap.s),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 10, label: Text('10')),
                ButtonSegment(value: 20, label: Text('20')),
                ButtonSegment(value: 50, label: Text('50')),
              ],
              selected: {_count},
              onSelectionChanged: (v) => setState(() => _count = v.first),
            ),
          ],
          const SizedBox(height: Gap.s),
          Row(
            children: [
              Expanded(
                child: _ModeChip(
                  label: '琴键模式',
                  selected: _keyboard,
                  onTap: () => setState(() => _keyboard = true),
                ),
              ),
              const SizedBox(width: Gap.s),
              Expanded(
                child: _ModeChip(
                  label: '选项模式',
                  selected: !_keyboard,
                  onTap: () => setState(() => _keyboard = false),
                ),
              ),
            ],
          ),
          const SizedBox(height: Gap.xl),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(Gap.l),
        child: FilledButton(
          onPressed: () {
            final config = SessionConfig(
              groupId: _groupId,
              mode: _timed ? PracticeMode.timed : PracticeMode.count,
              count: _timed ? 10 : _count,
              input: _keyboard ? InputSource.touch : InputSource.choice,
            );
            context.push(Routes.sessionPath(config));
          },
          child: Text('开始练习 · ${Groups.byId(_groupId).title}'),
        ),
      ),
    );
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({required this.group, required this.selected, required this.onTap});

  final NoteGroup group;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: Radii.card,
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.card,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: Gap.l, vertical: Gap.m),
          decoration: BoxDecoration(
            borderRadius: Radii.card,
            border: Border.all(
              color: selected ? theme.colorScheme.primary : theme.dividerColor,
              width: selected ? 2 : 1,
            ),
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
                    Text(group.title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: Gap.xs),
                    Text(group.subtitle, style: theme.textTheme.labelSmall),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.check_circle : Icons.chevron_right,
                color: selected ? theme.colorScheme.primary : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: Gap.m),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: Radii.card,
          border: Border.all(
            color: selected ? theme.colorScheme.primary : theme.dividerColor,
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(label, style: theme.textTheme.bodyMedium),
      ),
    );
  }
}
