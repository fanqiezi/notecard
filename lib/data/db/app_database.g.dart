// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PracticeSessionTable extends PracticeSession
    with TableInfo<$PracticeSessionTable, PracticeSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PracticeSessionTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelIdMeta = const VerificationMeta(
    'levelId',
  );
  @override
  late final GeneratedColumn<String> levelId = GeneratedColumn<String>(
    'level_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<int> endedAt = GeneratedColumn<int>(
    'ended_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<int> total = GeneratedColumn<int>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _correctMeta = const VerificationMeta(
    'correct',
  );
  @override
  late final GeneratedColumn<int> correct = GeneratedColumn<int>(
    'correct',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avgReactionMsMeta = const VerificationMeta(
    'avgReactionMs',
  );
  @override
  late final GeneratedColumn<int> avgReactionMs = GeneratedColumn<int>(
    'avg_reaction_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mode,
    levelId,
    startedAt,
    endedAt,
    total,
    correct,
    avgReactionMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'practice_session';
  @override
  VerificationContext validateIntegrity(
    Insertable<PracticeSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('level_id')) {
      context.handle(
        _levelIdMeta,
        levelId.isAcceptableOrUnknown(data['level_id']!, _levelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_levelIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_endedAtMeta);
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('correct')) {
      context.handle(
        _correctMeta,
        correct.isAcceptableOrUnknown(data['correct']!, _correctMeta),
      );
    } else if (isInserting) {
      context.missing(_correctMeta);
    }
    if (data.containsKey('avg_reaction_ms')) {
      context.handle(
        _avgReactionMsMeta,
        avgReactionMs.isAcceptableOrUnknown(
          data['avg_reaction_ms']!,
          _avgReactionMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_avgReactionMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PracticeSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PracticeSessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      levelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ended_at'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total'],
      )!,
      correct: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct'],
      )!,
      avgReactionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}avg_reaction_ms'],
      )!,
    );
  }

  @override
  $PracticeSessionTable createAlias(String alias) {
    return $PracticeSessionTable(attachedDatabase, alias);
  }
}

class PracticeSessionRow extends DataClass
    implements Insertable<PracticeSessionRow> {
  final int id;

  /// count / timed / wrong
  final String mode;

  /// L1…L6 / wrong
  final String levelId;
  final int startedAt;
  final int endedAt;
  final int total;
  final int correct;
  final int avgReactionMs;
  const PracticeSessionRow({
    required this.id,
    required this.mode,
    required this.levelId,
    required this.startedAt,
    required this.endedAt,
    required this.total,
    required this.correct,
    required this.avgReactionMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['mode'] = Variable<String>(mode);
    map['level_id'] = Variable<String>(levelId);
    map['started_at'] = Variable<int>(startedAt);
    map['ended_at'] = Variable<int>(endedAt);
    map['total'] = Variable<int>(total);
    map['correct'] = Variable<int>(correct);
    map['avg_reaction_ms'] = Variable<int>(avgReactionMs);
    return map;
  }

  PracticeSessionCompanion toCompanion(bool nullToAbsent) {
    return PracticeSessionCompanion(
      id: Value(id),
      mode: Value(mode),
      levelId: Value(levelId),
      startedAt: Value(startedAt),
      endedAt: Value(endedAt),
      total: Value(total),
      correct: Value(correct),
      avgReactionMs: Value(avgReactionMs),
    );
  }

  factory PracticeSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PracticeSessionRow(
      id: serializer.fromJson<int>(json['id']),
      mode: serializer.fromJson<String>(json['mode']),
      levelId: serializer.fromJson<String>(json['levelId']),
      startedAt: serializer.fromJson<int>(json['startedAt']),
      endedAt: serializer.fromJson<int>(json['endedAt']),
      total: serializer.fromJson<int>(json['total']),
      correct: serializer.fromJson<int>(json['correct']),
      avgReactionMs: serializer.fromJson<int>(json['avgReactionMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mode': serializer.toJson<String>(mode),
      'levelId': serializer.toJson<String>(levelId),
      'startedAt': serializer.toJson<int>(startedAt),
      'endedAt': serializer.toJson<int>(endedAt),
      'total': serializer.toJson<int>(total),
      'correct': serializer.toJson<int>(correct),
      'avgReactionMs': serializer.toJson<int>(avgReactionMs),
    };
  }

  PracticeSessionRow copyWith({
    int? id,
    String? mode,
    String? levelId,
    int? startedAt,
    int? endedAt,
    int? total,
    int? correct,
    int? avgReactionMs,
  }) => PracticeSessionRow(
    id: id ?? this.id,
    mode: mode ?? this.mode,
    levelId: levelId ?? this.levelId,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt ?? this.endedAt,
    total: total ?? this.total,
    correct: correct ?? this.correct,
    avgReactionMs: avgReactionMs ?? this.avgReactionMs,
  );
  PracticeSessionRow copyWithCompanion(PracticeSessionCompanion data) {
    return PracticeSessionRow(
      id: data.id.present ? data.id.value : this.id,
      mode: data.mode.present ? data.mode.value : this.mode,
      levelId: data.levelId.present ? data.levelId.value : this.levelId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      total: data.total.present ? data.total.value : this.total,
      correct: data.correct.present ? data.correct.value : this.correct,
      avgReactionMs: data.avgReactionMs.present
          ? data.avgReactionMs.value
          : this.avgReactionMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PracticeSessionRow(')
          ..write('id: $id, ')
          ..write('mode: $mode, ')
          ..write('levelId: $levelId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('total: $total, ')
          ..write('correct: $correct, ')
          ..write('avgReactionMs: $avgReactionMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    mode,
    levelId,
    startedAt,
    endedAt,
    total,
    correct,
    avgReactionMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PracticeSessionRow &&
          other.id == this.id &&
          other.mode == this.mode &&
          other.levelId == this.levelId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.total == this.total &&
          other.correct == this.correct &&
          other.avgReactionMs == this.avgReactionMs);
}

class PracticeSessionCompanion extends UpdateCompanion<PracticeSessionRow> {
  final Value<int> id;
  final Value<String> mode;
  final Value<String> levelId;
  final Value<int> startedAt;
  final Value<int> endedAt;
  final Value<int> total;
  final Value<int> correct;
  final Value<int> avgReactionMs;
  const PracticeSessionCompanion({
    this.id = const Value.absent(),
    this.mode = const Value.absent(),
    this.levelId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.total = const Value.absent(),
    this.correct = const Value.absent(),
    this.avgReactionMs = const Value.absent(),
  });
  PracticeSessionCompanion.insert({
    this.id = const Value.absent(),
    required String mode,
    required String levelId,
    required int startedAt,
    required int endedAt,
    required int total,
    required int correct,
    required int avgReactionMs,
  }) : mode = Value(mode),
       levelId = Value(levelId),
       startedAt = Value(startedAt),
       endedAt = Value(endedAt),
       total = Value(total),
       correct = Value(correct),
       avgReactionMs = Value(avgReactionMs);
  static Insertable<PracticeSessionRow> custom({
    Expression<int>? id,
    Expression<String>? mode,
    Expression<String>? levelId,
    Expression<int>? startedAt,
    Expression<int>? endedAt,
    Expression<int>? total,
    Expression<int>? correct,
    Expression<int>? avgReactionMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mode != null) 'mode': mode,
      if (levelId != null) 'level_id': levelId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (total != null) 'total': total,
      if (correct != null) 'correct': correct,
      if (avgReactionMs != null) 'avg_reaction_ms': avgReactionMs,
    });
  }

  PracticeSessionCompanion copyWith({
    Value<int>? id,
    Value<String>? mode,
    Value<String>? levelId,
    Value<int>? startedAt,
    Value<int>? endedAt,
    Value<int>? total,
    Value<int>? correct,
    Value<int>? avgReactionMs,
  }) {
    return PracticeSessionCompanion(
      id: id ?? this.id,
      mode: mode ?? this.mode,
      levelId: levelId ?? this.levelId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      total: total ?? this.total,
      correct: correct ?? this.correct,
      avgReactionMs: avgReactionMs ?? this.avgReactionMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (levelId.present) {
      map['level_id'] = Variable<String>(levelId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<int>(endedAt.value);
    }
    if (total.present) {
      map['total'] = Variable<int>(total.value);
    }
    if (correct.present) {
      map['correct'] = Variable<int>(correct.value);
    }
    if (avgReactionMs.present) {
      map['avg_reaction_ms'] = Variable<int>(avgReactionMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PracticeSessionCompanion(')
          ..write('id: $id, ')
          ..write('mode: $mode, ')
          ..write('levelId: $levelId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('total: $total, ')
          ..write('correct: $correct, ')
          ..write('avgReactionMs: $avgReactionMs')
          ..write(')'))
        .toString();
  }
}

class $AnswerRecordTable extends AnswerRecord
    with TableInfo<$AnswerRecordTable, AnswerRecordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnswerRecordTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES practice_session (id)',
    ),
  );
  static const VerificationMeta _midiMeta = const VerificationMeta('midi');
  @override
  late final GeneratedColumn<int> midi = GeneratedColumn<int>(
    'midi',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clefMeta = const VerificationMeta('clef');
  @override
  late final GeneratedColumn<String> clef = GeneratedColumn<String>(
    'clef',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCorrectMeta = const VerificationMeta(
    'isCorrect',
  );
  @override
  late final GeneratedColumn<int> isCorrect = GeneratedColumn<int>(
    'is_correct',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isTimeoutMeta = const VerificationMeta(
    'isTimeout',
  );
  @override
  late final GeneratedColumn<int> isTimeout = GeneratedColumn<int>(
    'is_timeout',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _reactionMsMeta = const VerificationMeta(
    'reactionMs',
  );
  @override
  late final GeneratedColumn<int> reactionMs = GeneratedColumn<int>(
    'reaction_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _answeredAtMeta = const VerificationMeta(
    'answeredAt',
  );
  @override
  late final GeneratedColumn<int> answeredAt = GeneratedColumn<int>(
    'answered_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    midi,
    clef,
    source,
    isCorrect,
    isTimeout,
    reactionMs,
    answeredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'answer_record';
  @override
  VerificationContext validateIntegrity(
    Insertable<AnswerRecordRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('midi')) {
      context.handle(
        _midiMeta,
        midi.isAcceptableOrUnknown(data['midi']!, _midiMeta),
      );
    } else if (isInserting) {
      context.missing(_midiMeta);
    }
    if (data.containsKey('clef')) {
      context.handle(
        _clefMeta,
        clef.isAcceptableOrUnknown(data['clef']!, _clefMeta),
      );
    } else if (isInserting) {
      context.missing(_clefMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('is_correct')) {
      context.handle(
        _isCorrectMeta,
        isCorrect.isAcceptableOrUnknown(data['is_correct']!, _isCorrectMeta),
      );
    } else if (isInserting) {
      context.missing(_isCorrectMeta);
    }
    if (data.containsKey('is_timeout')) {
      context.handle(
        _isTimeoutMeta,
        isTimeout.isAcceptableOrUnknown(data['is_timeout']!, _isTimeoutMeta),
      );
    }
    if (data.containsKey('reaction_ms')) {
      context.handle(
        _reactionMsMeta,
        reactionMs.isAcceptableOrUnknown(data['reaction_ms']!, _reactionMsMeta),
      );
    } else if (isInserting) {
      context.missing(_reactionMsMeta);
    }
    if (data.containsKey('answered_at')) {
      context.handle(
        _answeredAtMeta,
        answeredAt.isAcceptableOrUnknown(data['answered_at']!, _answeredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_answeredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AnswerRecordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnswerRecordRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      midi: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}midi'],
      )!,
      clef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clef'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      isCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_correct'],
      )!,
      isTimeout: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_timeout'],
      )!,
      reactionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reaction_ms'],
      )!,
      answeredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}answered_at'],
      )!,
    );
  }

  @override
  $AnswerRecordTable createAlias(String alias) {
    return $AnswerRecordTable(attachedDatabase, alias);
  }
}

class AnswerRecordRow extends DataClass implements Insertable<AnswerRecordRow> {
  final int id;
  final int sessionId;
  final int midi;

  /// treble / bass
  final String clef;

  /// touch / midi / choice
  final String source;
  final int isCorrect;

  /// 超时单独记一列：结算页要区分「答错」与「超时」，且平均反应时间不含超时题。
  final int isTimeout;
  final int reactionMs;
  final int answeredAt;
  const AnswerRecordRow({
    required this.id,
    required this.sessionId,
    required this.midi,
    required this.clef,
    required this.source,
    required this.isCorrect,
    required this.isTimeout,
    required this.reactionMs,
    required this.answeredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['midi'] = Variable<int>(midi);
    map['clef'] = Variable<String>(clef);
    map['source'] = Variable<String>(source);
    map['is_correct'] = Variable<int>(isCorrect);
    map['is_timeout'] = Variable<int>(isTimeout);
    map['reaction_ms'] = Variable<int>(reactionMs);
    map['answered_at'] = Variable<int>(answeredAt);
    return map;
  }

  AnswerRecordCompanion toCompanion(bool nullToAbsent) {
    return AnswerRecordCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      midi: Value(midi),
      clef: Value(clef),
      source: Value(source),
      isCorrect: Value(isCorrect),
      isTimeout: Value(isTimeout),
      reactionMs: Value(reactionMs),
      answeredAt: Value(answeredAt),
    );
  }

  factory AnswerRecordRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnswerRecordRow(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      midi: serializer.fromJson<int>(json['midi']),
      clef: serializer.fromJson<String>(json['clef']),
      source: serializer.fromJson<String>(json['source']),
      isCorrect: serializer.fromJson<int>(json['isCorrect']),
      isTimeout: serializer.fromJson<int>(json['isTimeout']),
      reactionMs: serializer.fromJson<int>(json['reactionMs']),
      answeredAt: serializer.fromJson<int>(json['answeredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'midi': serializer.toJson<int>(midi),
      'clef': serializer.toJson<String>(clef),
      'source': serializer.toJson<String>(source),
      'isCorrect': serializer.toJson<int>(isCorrect),
      'isTimeout': serializer.toJson<int>(isTimeout),
      'reactionMs': serializer.toJson<int>(reactionMs),
      'answeredAt': serializer.toJson<int>(answeredAt),
    };
  }

  AnswerRecordRow copyWith({
    int? id,
    int? sessionId,
    int? midi,
    String? clef,
    String? source,
    int? isCorrect,
    int? isTimeout,
    int? reactionMs,
    int? answeredAt,
  }) => AnswerRecordRow(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    midi: midi ?? this.midi,
    clef: clef ?? this.clef,
    source: source ?? this.source,
    isCorrect: isCorrect ?? this.isCorrect,
    isTimeout: isTimeout ?? this.isTimeout,
    reactionMs: reactionMs ?? this.reactionMs,
    answeredAt: answeredAt ?? this.answeredAt,
  );
  AnswerRecordRow copyWithCompanion(AnswerRecordCompanion data) {
    return AnswerRecordRow(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      midi: data.midi.present ? data.midi.value : this.midi,
      clef: data.clef.present ? data.clef.value : this.clef,
      source: data.source.present ? data.source.value : this.source,
      isCorrect: data.isCorrect.present ? data.isCorrect.value : this.isCorrect,
      isTimeout: data.isTimeout.present ? data.isTimeout.value : this.isTimeout,
      reactionMs: data.reactionMs.present
          ? data.reactionMs.value
          : this.reactionMs,
      answeredAt: data.answeredAt.present
          ? data.answeredAt.value
          : this.answeredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnswerRecordRow(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('midi: $midi, ')
          ..write('clef: $clef, ')
          ..write('source: $source, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('isTimeout: $isTimeout, ')
          ..write('reactionMs: $reactionMs, ')
          ..write('answeredAt: $answeredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    midi,
    clef,
    source,
    isCorrect,
    isTimeout,
    reactionMs,
    answeredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnswerRecordRow &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.midi == this.midi &&
          other.clef == this.clef &&
          other.source == this.source &&
          other.isCorrect == this.isCorrect &&
          other.isTimeout == this.isTimeout &&
          other.reactionMs == this.reactionMs &&
          other.answeredAt == this.answeredAt);
}

class AnswerRecordCompanion extends UpdateCompanion<AnswerRecordRow> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<int> midi;
  final Value<String> clef;
  final Value<String> source;
  final Value<int> isCorrect;
  final Value<int> isTimeout;
  final Value<int> reactionMs;
  final Value<int> answeredAt;
  const AnswerRecordCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.midi = const Value.absent(),
    this.clef = const Value.absent(),
    this.source = const Value.absent(),
    this.isCorrect = const Value.absent(),
    this.isTimeout = const Value.absent(),
    this.reactionMs = const Value.absent(),
    this.answeredAt = const Value.absent(),
  });
  AnswerRecordCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required int midi,
    required String clef,
    required String source,
    required int isCorrect,
    this.isTimeout = const Value.absent(),
    required int reactionMs,
    required int answeredAt,
  }) : sessionId = Value(sessionId),
       midi = Value(midi),
       clef = Value(clef),
       source = Value(source),
       isCorrect = Value(isCorrect),
       reactionMs = Value(reactionMs),
       answeredAt = Value(answeredAt);
  static Insertable<AnswerRecordRow> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? midi,
    Expression<String>? clef,
    Expression<String>? source,
    Expression<int>? isCorrect,
    Expression<int>? isTimeout,
    Expression<int>? reactionMs,
    Expression<int>? answeredAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (midi != null) 'midi': midi,
      if (clef != null) 'clef': clef,
      if (source != null) 'source': source,
      if (isCorrect != null) 'is_correct': isCorrect,
      if (isTimeout != null) 'is_timeout': isTimeout,
      if (reactionMs != null) 'reaction_ms': reactionMs,
      if (answeredAt != null) 'answered_at': answeredAt,
    });
  }

  AnswerRecordCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<int>? midi,
    Value<String>? clef,
    Value<String>? source,
    Value<int>? isCorrect,
    Value<int>? isTimeout,
    Value<int>? reactionMs,
    Value<int>? answeredAt,
  }) {
    return AnswerRecordCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      midi: midi ?? this.midi,
      clef: clef ?? this.clef,
      source: source ?? this.source,
      isCorrect: isCorrect ?? this.isCorrect,
      isTimeout: isTimeout ?? this.isTimeout,
      reactionMs: reactionMs ?? this.reactionMs,
      answeredAt: answeredAt ?? this.answeredAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (midi.present) {
      map['midi'] = Variable<int>(midi.value);
    }
    if (clef.present) {
      map['clef'] = Variable<String>(clef.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (isCorrect.present) {
      map['is_correct'] = Variable<int>(isCorrect.value);
    }
    if (isTimeout.present) {
      map['is_timeout'] = Variable<int>(isTimeout.value);
    }
    if (reactionMs.present) {
      map['reaction_ms'] = Variable<int>(reactionMs.value);
    }
    if (answeredAt.present) {
      map['answered_at'] = Variable<int>(answeredAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnswerRecordCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('midi: $midi, ')
          ..write('clef: $clef, ')
          ..write('source: $source, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('isTimeout: $isTimeout, ')
          ..write('reactionMs: $reactionMs, ')
          ..write('answeredAt: $answeredAt')
          ..write(')'))
        .toString();
  }
}

class $WrongNoteTable extends WrongNote
    with TableInfo<$WrongNoteTable, WrongNoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WrongNoteTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _midiMeta = const VerificationMeta('midi');
  @override
  late final GeneratedColumn<int> midi = GeneratedColumn<int>(
    'midi',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clefMeta = const VerificationMeta('clef');
  @override
  late final GeneratedColumn<String> clef = GeneratedColumn<String>(
    'clef',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wrongCountMeta = const VerificationMeta(
    'wrongCount',
  );
  @override
  late final GeneratedColumn<int> wrongCount = GeneratedColumn<int>(
    'wrong_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rightStreakMeta = const VerificationMeta(
    'rightStreak',
  );
  @override
  late final GeneratedColumn<int> rightStreak = GeneratedColumn<int>(
    'right_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastWrongAtMeta = const VerificationMeta(
    'lastWrongAt',
  );
  @override
  late final GeneratedColumn<int> lastWrongAt = GeneratedColumn<int>(
    'last_wrong_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _masteredMeta = const VerificationMeta(
    'mastered',
  );
  @override
  late final GeneratedColumn<int> mastered = GeneratedColumn<int>(
    'mastered',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    midi,
    clef,
    wrongCount,
    rightStreak,
    lastWrongAt,
    mastered,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wrong_note';
  @override
  VerificationContext validateIntegrity(
    Insertable<WrongNoteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('midi')) {
      context.handle(
        _midiMeta,
        midi.isAcceptableOrUnknown(data['midi']!, _midiMeta),
      );
    } else if (isInserting) {
      context.missing(_midiMeta);
    }
    if (data.containsKey('clef')) {
      context.handle(
        _clefMeta,
        clef.isAcceptableOrUnknown(data['clef']!, _clefMeta),
      );
    } else if (isInserting) {
      context.missing(_clefMeta);
    }
    if (data.containsKey('wrong_count')) {
      context.handle(
        _wrongCountMeta,
        wrongCount.isAcceptableOrUnknown(data['wrong_count']!, _wrongCountMeta),
      );
    } else if (isInserting) {
      context.missing(_wrongCountMeta);
    }
    if (data.containsKey('right_streak')) {
      context.handle(
        _rightStreakMeta,
        rightStreak.isAcceptableOrUnknown(
          data['right_streak']!,
          _rightStreakMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rightStreakMeta);
    }
    if (data.containsKey('last_wrong_at')) {
      context.handle(
        _lastWrongAtMeta,
        lastWrongAt.isAcceptableOrUnknown(
          data['last_wrong_at']!,
          _lastWrongAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastWrongAtMeta);
    }
    if (data.containsKey('mastered')) {
      context.handle(
        _masteredMeta,
        mastered.isAcceptableOrUnknown(data['mastered']!, _masteredMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {midi, clef};
  @override
  WrongNoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WrongNoteRow(
      midi: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}midi'],
      )!,
      clef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clef'],
      )!,
      wrongCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wrong_count'],
      )!,
      rightStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}right_streak'],
      )!,
      lastWrongAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_wrong_at'],
      )!,
      mastered: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mastered'],
      )!,
    );
  }

  @override
  $WrongNoteTable createAlias(String alias) {
    return $WrongNoteTable(attachedDatabase, alias);
  }
}

class WrongNoteRow extends DataClass implements Insertable<WrongNoteRow> {
  final int midi;
  final String clef;
  final int wrongCount;
  final int rightStreak;
  final int lastWrongAt;
  final int mastered;
  const WrongNoteRow({
    required this.midi,
    required this.clef,
    required this.wrongCount,
    required this.rightStreak,
    required this.lastWrongAt,
    required this.mastered,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['midi'] = Variable<int>(midi);
    map['clef'] = Variable<String>(clef);
    map['wrong_count'] = Variable<int>(wrongCount);
    map['right_streak'] = Variable<int>(rightStreak);
    map['last_wrong_at'] = Variable<int>(lastWrongAt);
    map['mastered'] = Variable<int>(mastered);
    return map;
  }

  WrongNoteCompanion toCompanion(bool nullToAbsent) {
    return WrongNoteCompanion(
      midi: Value(midi),
      clef: Value(clef),
      wrongCount: Value(wrongCount),
      rightStreak: Value(rightStreak),
      lastWrongAt: Value(lastWrongAt),
      mastered: Value(mastered),
    );
  }

  factory WrongNoteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WrongNoteRow(
      midi: serializer.fromJson<int>(json['midi']),
      clef: serializer.fromJson<String>(json['clef']),
      wrongCount: serializer.fromJson<int>(json['wrongCount']),
      rightStreak: serializer.fromJson<int>(json['rightStreak']),
      lastWrongAt: serializer.fromJson<int>(json['lastWrongAt']),
      mastered: serializer.fromJson<int>(json['mastered']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'midi': serializer.toJson<int>(midi),
      'clef': serializer.toJson<String>(clef),
      'wrongCount': serializer.toJson<int>(wrongCount),
      'rightStreak': serializer.toJson<int>(rightStreak),
      'lastWrongAt': serializer.toJson<int>(lastWrongAt),
      'mastered': serializer.toJson<int>(mastered),
    };
  }

  WrongNoteRow copyWith({
    int? midi,
    String? clef,
    int? wrongCount,
    int? rightStreak,
    int? lastWrongAt,
    int? mastered,
  }) => WrongNoteRow(
    midi: midi ?? this.midi,
    clef: clef ?? this.clef,
    wrongCount: wrongCount ?? this.wrongCount,
    rightStreak: rightStreak ?? this.rightStreak,
    lastWrongAt: lastWrongAt ?? this.lastWrongAt,
    mastered: mastered ?? this.mastered,
  );
  WrongNoteRow copyWithCompanion(WrongNoteCompanion data) {
    return WrongNoteRow(
      midi: data.midi.present ? data.midi.value : this.midi,
      clef: data.clef.present ? data.clef.value : this.clef,
      wrongCount: data.wrongCount.present
          ? data.wrongCount.value
          : this.wrongCount,
      rightStreak: data.rightStreak.present
          ? data.rightStreak.value
          : this.rightStreak,
      lastWrongAt: data.lastWrongAt.present
          ? data.lastWrongAt.value
          : this.lastWrongAt,
      mastered: data.mastered.present ? data.mastered.value : this.mastered,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WrongNoteRow(')
          ..write('midi: $midi, ')
          ..write('clef: $clef, ')
          ..write('wrongCount: $wrongCount, ')
          ..write('rightStreak: $rightStreak, ')
          ..write('lastWrongAt: $lastWrongAt, ')
          ..write('mastered: $mastered')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(midi, clef, wrongCount, rightStreak, lastWrongAt, mastered);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WrongNoteRow &&
          other.midi == this.midi &&
          other.clef == this.clef &&
          other.wrongCount == this.wrongCount &&
          other.rightStreak == this.rightStreak &&
          other.lastWrongAt == this.lastWrongAt &&
          other.mastered == this.mastered);
}

class WrongNoteCompanion extends UpdateCompanion<WrongNoteRow> {
  final Value<int> midi;
  final Value<String> clef;
  final Value<int> wrongCount;
  final Value<int> rightStreak;
  final Value<int> lastWrongAt;
  final Value<int> mastered;
  final Value<int> rowid;
  const WrongNoteCompanion({
    this.midi = const Value.absent(),
    this.clef = const Value.absent(),
    this.wrongCount = const Value.absent(),
    this.rightStreak = const Value.absent(),
    this.lastWrongAt = const Value.absent(),
    this.mastered = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WrongNoteCompanion.insert({
    required int midi,
    required String clef,
    required int wrongCount,
    required int rightStreak,
    required int lastWrongAt,
    this.mastered = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : midi = Value(midi),
       clef = Value(clef),
       wrongCount = Value(wrongCount),
       rightStreak = Value(rightStreak),
       lastWrongAt = Value(lastWrongAt);
  static Insertable<WrongNoteRow> custom({
    Expression<int>? midi,
    Expression<String>? clef,
    Expression<int>? wrongCount,
    Expression<int>? rightStreak,
    Expression<int>? lastWrongAt,
    Expression<int>? mastered,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (midi != null) 'midi': midi,
      if (clef != null) 'clef': clef,
      if (wrongCount != null) 'wrong_count': wrongCount,
      if (rightStreak != null) 'right_streak': rightStreak,
      if (lastWrongAt != null) 'last_wrong_at': lastWrongAt,
      if (mastered != null) 'mastered': mastered,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WrongNoteCompanion copyWith({
    Value<int>? midi,
    Value<String>? clef,
    Value<int>? wrongCount,
    Value<int>? rightStreak,
    Value<int>? lastWrongAt,
    Value<int>? mastered,
    Value<int>? rowid,
  }) {
    return WrongNoteCompanion(
      midi: midi ?? this.midi,
      clef: clef ?? this.clef,
      wrongCount: wrongCount ?? this.wrongCount,
      rightStreak: rightStreak ?? this.rightStreak,
      lastWrongAt: lastWrongAt ?? this.lastWrongAt,
      mastered: mastered ?? this.mastered,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (midi.present) {
      map['midi'] = Variable<int>(midi.value);
    }
    if (clef.present) {
      map['clef'] = Variable<String>(clef.value);
    }
    if (wrongCount.present) {
      map['wrong_count'] = Variable<int>(wrongCount.value);
    }
    if (rightStreak.present) {
      map['right_streak'] = Variable<int>(rightStreak.value);
    }
    if (lastWrongAt.present) {
      map['last_wrong_at'] = Variable<int>(lastWrongAt.value);
    }
    if (mastered.present) {
      map['mastered'] = Variable<int>(mastered.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WrongNoteCompanion(')
          ..write('midi: $midi, ')
          ..write('clef: $clef, ')
          ..write('wrongCount: $wrongCount, ')
          ..write('rightStreak: $rightStreak, ')
          ..write('lastWrongAt: $lastWrongAt, ')
          ..write('mastered: $mastered, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PracticeSessionTable practiceSession = $PracticeSessionTable(
    this,
  );
  late final $AnswerRecordTable answerRecord = $AnswerRecordTable(this);
  late final $WrongNoteTable wrongNote = $WrongNoteTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    practiceSession,
    answerRecord,
    wrongNote,
  ];
}

typedef $$PracticeSessionTableCreateCompanionBuilder =
    PracticeSessionCompanion Function({
      Value<int> id,
      required String mode,
      required String levelId,
      required int startedAt,
      required int endedAt,
      required int total,
      required int correct,
      required int avgReactionMs,
    });
typedef $$PracticeSessionTableUpdateCompanionBuilder =
    PracticeSessionCompanion Function({
      Value<int> id,
      Value<String> mode,
      Value<String> levelId,
      Value<int> startedAt,
      Value<int> endedAt,
      Value<int> total,
      Value<int> correct,
      Value<int> avgReactionMs,
    });

final class $$PracticeSessionTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PracticeSessionTable,
          PracticeSessionRow
        > {
  $$PracticeSessionTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$AnswerRecordTable, List<AnswerRecordRow>>
  _answerRecordRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.answerRecord,
    aliasName: 'practice_session__id__answer_record__session_id',
  );

  $$AnswerRecordTableProcessedTableManager get answerRecordRefs {
    final manager = $$AnswerRecordTableTableManager(
      $_db,
      $_db.answerRecord,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_answerRecordRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PracticeSessionTableFilterComposer
    extends Composer<_$AppDatabase, $PracticeSessionTable> {
  $$PracticeSessionTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get levelId => $composableBuilder(
    column: $table.levelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correct => $composableBuilder(
    column: $table.correct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get avgReactionMs => $composableBuilder(
    column: $table.avgReactionMs,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> answerRecordRefs(
    Expression<bool> Function($$AnswerRecordTableFilterComposer f) f,
  ) {
    final $$AnswerRecordTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.answerRecord,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AnswerRecordTableFilterComposer(
            $db: $db,
            $table: $db.answerRecord,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PracticeSessionTableOrderingComposer
    extends Composer<_$AppDatabase, $PracticeSessionTable> {
  $$PracticeSessionTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get levelId => $composableBuilder(
    column: $table.levelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correct => $composableBuilder(
    column: $table.correct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get avgReactionMs => $composableBuilder(
    column: $table.avgReactionMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PracticeSessionTableAnnotationComposer
    extends Composer<_$AppDatabase, $PracticeSessionTable> {
  $$PracticeSessionTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get levelId =>
      $composableBuilder(column: $table.levelId, builder: (column) => column);

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<int> get correct =>
      $composableBuilder(column: $table.correct, builder: (column) => column);

  GeneratedColumn<int> get avgReactionMs => $composableBuilder(
    column: $table.avgReactionMs,
    builder: (column) => column,
  );

  Expression<T> answerRecordRefs<T extends Object>(
    Expression<T> Function($$AnswerRecordTableAnnotationComposer a) f,
  ) {
    final $$AnswerRecordTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.answerRecord,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AnswerRecordTableAnnotationComposer(
            $db: $db,
            $table: $db.answerRecord,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PracticeSessionTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PracticeSessionTable,
          PracticeSessionRow,
          $$PracticeSessionTableFilterComposer,
          $$PracticeSessionTableOrderingComposer,
          $$PracticeSessionTableAnnotationComposer,
          $$PracticeSessionTableCreateCompanionBuilder,
          $$PracticeSessionTableUpdateCompanionBuilder,
          (PracticeSessionRow, $$PracticeSessionTableReferences),
          PracticeSessionRow,
          PrefetchHooks Function({bool answerRecordRefs})
        > {
  $$PracticeSessionTableTableManager(
    _$AppDatabase db,
    $PracticeSessionTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PracticeSessionTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PracticeSessionTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PracticeSessionTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String> levelId = const Value.absent(),
                Value<int> startedAt = const Value.absent(),
                Value<int> endedAt = const Value.absent(),
                Value<int> total = const Value.absent(),
                Value<int> correct = const Value.absent(),
                Value<int> avgReactionMs = const Value.absent(),
              }) => PracticeSessionCompanion(
                id: id,
                mode: mode,
                levelId: levelId,
                startedAt: startedAt,
                endedAt: endedAt,
                total: total,
                correct: correct,
                avgReactionMs: avgReactionMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String mode,
                required String levelId,
                required int startedAt,
                required int endedAt,
                required int total,
                required int correct,
                required int avgReactionMs,
              }) => PracticeSessionCompanion.insert(
                id: id,
                mode: mode,
                levelId: levelId,
                startedAt: startedAt,
                endedAt: endedAt,
                total: total,
                correct: correct,
                avgReactionMs: avgReactionMs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PracticeSessionTable, PracticeSessionRow>(table),
                  $$PracticeSessionTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({answerRecordRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (answerRecordRefs) db.answerRecord],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (answerRecordRefs)
                    await $_getPrefetchedDataByColumns<
                      PracticeSessionRow,
                      $PracticeSessionTable,
                      AnswerRecordRow,
                      $AnswerRecordTable
                    >(
                      currentTable: table,
                      referencedTable: $$PracticeSessionTableReferences
                          ._answerRecordRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PracticeSessionTableReferences(
                            db,
                            table,
                            p0,
                          ).answerRecordRefs,
                      currentColumn: 'id',
                      referencedColumn: 'session_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PracticeSessionTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PracticeSessionTable,
      PracticeSessionRow,
      $$PracticeSessionTableFilterComposer,
      $$PracticeSessionTableOrderingComposer,
      $$PracticeSessionTableAnnotationComposer,
      $$PracticeSessionTableCreateCompanionBuilder,
      $$PracticeSessionTableUpdateCompanionBuilder,
      (PracticeSessionRow, $$PracticeSessionTableReferences),
      PracticeSessionRow,
      PrefetchHooks Function({bool answerRecordRefs})
    >;
typedef $$AnswerRecordTableCreateCompanionBuilder =
    AnswerRecordCompanion Function({
      Value<int> id,
      required int sessionId,
      required int midi,
      required String clef,
      required String source,
      required int isCorrect,
      Value<int> isTimeout,
      required int reactionMs,
      required int answeredAt,
    });
typedef $$AnswerRecordTableUpdateCompanionBuilder =
    AnswerRecordCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<int> midi,
      Value<String> clef,
      Value<String> source,
      Value<int> isCorrect,
      Value<int> isTimeout,
      Value<int> reactionMs,
      Value<int> answeredAt,
    });

final class $$AnswerRecordTableReferences
    extends BaseReferences<_$AppDatabase, $AnswerRecordTable, AnswerRecordRow> {
  $$AnswerRecordTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PracticeSessionTable _sessionIdTable(_$AppDatabase db) => db
      .practiceSession
      .createAlias('answer_record__session_id__practice_session__id');

  $$PracticeSessionTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$PracticeSessionTableTableManager(
      $_db,
      $_db.practiceSession,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AnswerRecordTableFilterComposer
    extends Composer<_$AppDatabase, $AnswerRecordTable> {
  $$AnswerRecordTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get midi => $composableBuilder(
    column: $table.midi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clef => $composableBuilder(
    column: $table.clef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isTimeout => $composableBuilder(
    column: $table.isTimeout,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reactionMs => $composableBuilder(
    column: $table.reactionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PracticeSessionTableFilterComposer get sessionId {
    final $$PracticeSessionTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSession,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionTableFilterComposer(
            $db: $db,
            $table: $db.practiceSession,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AnswerRecordTableOrderingComposer
    extends Composer<_$AppDatabase, $AnswerRecordTable> {
  $$AnswerRecordTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get midi => $composableBuilder(
    column: $table.midi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clef => $composableBuilder(
    column: $table.clef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isTimeout => $composableBuilder(
    column: $table.isTimeout,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reactionMs => $composableBuilder(
    column: $table.reactionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PracticeSessionTableOrderingComposer get sessionId {
    final $$PracticeSessionTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSession,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionTableOrderingComposer(
            $db: $db,
            $table: $db.practiceSession,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AnswerRecordTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnswerRecordTable> {
  $$AnswerRecordTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get midi =>
      $composableBuilder(column: $table.midi, builder: (column) => column);

  GeneratedColumn<String> get clef =>
      $composableBuilder(column: $table.clef, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get isCorrect =>
      $composableBuilder(column: $table.isCorrect, builder: (column) => column);

  GeneratedColumn<int> get isTimeout =>
      $composableBuilder(column: $table.isTimeout, builder: (column) => column);

  GeneratedColumn<int> get reactionMs => $composableBuilder(
    column: $table.reactionMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => column,
  );

  $$PracticeSessionTableAnnotationComposer get sessionId {
    final $$PracticeSessionTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSession,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionTableAnnotationComposer(
            $db: $db,
            $table: $db.practiceSession,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AnswerRecordTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AnswerRecordTable,
          AnswerRecordRow,
          $$AnswerRecordTableFilterComposer,
          $$AnswerRecordTableOrderingComposer,
          $$AnswerRecordTableAnnotationComposer,
          $$AnswerRecordTableCreateCompanionBuilder,
          $$AnswerRecordTableUpdateCompanionBuilder,
          (AnswerRecordRow, $$AnswerRecordTableReferences),
          AnswerRecordRow,
          PrefetchHooks Function({bool sessionId})
        > {
  $$AnswerRecordTableTableManager(_$AppDatabase db, $AnswerRecordTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnswerRecordTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnswerRecordTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnswerRecordTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<int> midi = const Value.absent(),
                Value<String> clef = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> isCorrect = const Value.absent(),
                Value<int> isTimeout = const Value.absent(),
                Value<int> reactionMs = const Value.absent(),
                Value<int> answeredAt = const Value.absent(),
              }) => AnswerRecordCompanion(
                id: id,
                sessionId: sessionId,
                midi: midi,
                clef: clef,
                source: source,
                isCorrect: isCorrect,
                isTimeout: isTimeout,
                reactionMs: reactionMs,
                answeredAt: answeredAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required int midi,
                required String clef,
                required String source,
                required int isCorrect,
                Value<int> isTimeout = const Value.absent(),
                required int reactionMs,
                required int answeredAt,
              }) => AnswerRecordCompanion.insert(
                id: id,
                sessionId: sessionId,
                midi: midi,
                clef: clef,
                source: source,
                isCorrect: isCorrect,
                isTimeout: isTimeout,
                reactionMs: reactionMs,
                answeredAt: answeredAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AnswerRecordTable, AnswerRecordRow>(table),
                  $$AnswerRecordTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$AnswerRecordTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$AnswerRecordTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AnswerRecordTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AnswerRecordTable,
      AnswerRecordRow,
      $$AnswerRecordTableFilterComposer,
      $$AnswerRecordTableOrderingComposer,
      $$AnswerRecordTableAnnotationComposer,
      $$AnswerRecordTableCreateCompanionBuilder,
      $$AnswerRecordTableUpdateCompanionBuilder,
      (AnswerRecordRow, $$AnswerRecordTableReferences),
      AnswerRecordRow,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$WrongNoteTableCreateCompanionBuilder = WrongNoteCompanion Function({
  required int midi,
  required String clef,
  required int wrongCount,
  required int rightStreak,
  required int lastWrongAt,
  Value<int> mastered,
  Value<int> rowid,
});
typedef $$WrongNoteTableUpdateCompanionBuilder = WrongNoteCompanion Function({
  Value<int> midi,
  Value<String> clef,
  Value<int> wrongCount,
  Value<int> rightStreak,
  Value<int> lastWrongAt,
  Value<int> mastered,
  Value<int> rowid,
});

class $$WrongNoteTableFilterComposer
    extends Composer<_$AppDatabase, $WrongNoteTable> {
  $$WrongNoteTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get midi => $composableBuilder(
    column: $table.midi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clef => $composableBuilder(
    column: $table.clef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wrongCount => $composableBuilder(
    column: $table.wrongCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rightStreak => $composableBuilder(
    column: $table.rightStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastWrongAt => $composableBuilder(
    column: $table.lastWrongAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mastered => $composableBuilder(
    column: $table.mastered,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WrongNoteTableOrderingComposer
    extends Composer<_$AppDatabase, $WrongNoteTable> {
  $$WrongNoteTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get midi => $composableBuilder(
    column: $table.midi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clef => $composableBuilder(
    column: $table.clef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wrongCount => $composableBuilder(
    column: $table.wrongCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rightStreak => $composableBuilder(
    column: $table.rightStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastWrongAt => $composableBuilder(
    column: $table.lastWrongAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mastered => $composableBuilder(
    column: $table.mastered,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WrongNoteTableAnnotationComposer
    extends Composer<_$AppDatabase, $WrongNoteTable> {
  $$WrongNoteTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get midi =>
      $composableBuilder(column: $table.midi, builder: (column) => column);

  GeneratedColumn<String> get clef =>
      $composableBuilder(column: $table.clef, builder: (column) => column);

  GeneratedColumn<int> get wrongCount => $composableBuilder(
    column: $table.wrongCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rightStreak => $composableBuilder(
    column: $table.rightStreak,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastWrongAt => $composableBuilder(
    column: $table.lastWrongAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get mastered =>
      $composableBuilder(column: $table.mastered, builder: (column) => column);
}

class $$WrongNoteTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WrongNoteTable,
          WrongNoteRow,
          $$WrongNoteTableFilterComposer,
          $$WrongNoteTableOrderingComposer,
          $$WrongNoteTableAnnotationComposer,
          $$WrongNoteTableCreateCompanionBuilder,
          $$WrongNoteTableUpdateCompanionBuilder,
          (
            WrongNoteRow,
            BaseReferences<_$AppDatabase, $WrongNoteTable, WrongNoteRow>,
          ),
          WrongNoteRow,
          PrefetchHooks Function()
        > {
  $$WrongNoteTableTableManager(_$AppDatabase db, $WrongNoteTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WrongNoteTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WrongNoteTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WrongNoteTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> midi = const Value.absent(),
                Value<String> clef = const Value.absent(),
                Value<int> wrongCount = const Value.absent(),
                Value<int> rightStreak = const Value.absent(),
                Value<int> lastWrongAt = const Value.absent(),
                Value<int> mastered = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WrongNoteCompanion(
                midi: midi,
                clef: clef,
                wrongCount: wrongCount,
                rightStreak: rightStreak,
                lastWrongAt: lastWrongAt,
                mastered: mastered,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int midi,
                required String clef,
                required int wrongCount,
                required int rightStreak,
                required int lastWrongAt,
                Value<int> mastered = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WrongNoteCompanion.insert(
                midi: midi,
                clef: clef,
                wrongCount: wrongCount,
                rightStreak: rightStreak,
                lastWrongAt: lastWrongAt,
                mastered: mastered,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WrongNoteTable, WrongNoteRow>(table),
                  BaseReferences<_$AppDatabase, $WrongNoteTable, WrongNoteRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WrongNoteTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WrongNoteTable,
      WrongNoteRow,
      $$WrongNoteTableFilterComposer,
      $$WrongNoteTableOrderingComposer,
      $$WrongNoteTableAnnotationComposer,
      $$WrongNoteTableCreateCompanionBuilder,
      $$WrongNoteTableUpdateCompanionBuilder,
      (
        WrongNoteRow,
        BaseReferences<_$AppDatabase, $WrongNoteTable, WrongNoteRow>,
      ),
      WrongNoteRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PracticeSessionTableTableManager get practiceSession =>
      $$PracticeSessionTableTableManager(_db, _db.practiceSession);
  $$AnswerRecordTableTableManager get answerRecord =>
      $$AnswerRecordTableTableManager(_db, _db.answerRecord);
  $$WrongNoteTableTableManager get wrongNote =>
      $$WrongNoteTableTableManager(_db, _db.wrongNote);
}
