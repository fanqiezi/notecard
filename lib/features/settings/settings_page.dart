import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/providers.dart';
import '../../core/theme/semantic_colors.dart';
import '../../core/theme/spacing.dart';
import '../../core/constants/note_name.dart';
import '../../data/prefs/settings_store.dart';
import '../../router/app_router.dart';
import '../midi/midi_controller.dart';

/// S8 设置 —— 制作文档 3.6 / 5.2。所有项即时写回 shared_preferences。
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsControllerProvider).value ?? const AppSettings();
    final midi = ref.watch(midiControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListView(
        padding: Gap.page,
        children: [
          Text('答题', style: theme.textTheme.titleMedium),
          const SizedBox(height: Gap.s),
          _Card(
            children: [
              SwitchListTile(
                value: settings.soundEnabled,
                onChanged: (v) => controller.patch((s) => s.copyWith(soundEnabled: v)),
                title: const Text('琴键音效'),
                subtitle: Text('音频在 M1.5 接入，开关先存下来',
                    style: theme.textTheme.labelSmall),
              ),
              const Divider(),
              SwitchListTile(
                value: settings.vibrationEnabled,
                onChanged: (v) => controller.patch((s) => s.copyWith(vibrationEnabled: v)),
                title: const Text('震动反馈'),
              ),
              const Divider(),
              SwitchListTile(
                value: settings.autoFollowOctave,
                onChanged: (v) => controller.patch((s) => s.copyWith(autoFollowOctave: v)),
                title: const Text('自动切换到音符所在分组'),
                subtitle: Text('键盘自动翻到该音所在的八度',
                    style: theme.textTheme.labelSmall),
              ),
              const Divider(),
              ListTile(
                title: const Text('答题方式'),
                subtitle: Text(settings.answerInput == AnswerInput.keyboard ? '琴键模式' : '选项模式'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _pickAnswerInput(context, controller, settings),
              ),
              const Divider(),
              ListTile(
                title: const Text('音名显示'),
                subtitle: Text(settings.noteNameStyle == NoteNameStyle.cde ? 'C-D-E' : 'do-re-mi'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _pickNoteName(context, controller, settings),
              ),
              const Divider(),
              ListTile(
                title: const Text('音名记法'),
                subtitle: Text(settings.pitchNotation.label),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _pickNotation(context, controller, settings),
              ),
              const Divider(),
              ListTile(
                title: const Text('主题'),
                subtitle: Text(switch (settings.themeMode) {
                  ThemeMode.system => '跟随系统',
                  ThemeMode.light => '浅色',
                  ThemeMode.dark => '深色',
                }),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _pickTheme(context, controller, settings),
              ),
            ],
          ),
          const SizedBox(height: Gap.xl),
          Text('设备', style: theme.textTheme.titleMedium),
          const SizedBox(height: Gap.s),
          _Card(
            children: [
              ListTile(
                leading: Icon(
                  Icons.piano,
                  color: midi.connected ? theme.colorScheme.primary : null,
                ),
                title: const Text('MIDI 键盘'),
                // 跟随 MIDI 连接状态，不再写死「未连接」
                subtitle: Text(
                  midi.connected ? (midi.connectedName ?? '已连接') : '未连接',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Icon(
                  midi.connected ? Icons.check_circle : Icons.chevron_right,
                  color: midi.connected ? theme.colorScheme.primary : null,
                ),
                onTap: () => context.push(Routes.midi),
              ),
            ],
          ),
          const SizedBox(height: Gap.xl),
          Text('数据', style: theme.textTheme.titleMedium),
          const SizedBox(height: Gap.s),
          _Card(
            children: [
              ListTile(
                title: const Text('清空练习记录'),
                subtitle: Text('会话与逐题记录，不影响错题本', style: theme.textTheme.labelSmall),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _confirmClear(context, ref, wrongOnly: false),
              ),
              const Divider(),
              ListTile(
                title: const Text('清空错题本'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _confirmClear(context, ref, wrongOnly: true),
              ),
            ],
          ),
          const SizedBox(height: Gap.xl),
          Text('关于', style: theme.textTheme.titleMedium),
          const SizedBox(height: Gap.s),
          _Card(
            children: [
              const ListTile(title: Text('版本'), subtitle: Text('1.1.0 (2)')),
              const Divider(),
              const ListTile(
                title: Text('字体与素材'),
                subtitle: Text('Bravura（SIL OFL 1.1）· 钢琴采样（CC BY 3.0，M1.5 接入）'),
              ),
              const Divider(),
              _DbStatusTile(),
            ],
          ),
          const SizedBox(height: Gap.xl),
          Center(
            child: Text('音符卡 NoteCard · 完全离线 · 无账号', style: theme.textTheme.labelSmall),
          ),
          const SizedBox(height: Gap.xl),
        ],
      ),
    );
  }

  Future<void> _pickAnswerInput(
      BuildContext context, SettingsController c, AppSettings s) async {
    final picked = await showModalBottomSheet<AnswerInput>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final v in AnswerInput.values)
              ListTile(
                title: Text(v == AnswerInput.keyboard ? '琴键模式' : '选项模式'),
                trailing: s.answerInput == v ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(ctx, v),
              ),
          ],
        ),
      ),
    );
    if (picked != null) await c.patch((cur) => cur.copyWith(answerInput: picked));
  }

  Future<void> _pickNoteName(
      BuildContext context, SettingsController c, AppSettings s) async {
    final picked = await showModalBottomSheet<NoteNameStyle>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final v in NoteNameStyle.values)
              ListTile(
                title: Text(v == NoteNameStyle.cde ? 'C-D-E' : 'do-re-mi'),
                trailing: s.noteNameStyle == v ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(ctx, v),
              ),
          ],
        ),
      ),
    );
    if (picked != null) await c.patch((cur) => cur.copyWith(noteNameStyle: picked));
  }

  Future<void> _pickNotation(
      BuildContext context, SettingsController c, AppSettings s) async {
    final picked = await showModalBottomSheet<PitchNotation>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final v in PitchNotation.values)
              ListTile(
                title: Text(v.label),
                subtitle: Text(v == PitchNotation.chinese ? '中央 C 记作 c1，大字组用大写' : '中央 C 记作 C4'),
                trailing: s.pitchNotation == v ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(ctx, v),
              ),
          ],
        ),
      ),
    );
    if (picked != null) await c.patch((cur) => cur.copyWith(pitchNotation: picked));
  }

  Future<void> _pickTheme(BuildContext context, SettingsController c, AppSettings s) async {
    final picked = await showModalBottomSheet<ThemeMode>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final entry in const [
              (ThemeMode.system, '跟随系统'),
              (ThemeMode.light, '浅色'),
              (ThemeMode.dark, '深色'),
            ])
              ListTile(
                title: Text(entry.$2),
                trailing: s.themeMode == entry.$1 ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(ctx, entry.$1),
              ),
          ],
        ),
      ),
    );
    if (picked != null) await c.patch((cur) => cur.copyWith(themeMode: picked));
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref, {required bool wrongOnly}) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(wrongOnly ? '清空错题本？' : '清空练习记录？'),
        content: const Text('此操作不可撤销。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('确认清空')),
        ],
      ),
    );
    if (ok != true) return;
    final repo = ref.read(practiceRepositoryProvider);
    if (wrongOnly) {
      await repo.clearWrongNotes();
    } else {
      await repo.clearAll();
    }
    ref.read(dbTickProvider.notifier).bump();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已清空')));
    }
  }
}

class _DbStatusTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final db = ref.watch(databaseProvider);
    return FutureBuilder<Map<String, int>>(
      future: db.tableCounts(),
      builder: (context, snapshot) {
        final counts = snapshot.data;
        final text = counts == null
            ? (snapshot.hasError ? '打开失败' : '初始化中…')
            : 'practice_session ${counts['practice_session']} · '
                'answer_record ${counts['answer_record']} · '
                'wrong_note ${counts['wrong_note']}';
        return ListTile(
          title: const Text('本地数据库'),
          subtitle: Text(text, style: theme.textTheme.labelSmall),
          trailing: Icon(
            counts == null ? Icons.hourglass_empty : Icons.check_circle,
            color: counts == null ? theme.colorScheme.onSurfaceVariant : context.semantic.success,
            size: 20,
          ),
        );
      },
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: Radii.card,
        border: Border.all(color: theme.dividerColor),
      ),
      // ListTile 需要 Material 祖先来画背景与水波纹；外层是带底色的 Container，
      // 不隔离的话 debug 下会报「ink splashes may be invisible」。
      child: Material(
        type: MaterialType.transparency,
        child: Column(children: children),
      ),
    );
  }
}
