import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/note_name.dart';

/// 答题方式 —— 制作文档 3.6。
enum AnswerInput { keyboard, choice }

/// 音名显示。
enum NoteNameStyle { cde, solfege }

/// 连接过的 MIDI 设备（「我的设备」列表用）。
@immutable
class MidiDeviceRecord {
  const MidiDeviceRecord({
    required this.id,
    required this.name,
    required this.kind,
    required this.lastAt,
  });

  final String id;
  final String name;

  /// native / BLE / virtual …
  final String kind;

  /// 最近一次连接时间（毫秒时间戳），自动连接取最新的那台。
  final int lastAt;

  /// Android 每次插拔都会给同一台琴分配新 id（13#port=0 → 16#port=0 → 17#port=0），
  /// 所以跨会话的身份只能用「传输方式 + 名称」。
  String get stableKey => '${kind.toLowerCase()}::${name.toLowerCase().trim()}';

  Map<String, Object?> toJson() => {'id': id, 'name': name, 'kind': kind, 'lastAt': lastAt};

  static MidiDeviceRecord? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final name = raw['name'];
    if (id is! String || name is! String) return null;
    return MidiDeviceRecord(
      id: id,
      name: name,
      kind: raw['kind'] as String? ?? 'native',
      lastAt: (raw['lastAt'] as num?)?.toInt() ?? 0,
    );
  }

  MidiDeviceRecord touched() =>
      MidiDeviceRecord(id: id, name: name, kind: kind, lastAt: DateTime.now().millisecondsSinceEpoch);
}

/// 设置项（存在 shared_preferences，不落库）。
@immutable
class AppSettings {
  const AppSettings({
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.answerInput = AnswerInput.keyboard,
    this.noteNameStyle = NoteNameStyle.cde,
    this.themeMode = ThemeMode.system,
    this.midiTranspose = 0,
    this.autoFollowOctave = true,
    this.pitchNotation = PitchNotation.chinese,
    this.midiAutoConnect = true,
    this.showLiveNote = true,
    this.savedMidiDevices = const [],
  });

  final bool soundEnabled;
  final bool vibrationEnabled;
  final AnswerInput answerInput;
  final NoteNameStyle noteNameStyle;
  final ThemeMode themeMode;

  /// −2…+2 个八度，小键盘靠它弹到 C2–C4（制作文档 3.7.3）。
  final int midiTranspose;

  /// 自动把键盘切到当前音符所在的八度分组（默认开）。
  final bool autoFollowOctave;

  /// 音名记法，默认中国科学音高记号法。
  final PitchNotation pitchNotation;

  /// 打开设备页时自动重连上次那台键盘。
  final bool midiAutoConnect;

  /// 五线谱上实时显示 MIDI 按下的音。
  final bool showLiveNote;

  /// 连接过的设备（按 lastAt 降序，「我的设备」与自动连接都用它）。
  final List<MidiDeviceRecord> savedMidiDevices;

  /// 最近一次连接的设备，自动连接的目标。
  MidiDeviceRecord? get lastMidiDevice {
    if (savedMidiDevices.isEmpty) return null;
    final sorted = [...savedMidiDevices]..sort((a, b) => b.lastAt.compareTo(a.lastAt));
    return sorted.first;
  }

  AppSettings copyWith({
    bool? soundEnabled,
    bool? vibrationEnabled,
    AnswerInput? answerInput,
    NoteNameStyle? noteNameStyle,
    ThemeMode? themeMode,
    int? midiTranspose,
    bool? autoFollowOctave,
    PitchNotation? pitchNotation,
    bool? midiAutoConnect,
    bool? showLiveNote,
    List<MidiDeviceRecord>? savedMidiDevices,
  }) {
    return AppSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      answerInput: answerInput ?? this.answerInput,
      noteNameStyle: noteNameStyle ?? this.noteNameStyle,
      themeMode: themeMode ?? this.themeMode,
      midiTranspose: midiTranspose ?? this.midiTranspose,
      autoFollowOctave: autoFollowOctave ?? this.autoFollowOctave,
      pitchNotation: pitchNotation ?? this.pitchNotation,
      midiAutoConnect: midiAutoConnect ?? this.midiAutoConnect,
      showLiveNote: showLiveNote ?? this.showLiveNote,
      savedMidiDevices: savedMidiDevices ?? this.savedMidiDevices,
    );
  }
}

/// 键名常量集中在这里，避免各处 hardcode 拼错导致静默读默认值。
abstract final class _Keys {
  static const sound = 'sound_enabled';
  static const vibration = 'vibration_enabled';
  static const answerInput = 'answer_mode';
  static const noteName = 'note_name_style';
  static const theme = 'theme_mode';
  static const transpose = 'midi_transpose';
  static const autoFollow = 'auto_follow_octave';
  static const pitchNotation = 'pitch_notation';
  static const midiAutoConnect = 'midi_auto_connect';
  static const showLiveNote = 'show_live_note';
  static const savedDevices = 'saved_midi_devices';
  // 旧版本的单设备字段，仅用于首次迁移
  static const legacyLastId = 'last_midi_device_id';
  static const legacyLastName = 'last_midi_device_name';
}

abstract final class SettingsStore {
  static Future<AppSettings> load() async {
    final p = await SharedPreferences.getInstance();
    return AppSettings(
      soundEnabled: p.getBool(_Keys.sound) ?? true,
      vibrationEnabled: p.getBool(_Keys.vibration) ?? true,
      answerInput: AnswerInput.values.firstWhere(
        (v) => v.name == p.getString(_Keys.answerInput),
        orElse: () => AnswerInput.keyboard,
      ),
      noteNameStyle: NoteNameStyle.values.firstWhere(
        (v) => v.name == p.getString(_Keys.noteName),
        orElse: () => NoteNameStyle.cde,
      ),
      themeMode: ThemeMode.values.firstWhere(
        (v) => v.name == p.getString(_Keys.theme),
        orElse: () => ThemeMode.system,
      ),
      midiTranspose: p.getInt(_Keys.transpose) ?? 0,
      autoFollowOctave: p.getBool(_Keys.autoFollow) ?? true,
      midiAutoConnect: p.getBool(_Keys.midiAutoConnect) ?? true,
      showLiveNote: p.getBool(_Keys.showLiveNote) ?? true,
      savedMidiDevices: _readDevices(p),
      pitchNotation: PitchNotation.values.firstWhere(
        (v) => v.name == p.getString(_Keys.pitchNotation),
        orElse: () => PitchNotation.chinese,
      ),
    );
  }

  static List<MidiDeviceRecord> _readDevices(SharedPreferences p) {
    final raw = p.getString(_Keys.savedDevices);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          final parsed = decoded
              .map(MidiDeviceRecord.tryParse)
              .whereType<MidiDeviceRecord>()
              .toList()
            ..sort((a, b) => b.lastAt.compareTo(a.lastAt));
          // 旧版本按 id 存，同一台琴会留下多条，按 stableKey 合并
          final seen = <String>{};
          return parsed.where((d) => seen.add(d.stableKey)).toList();
        }
      } catch (_) {
        // 数据损坏就当没有，避免整个设置读失败
      }
    }
    // 迁移旧版本的单设备字段
    final legacyId = p.getString(_Keys.legacyLastId);
    if (legacyId == null || legacyId.isEmpty) return const [];
    return [
      MidiDeviceRecord(
        id: legacyId,
        name: p.getString(_Keys.legacyLastName) ?? legacyId,
        kind: 'native',
        lastAt: 0,
      ),
    ];
  }

  static Future<void> save(AppSettings s) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_Keys.sound, s.soundEnabled);
    await p.setBool(_Keys.vibration, s.vibrationEnabled);
    await p.setString(_Keys.answerInput, s.answerInput.name);
    await p.setString(_Keys.noteName, s.noteNameStyle.name);
    await p.setString(_Keys.theme, s.themeMode.name);
    await p.setInt(_Keys.transpose, s.midiTranspose);
    await p.setBool(_Keys.autoFollow, s.autoFollowOctave);
    await p.setString(_Keys.pitchNotation, s.pitchNotation.name);
    await p.setBool(_Keys.midiAutoConnect, s.midiAutoConnect);
    await p.setBool(_Keys.showLiveNote, s.showLiveNote);
    await p.setString(
      _Keys.savedDevices,
      jsonEncode(s.savedMidiDevices.map((d) => d.toJson()).toList()),
    );
  }
}
