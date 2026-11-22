import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/constants/note_name.dart';
import '../../core/constants/pitch.dart';
import '../../core/providers.dart';
import '../../core/theme/spacing.dart';
import '../../data/midi/midi_service.dart';
import '../../data/prefs/settings_store.dart';
import 'midi_controller.dart';

/// S9 MIDI 设备页 —— 制作文档 5.2 / 3.7。
class MidiPage extends ConsumerStatefulWidget {
  const MidiPage({super.key});

  @override
  ConsumerState<MidiPage> createState() => _MidiPageState();
}

class _MidiPageState extends ConsumerState<MidiPage> {
  /// 测试框里最多留这么多条，避免无限增长。
  static const _maxEvents = 40;
  final List<MidiKeyEvent> _log = [];
  StreamSubscription<MidiKeyEvent>? _sub;

  @override
  void initState() {
    super.initState();
    // 原始按键事件（未移调、未去抖），用来验证连接与按键时序
    _sub = ref.read(midiServiceProvider).events.listen((e) {
      if (!mounted) return;
      setState(() {
        _log.insert(0, e);
        if (_log.length > _maxEvents) _log.removeLast();
      });
    });
    // 首帧后扫描一次，避免 initState 里直接 await
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(midiControllerProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(midiControllerProvider);
    final settings = ref.watch(settingsControllerProvider).value ?? const AppSettings();
    final transpose = settings.midiTranspose;

    return Scaffold(
      appBar: AppBar(title: const Text('MIDI 键盘')),
      body: ListView(
        padding: Gap.page,
        children: [
          Text('已连接', style: theme.textTheme.titleMedium),
          const SizedBox(height: Gap.s),
          _Card(
            child: state.connected
                // 不用 ListTile：设备名很长时 trailing 会被挤出卡片边界，
                // 这里改成 Row + Expanded，名字单行省略，按钮固定右侧。
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Gap.l, vertical: Gap.m),
                    child: Row(
                      children: [
                        const Icon(Icons.piano),
                        const SizedBox(width: Gap.m),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.connectedName ?? 'MIDI 键盘',
                                style: theme.textTheme.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '已连接 · 练习页可直接用它答题',
                                style: theme.textTheme.labelSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: Gap.s),
                        TextButton(
                          onPressed: () =>
                              ref.read(midiControllerProvider.notifier).disconnect(),
                          child: const Text('断开'),
                        ),
                      ],
                    ),
                  )
                : ListTile(
                    leading: Icon(Icons.piano, color: theme.colorScheme.onSurfaceVariant),
                    title: const Text('未连接设备'),
                    subtitle: const Text('用 USB 线连接键盘后点「刷新」'),
                  ),
          ),
          const SizedBox(height: Gap.l),
          _Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: settings.midiAutoConnect,
                  onChanged: (v) => ref
                      .read(settingsControllerProvider.notifier)
                      .patch((s) => s.copyWith(midiAutoConnect: v)),
                  title: const Text('自动连接'),
                  subtitle: Text('打开本页时自动连上次那台键盘',
                      style: theme.textTheme.labelSmall),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: settings.showLiveNote,
                  onChanged: (v) => ref
                      .read(settingsControllerProvider.notifier)
                      .patch((s) => s.copyWith(showLiveNote: v)),
                  title: const Text('音符显示'),
                  subtitle: Text('五线谱上实时显示按下的音',
                      style: theme.textTheme.labelSmall),
                ),
              ],
            ),
          ),
          const SizedBox(height: Gap.xl),
          Text('移调（八度）', style: theme.textTheme.titleMedium),
          const SizedBox(height: Gap.s),
          _Card(
            child: Row(
              children: [
                const SizedBox(width: Gap.s),
                IconButton(
                  onPressed: transpose > -2 ? () => _setTranspose(transpose - 1) : null,
                  icon: const Icon(Icons.remove),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      transpose == 0 ? '0' : (transpose > 0 ? '+$transpose' : '$transpose'),
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: transpose < 2 ? () => _setTranspose(transpose + 1) : null,
                  icon: const Icon(Icons.add),
                ),
                const SizedBox(width: Gap.s),
              ],
            ),
          ),
          const SizedBox(height: Gap.s),
          Text(
            '25 键小键盘请把移调设为 +1 或 +2 才能弹到 C2–C6',
            style: theme.textTheme.labelSmall,
          ),
          const SizedBox(height: Gap.xl),
          Text('琴键音来源', style: theme.textTheme.titleMedium),
          const SizedBox(height: Gap.s),
          _Card(
            child: const ListTile(
              title: Text('App 播放'),
              subtitle: Text('键盘自带音源时可改为「仅设备发声」避免双音'),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
          const SizedBox(height: Gap.xl),
          Row(
            children: [
              Text('我的设备', style: theme.textTheme.titleMedium),
              const SizedBox(width: Gap.s),
              Text('${settings.savedMidiDevices.length} 台',
                  style: theme.textTheme.labelSmall),
            ],
          ),
          const SizedBox(height: Gap.s),
          _Card(
            child: settings.savedMidiDevices.isEmpty
                ? ListTile(
                    title: Text(
                      '还没有连接记录，连一台键盘后会自动记住',
                      style: theme.textTheme.labelSmall,
                    ),
                  )
                : Column(
                    children: [
                      for (var i = 0; i < settings.savedMidiDevices.length; i++) ...[
                        if (i > 0) const Divider(height: 1),
                        _savedDeviceTile(theme, settings.savedMidiDevices[i], state),
                      ],
                    ],
                  ),
          ),
          const SizedBox(height: Gap.xl),
          Row(
            children: [
              Text('已发现设备', style: theme.textTheme.titleMedium),
              const Spacer(),
              TextButton(
                onPressed: state.busy
                    ? null
                    : () => ref.read(midiControllerProvider.notifier).refresh(),
                child: state.busy
                    ? const SizedBox(
                        width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('刷新'),
              ),
            ],
          ),
          const SizedBox(height: Gap.s),
          _Card(
            child: state.devices.isEmpty
                ? ListTile(
                    title: Text(
                      state.error ?? '暂无设备，请用 USB 线连接键盘后重试',
                      style: theme.textTheme.bodySmall,
                    ),
                  )
                : Column(
                    children: [
                      for (var i = 0; i < state.devices.length; i++) ...[
                        if (i > 0) const Divider(height: 1),
                        _deviceTile(theme, state.devices[i], state),
                      ],
                    ],
                  ),
          ),
          if (state.error != null) ...[
            const SizedBox(height: Gap.s),
            Text(state.error!, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.error)),
          ],
          const SizedBox(height: Gap.xl),
          Row(
            children: [
              Text('按键测试', style: theme.textTheme.titleMedium),
              const SizedBox(width: Gap.s),
              Text('最近 ${_log.length}/$_maxEvents 条', style: theme.textTheme.labelSmall),
              const Spacer(),
              if (_log.isNotEmpty)
                TextButton(
                  onPressed: () => setState(_log.clear),
                  child: const Text('清空'),
                ),
            ],
          ),
          const SizedBox(height: Gap.s),
          _Card(
            child: SizedBox(
              height: 200,
              child: _log.isEmpty
                  ? Center(
                      child: Text(
                        '连接后按一下琴键，这里会按时间顺序显示按下/抬起事件',
                        style: theme.textTheme.labelSmall,
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: Gap.s),
                      itemCount: _log.length,
                      itemBuilder: (context, index) {
                        final e = _log[index];
                        final color = e.isOn
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant;
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: Gap.l, vertical: Gap.xs),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 96,
                                child: Text(_clock(e.at),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                        fontFeatures: const [FontFeature.tabularFigures()])),
                              ),
                              SizedBox(
                                width: 36,
                                child: Text(e.isOn ? '按下' : '抬起',
                                    style: theme.textTheme.labelSmall?.copyWith(color: color)),
                              ),
                              Expanded(
                                child: Text(
                                  _label(e.midi),
                                  style: theme.textTheme.bodyMedium?.copyWith(color: color),
                                ),
                              ),
                              Text('力度 ${e.velocity}', style: theme.textTheme.labelSmall),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  static String _clock(DateTime t) => formatMidiEventTime(t);

  static const _pitchClasses = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];

  /// 测试框里的音名：自然音跟随当前记法，黑键用带升号的写法。
  static String _label(int midi) =>
      Pitch.isNatural(midi) ? NoteNaming.marked(midi) : '${_pitchClasses[midi % 12]}${midi ~/ 12 - 1}';

  /// 「我的设备」：状态 + 连接 / 信息 / 删除。
  Widget _savedDeviceTile(ThemeData theme, MidiDeviceRecord record, MidiState state) {
    final isConnected = state.connectedId == record.id;
    final isOnline = _findOnline(record.stableKey) != null;
    final status = isConnected ? '已连接' : (isOnline ? '未连接 · 已插入' : '未连接');
    return ListTile(
      leading: Icon(
        Icons.piano,
        color: isConnected ? theme.colorScheme.primary : null,
      ),
      title: Text(record.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Row(
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: isConnected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(status, style: theme.textTheme.labelSmall),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: '连接',
            iconSize: 20,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            icon: Icon(
              Icons.link,
              color: isConnected ? theme.colorScheme.primary : null,
            ),
            onPressed: isConnected ? null : () => _connectSaved(record),
          ),
          IconButton(
            tooltip: '信息',
            iconSize: 20,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showSavedInfo(record, isConnected, isOnline),
          ),
          IconButton(
            tooltip: '删除',
            iconSize: 20,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _deleteSaved(record),
          ),
        ],
      ),
    );
  }

  /// 按「传输方式 + 名称」找在线设备：插拔后 id 会变，不能按 id 找。
  MidiDeviceInfo? _findOnline(String stableKey) {
    for (final d in ref.read(midiControllerProvider).devices) {
      if ('${d.kind.toLowerCase()}::${d.name.toLowerCase().trim()}' == stableKey) return d;
    }
    return null;
  }

  Future<void> _connectSaved(MidiDeviceRecord record) async {
    final notifier = ref.read(midiControllerProvider.notifier);
    var match = _findOnline(record.stableKey);
    if (match == null) {
      // 历史设备可能刚插上还没扫描到，先刷一次
      await notifier.refresh();
      match = _findOnline(record.stableKey);
    }
    if (match == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${record.name} 当前不在线，请插好 USB 后重试')),
      );
      return;
    }
    await notifier.connect(match);
  }

  void _showSavedInfo(MidiDeviceRecord record, bool isConnected, bool isOnline) {
    final last = record.lastAt == 0
        ? '—'
        : DateTime.fromMillisecondsSinceEpoch(record.lastAt).toString().substring(0, 19);
    final status = isConnected ? '已连接' : (isOnline ? '未连接（已插入）' : '未连接');
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(record.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('设备 ID', record.id),
            _infoRow('传输方式', record.kind),
            _infoRow('状态', status),
            _infoRow('最近连接', last),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('关闭')),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 76, child: Text(label, style: theme.textTheme.labelSmall)),
          Expanded(child: SelectableText(value, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }

  Future<void> _deleteSaved(MidiDeviceRecord record) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除设备？'),
        content: Text('从「我的设备」移除 ${record.name}，不影响实际插着的键盘。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('删除')),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(midiControllerProvider.notifier).forgetDevice(record.stableKey);
  }

  Widget _deviceTile(ThemeData theme, MidiDeviceInfo device, MidiState state) {
    final isCurrent = state.connectedId == device.id;
    return ListTile(
      leading: Icon(
        device.kind == 'BLE' ? Icons.bluetooth : Icons.usb,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      // 名字单行省略：MIDI 设备名经常很长（"Yamaha Corporation Digital Piano"）
      title: Text(device.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      // 只显示传输方式；内部 id（native · 8#port=0）对用户没意义
      subtitle: Text(
        isCurrent ? '${device.kind} · 已连接' : device.kind,
        style: theme.textTheme.labelSmall,
      ),
      trailing: isCurrent
          ? Icon(Icons.check, color: theme.colorScheme.primary)
          : TextButton(
              onPressed: () => ref.read(midiControllerProvider.notifier).connect(device),
              child: const Text('连接'),
            ),
      onTap: isCurrent ? null : () => ref.read(midiControllerProvider.notifier).connect(device),
    );
  }

  Future<void> _setTranspose(int value) async {
    await ref.read(settingsControllerProvider.notifier).patch((s) => s.copyWith(midiTranspose: value));
    ref.read(midiServiceProvider).setTranspose(value);
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: Radii.card,
        border: Border.all(color: theme.dividerColor),
      ),
      child: Material(type: MaterialType.transparency, child: child),
    );
  }
}
