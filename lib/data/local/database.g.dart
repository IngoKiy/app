// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ProjectsTable extends Projects
    with TableInfo<$ProjectsTable, ProjectRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<int> remoteId = GeneratedColumn<int>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _updatedAtServerMeta = const VerificationMeta(
    'updatedAtServer',
  );
  @override
  late final GeneratedColumn<String> updatedAtServer = GeneratedColumn<String>(
    'updated_at_server',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<String> syncedAt = GeneratedColumn<String>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _parentProjectIdMeta = const VerificationMeta(
    'parentProjectId',
  );
  @override
  late final GeneratedColumn<int> parentProjectId = GeneratedColumn<int>(
    'parent_project_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<double> position = GeneratedColumn<double>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isFavouriteMeta = const VerificationMeta(
    'isFavourite',
  );
  @override
  late final GeneratedColumn<bool> isFavourite = GeneratedColumn<bool>(
    'is_favourite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favourite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hexColorMeta = const VerificationMeta(
    'hexColor',
  );
  @override
  late final GeneratedColumn<String> hexColor = GeneratedColumn<String>(
    'hex_color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _viewsJsonMeta = const VerificationMeta(
    'viewsJson',
  );
  @override
  late final GeneratedColumn<String> viewsJson = GeneratedColumn<String>(
    'views_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _ownerJsonMeta = const VerificationMeta(
    'ownerJson',
  );
  @override
  late final GeneratedColumn<String> ownerJson = GeneratedColumn<String>(
    'owner_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawJsonMeta = const VerificationMeta(
    'rawJson',
  );
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
    'raw_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    remoteId,
    updatedAtServer,
    isDirty,
    isDeleted,
    syncedAt,
    id,
    title,
    description,
    parentProjectId,
    position,
    isFavourite,
    hexColor,
    viewsJson,
    ownerJson,
    rawJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProjectRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('updated_at_server')) {
      context.handle(
        _updatedAtServerMeta,
        updatedAtServer.isAcceptableOrUnknown(
          data['updated_at_server']!,
          _updatedAtServerMeta,
        ),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('parent_project_id')) {
      context.handle(
        _parentProjectIdMeta,
        parentProjectId.isAcceptableOrUnknown(
          data['parent_project_id']!,
          _parentProjectIdMeta,
        ),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('is_favourite')) {
      context.handle(
        _isFavouriteMeta,
        isFavourite.isAcceptableOrUnknown(
          data['is_favourite']!,
          _isFavouriteMeta,
        ),
      );
    }
    if (data.containsKey('hex_color')) {
      context.handle(
        _hexColorMeta,
        hexColor.isAcceptableOrUnknown(data['hex_color']!, _hexColorMeta),
      );
    }
    if (data.containsKey('views_json')) {
      context.handle(
        _viewsJsonMeta,
        viewsJson.isAcceptableOrUnknown(data['views_json']!, _viewsJsonMeta),
      );
    }
    if (data.containsKey('owner_json')) {
      context.handle(
        _ownerJsonMeta,
        ownerJson.isAcceptableOrUnknown(data['owner_json']!, _ownerJsonMeta),
      );
    }
    if (data.containsKey('raw_json')) {
      context.handle(
        _rawJsonMeta,
        rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_rawJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProjectRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectRow(
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remote_id'],
      ),
      updatedAtServer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_server'],
      ),
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      parentProjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_project_id'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}position'],
      )!,
      isFavourite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favourite'],
      )!,
      hexColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hex_color'],
      ),
      viewsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}views_json'],
      )!,
      ownerJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_json'],
      ),
      rawJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_json'],
      )!,
    );
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }
}

class ProjectRow extends DataClass implements Insertable<ProjectRow> {
  final int? remoteId;
  final String? updatedAtServer;
  final bool isDirty;
  final bool isDeleted;
  final String? syncedAt;
  final int id;
  final String title;
  final String description;
  final int? parentProjectId;
  final double position;
  final bool isFavourite;
  final String? hexColor;

  /// JSON-Array der ProjectView-DTOs.
  final String viewsJson;
  final String? ownerJson;

  /// Komplettes ProjectDto-JSON als Fallback für Felder ohne eigene Spalte.
  final String rawJson;
  const ProjectRow({
    this.remoteId,
    this.updatedAtServer,
    required this.isDirty,
    required this.isDeleted,
    this.syncedAt,
    required this.id,
    required this.title,
    required this.description,
    this.parentProjectId,
    required this.position,
    required this.isFavourite,
    this.hexColor,
    required this.viewsJson,
    this.ownerJson,
    required this.rawJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<int>(remoteId);
    }
    if (!nullToAbsent || updatedAtServer != null) {
      map['updated_at_server'] = Variable<String>(updatedAtServer);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<String>(syncedAt);
    }
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || parentProjectId != null) {
      map['parent_project_id'] = Variable<int>(parentProjectId);
    }
    map['position'] = Variable<double>(position);
    map['is_favourite'] = Variable<bool>(isFavourite);
    if (!nullToAbsent || hexColor != null) {
      map['hex_color'] = Variable<String>(hexColor);
    }
    map['views_json'] = Variable<String>(viewsJson);
    if (!nullToAbsent || ownerJson != null) {
      map['owner_json'] = Variable<String>(ownerJson);
    }
    map['raw_json'] = Variable<String>(rawJson);
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      updatedAtServer: updatedAtServer == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAtServer),
      isDirty: Value(isDirty),
      isDeleted: Value(isDeleted),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      id: Value(id),
      title: Value(title),
      description: Value(description),
      parentProjectId: parentProjectId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentProjectId),
      position: Value(position),
      isFavourite: Value(isFavourite),
      hexColor: hexColor == null && nullToAbsent
          ? const Value.absent()
          : Value(hexColor),
      viewsJson: Value(viewsJson),
      ownerJson: ownerJson == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerJson),
      rawJson: Value(rawJson),
    );
  }

  factory ProjectRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectRow(
      remoteId: serializer.fromJson<int?>(json['remoteId']),
      updatedAtServer: serializer.fromJson<String?>(json['updatedAtServer']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      syncedAt: serializer.fromJson<String?>(json['syncedAt']),
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      parentProjectId: serializer.fromJson<int?>(json['parentProjectId']),
      position: serializer.fromJson<double>(json['position']),
      isFavourite: serializer.fromJson<bool>(json['isFavourite']),
      hexColor: serializer.fromJson<String?>(json['hexColor']),
      viewsJson: serializer.fromJson<String>(json['viewsJson']),
      ownerJson: serializer.fromJson<String?>(json['ownerJson']),
      rawJson: serializer.fromJson<String>(json['rawJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'remoteId': serializer.toJson<int?>(remoteId),
      'updatedAtServer': serializer.toJson<String?>(updatedAtServer),
      'isDirty': serializer.toJson<bool>(isDirty),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'syncedAt': serializer.toJson<String?>(syncedAt),
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'parentProjectId': serializer.toJson<int?>(parentProjectId),
      'position': serializer.toJson<double>(position),
      'isFavourite': serializer.toJson<bool>(isFavourite),
      'hexColor': serializer.toJson<String?>(hexColor),
      'viewsJson': serializer.toJson<String>(viewsJson),
      'ownerJson': serializer.toJson<String?>(ownerJson),
      'rawJson': serializer.toJson<String>(rawJson),
    };
  }

  ProjectRow copyWith({
    Value<int?> remoteId = const Value.absent(),
    Value<String?> updatedAtServer = const Value.absent(),
    bool? isDirty,
    bool? isDeleted,
    Value<String?> syncedAt = const Value.absent(),
    int? id,
    String? title,
    String? description,
    Value<int?> parentProjectId = const Value.absent(),
    double? position,
    bool? isFavourite,
    Value<String?> hexColor = const Value.absent(),
    String? viewsJson,
    Value<String?> ownerJson = const Value.absent(),
    String? rawJson,
  }) => ProjectRow(
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    updatedAtServer: updatedAtServer.present
        ? updatedAtServer.value
        : this.updatedAtServer,
    isDirty: isDirty ?? this.isDirty,
    isDeleted: isDeleted ?? this.isDeleted,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    parentProjectId: parentProjectId.present
        ? parentProjectId.value
        : this.parentProjectId,
    position: position ?? this.position,
    isFavourite: isFavourite ?? this.isFavourite,
    hexColor: hexColor.present ? hexColor.value : this.hexColor,
    viewsJson: viewsJson ?? this.viewsJson,
    ownerJson: ownerJson.present ? ownerJson.value : this.ownerJson,
    rawJson: rawJson ?? this.rawJson,
  );
  ProjectRow copyWithCompanion(ProjectsCompanion data) {
    return ProjectRow(
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      updatedAtServer: data.updatedAtServer.present
          ? data.updatedAtServer.value
          : this.updatedAtServer,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      parentProjectId: data.parentProjectId.present
          ? data.parentProjectId.value
          : this.parentProjectId,
      position: data.position.present ? data.position.value : this.position,
      isFavourite: data.isFavourite.present
          ? data.isFavourite.value
          : this.isFavourite,
      hexColor: data.hexColor.present ? data.hexColor.value : this.hexColor,
      viewsJson: data.viewsJson.present ? data.viewsJson.value : this.viewsJson,
      ownerJson: data.ownerJson.present ? data.ownerJson.value : this.ownerJson,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectRow(')
          ..write('remoteId: $remoteId, ')
          ..write('updatedAtServer: $updatedAtServer, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('parentProjectId: $parentProjectId, ')
          ..write('position: $position, ')
          ..write('isFavourite: $isFavourite, ')
          ..write('hexColor: $hexColor, ')
          ..write('viewsJson: $viewsJson, ')
          ..write('ownerJson: $ownerJson, ')
          ..write('rawJson: $rawJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    remoteId,
    updatedAtServer,
    isDirty,
    isDeleted,
    syncedAt,
    id,
    title,
    description,
    parentProjectId,
    position,
    isFavourite,
    hexColor,
    viewsJson,
    ownerJson,
    rawJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectRow &&
          other.remoteId == this.remoteId &&
          other.updatedAtServer == this.updatedAtServer &&
          other.isDirty == this.isDirty &&
          other.isDeleted == this.isDeleted &&
          other.syncedAt == this.syncedAt &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.parentProjectId == this.parentProjectId &&
          other.position == this.position &&
          other.isFavourite == this.isFavourite &&
          other.hexColor == this.hexColor &&
          other.viewsJson == this.viewsJson &&
          other.ownerJson == this.ownerJson &&
          other.rawJson == this.rawJson);
}

class ProjectsCompanion extends UpdateCompanion<ProjectRow> {
  final Value<int?> remoteId;
  final Value<String?> updatedAtServer;
  final Value<bool> isDirty;
  final Value<bool> isDeleted;
  final Value<String?> syncedAt;
  final Value<int> id;
  final Value<String> title;
  final Value<String> description;
  final Value<int?> parentProjectId;
  final Value<double> position;
  final Value<bool> isFavourite;
  final Value<String?> hexColor;
  final Value<String> viewsJson;
  final Value<String?> ownerJson;
  final Value<String> rawJson;
  const ProjectsCompanion({
    this.remoteId = const Value.absent(),
    this.updatedAtServer = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.parentProjectId = const Value.absent(),
    this.position = const Value.absent(),
    this.isFavourite = const Value.absent(),
    this.hexColor = const Value.absent(),
    this.viewsJson = const Value.absent(),
    this.ownerJson = const Value.absent(),
    this.rawJson = const Value.absent(),
  });
  ProjectsCompanion.insert({
    this.remoteId = const Value.absent(),
    this.updatedAtServer = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.id = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.parentProjectId = const Value.absent(),
    this.position = const Value.absent(),
    this.isFavourite = const Value.absent(),
    this.hexColor = const Value.absent(),
    this.viewsJson = const Value.absent(),
    this.ownerJson = const Value.absent(),
    required String rawJson,
  }) : title = Value(title),
       rawJson = Value(rawJson);
  static Insertable<ProjectRow> custom({
    Expression<int>? remoteId,
    Expression<String>? updatedAtServer,
    Expression<bool>? isDirty,
    Expression<bool>? isDeleted,
    Expression<String>? syncedAt,
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? parentProjectId,
    Expression<double>? position,
    Expression<bool>? isFavourite,
    Expression<String>? hexColor,
    Expression<String>? viewsJson,
    Expression<String>? ownerJson,
    Expression<String>? rawJson,
  }) {
    return RawValuesInsertable({
      if (remoteId != null) 'remote_id': remoteId,
      if (updatedAtServer != null) 'updated_at_server': updatedAtServer,
      if (isDirty != null) 'is_dirty': isDirty,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (parentProjectId != null) 'parent_project_id': parentProjectId,
      if (position != null) 'position': position,
      if (isFavourite != null) 'is_favourite': isFavourite,
      if (hexColor != null) 'hex_color': hexColor,
      if (viewsJson != null) 'views_json': viewsJson,
      if (ownerJson != null) 'owner_json': ownerJson,
      if (rawJson != null) 'raw_json': rawJson,
    });
  }

  ProjectsCompanion copyWith({
    Value<int?>? remoteId,
    Value<String?>? updatedAtServer,
    Value<bool>? isDirty,
    Value<bool>? isDeleted,
    Value<String?>? syncedAt,
    Value<int>? id,
    Value<String>? title,
    Value<String>? description,
    Value<int?>? parentProjectId,
    Value<double>? position,
    Value<bool>? isFavourite,
    Value<String?>? hexColor,
    Value<String>? viewsJson,
    Value<String?>? ownerJson,
    Value<String>? rawJson,
  }) {
    return ProjectsCompanion(
      remoteId: remoteId ?? this.remoteId,
      updatedAtServer: updatedAtServer ?? this.updatedAtServer,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      syncedAt: syncedAt ?? this.syncedAt,
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      parentProjectId: parentProjectId ?? this.parentProjectId,
      position: position ?? this.position,
      isFavourite: isFavourite ?? this.isFavourite,
      hexColor: hexColor ?? this.hexColor,
      viewsJson: viewsJson ?? this.viewsJson,
      ownerJson: ownerJson ?? this.ownerJson,
      rawJson: rawJson ?? this.rawJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (remoteId.present) {
      map['remote_id'] = Variable<int>(remoteId.value);
    }
    if (updatedAtServer.present) {
      map['updated_at_server'] = Variable<String>(updatedAtServer.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<String>(syncedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (parentProjectId.present) {
      map['parent_project_id'] = Variable<int>(parentProjectId.value);
    }
    if (position.present) {
      map['position'] = Variable<double>(position.value);
    }
    if (isFavourite.present) {
      map['is_favourite'] = Variable<bool>(isFavourite.value);
    }
    if (hexColor.present) {
      map['hex_color'] = Variable<String>(hexColor.value);
    }
    if (viewsJson.present) {
      map['views_json'] = Variable<String>(viewsJson.value);
    }
    if (ownerJson.present) {
      map['owner_json'] = Variable<String>(ownerJson.value);
    }
    if (rawJson.present) {
      map['raw_json'] = Variable<String>(rawJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('remoteId: $remoteId, ')
          ..write('updatedAtServer: $updatedAtServer, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('parentProjectId: $parentProjectId, ')
          ..write('position: $position, ')
          ..write('isFavourite: $isFavourite, ')
          ..write('hexColor: $hexColor, ')
          ..write('viewsJson: $viewsJson, ')
          ..write('ownerJson: $ownerJson, ')
          ..write('rawJson: $rawJson')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, TaskRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<int> remoteId = GeneratedColumn<int>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _updatedAtServerMeta = const VerificationMeta(
    'updatedAtServer',
  );
  @override
  late final GeneratedColumn<String> updatedAtServer = GeneratedColumn<String>(
    'updated_at_server',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<String> syncedAt = GeneratedColumn<String>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bucketIdMeta = const VerificationMeta(
    'bucketId',
  );
  @override
  late final GeneratedColumn<int> bucketId = GeneratedColumn<int>(
    'bucket_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<bool> done = GeneratedColumn<bool>(
    'done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _doneAtMeta = const VerificationMeta('doneAt');
  @override
  late final GeneratedColumn<String> doneAt = GeneratedColumn<String>(
    'done_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<String> dueDate = GeneratedColumn<String>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<String> endDate = GeneratedColumn<String>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _percentDoneMeta = const VerificationMeta(
    'percentDone',
  );
  @override
  late final GeneratedColumn<double> percentDone = GeneratedColumn<double>(
    'percent_done',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<double> position = GeneratedColumn<double>(
    'position',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kanbanPositionMeta = const VerificationMeta(
    'kanbanPosition',
  );
  @override
  late final GeneratedColumn<double> kanbanPosition = GeneratedColumn<double>(
    'kanban_position',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _identifierMeta = const VerificationMeta(
    'identifier',
  );
  @override
  late final GeneratedColumn<String> identifier = GeneratedColumn<String>(
    'identifier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawJsonMeta = const VerificationMeta(
    'rawJson',
  );
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
    'raw_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    remoteId,
    updatedAtServer,
    isDirty,
    isDeleted,
    syncedAt,
    id,
    projectId,
    bucketId,
    title,
    description,
    done,
    doneAt,
    dueDate,
    startDate,
    endDate,
    priority,
    percentDone,
    position,
    kanbanPosition,
    identifier,
    createdAt,
    updatedAt,
    rawJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('updated_at_server')) {
      context.handle(
        _updatedAtServerMeta,
        updatedAtServer.isAcceptableOrUnknown(
          data['updated_at_server']!,
          _updatedAtServerMeta,
        ),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('bucket_id')) {
      context.handle(
        _bucketIdMeta,
        bucketId.isAcceptableOrUnknown(data['bucket_id']!, _bucketIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('done')) {
      context.handle(
        _doneMeta,
        done.isAcceptableOrUnknown(data['done']!, _doneMeta),
      );
    }
    if (data.containsKey('done_at')) {
      context.handle(
        _doneAtMeta,
        doneAt.isAcceptableOrUnknown(data['done_at']!, _doneAtMeta),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('percent_done')) {
      context.handle(
        _percentDoneMeta,
        percentDone.isAcceptableOrUnknown(
          data['percent_done']!,
          _percentDoneMeta,
        ),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('kanban_position')) {
      context.handle(
        _kanbanPositionMeta,
        kanbanPosition.isAcceptableOrUnknown(
          data['kanban_position']!,
          _kanbanPositionMeta,
        ),
      );
    }
    if (data.containsKey('identifier')) {
      context.handle(
        _identifierMeta,
        identifier.isAcceptableOrUnknown(data['identifier']!, _identifierMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('raw_json')) {
      context.handle(
        _rawJsonMeta,
        rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_rawJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskRow(
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remote_id'],
      ),
      updatedAtServer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_server'],
      ),
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}project_id'],
      )!,
      bucketId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bucket_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      done: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}done'],
      )!,
      doneAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}done_at'],
      ),
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}due_date'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_date'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_date'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      ),
      percentDone: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}percent_done'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}position'],
      ),
      kanbanPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kanban_position'],
      ),
      identifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}identifier'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      rawJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_json'],
      )!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class TaskRow extends DataClass implements Insertable<TaskRow> {
  final int? remoteId;
  final String? updatedAtServer;
  final bool isDirty;
  final bool isDeleted;
  final String? syncedAt;
  final int id;
  final int projectId;
  final int? bucketId;
  final String title;
  final String description;
  final bool done;
  final String? doneAt;
  final String? dueDate;
  final String? startDate;
  final String? endDate;
  final int? priority;
  final double? percentDone;
  final double? position;
  final double? kanbanPosition;
  final String identifier;
  final String createdAt;
  final String updatedAt;

  /// Komplettes TaskDto-JSON (inkl. reminders/subtasks/attachments/labels/
  /// assignees) als Fallback für Felder ohne eigene Spalte.
  final String rawJson;
  const TaskRow({
    this.remoteId,
    this.updatedAtServer,
    required this.isDirty,
    required this.isDeleted,
    this.syncedAt,
    required this.id,
    required this.projectId,
    this.bucketId,
    required this.title,
    required this.description,
    required this.done,
    this.doneAt,
    this.dueDate,
    this.startDate,
    this.endDate,
    this.priority,
    this.percentDone,
    this.position,
    this.kanbanPosition,
    required this.identifier,
    required this.createdAt,
    required this.updatedAt,
    required this.rawJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<int>(remoteId);
    }
    if (!nullToAbsent || updatedAtServer != null) {
      map['updated_at_server'] = Variable<String>(updatedAtServer);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<String>(syncedAt);
    }
    map['id'] = Variable<int>(id);
    map['project_id'] = Variable<int>(projectId);
    if (!nullToAbsent || bucketId != null) {
      map['bucket_id'] = Variable<int>(bucketId);
    }
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['done'] = Variable<bool>(done);
    if (!nullToAbsent || doneAt != null) {
      map['done_at'] = Variable<String>(doneAt);
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<String>(dueDate);
    }
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<String>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<String>(endDate);
    }
    if (!nullToAbsent || priority != null) {
      map['priority'] = Variable<int>(priority);
    }
    if (!nullToAbsent || percentDone != null) {
      map['percent_done'] = Variable<double>(percentDone);
    }
    if (!nullToAbsent || position != null) {
      map['position'] = Variable<double>(position);
    }
    if (!nullToAbsent || kanbanPosition != null) {
      map['kanban_position'] = Variable<double>(kanbanPosition);
    }
    map['identifier'] = Variable<String>(identifier);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['raw_json'] = Variable<String>(rawJson);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      updatedAtServer: updatedAtServer == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAtServer),
      isDirty: Value(isDirty),
      isDeleted: Value(isDeleted),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      id: Value(id),
      projectId: Value(projectId),
      bucketId: bucketId == null && nullToAbsent
          ? const Value.absent()
          : Value(bucketId),
      title: Value(title),
      description: Value(description),
      done: Value(done),
      doneAt: doneAt == null && nullToAbsent
          ? const Value.absent()
          : Value(doneAt),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      priority: priority == null && nullToAbsent
          ? const Value.absent()
          : Value(priority),
      percentDone: percentDone == null && nullToAbsent
          ? const Value.absent()
          : Value(percentDone),
      position: position == null && nullToAbsent
          ? const Value.absent()
          : Value(position),
      kanbanPosition: kanbanPosition == null && nullToAbsent
          ? const Value.absent()
          : Value(kanbanPosition),
      identifier: Value(identifier),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      rawJson: Value(rawJson),
    );
  }

  factory TaskRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskRow(
      remoteId: serializer.fromJson<int?>(json['remoteId']),
      updatedAtServer: serializer.fromJson<String?>(json['updatedAtServer']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      syncedAt: serializer.fromJson<String?>(json['syncedAt']),
      id: serializer.fromJson<int>(json['id']),
      projectId: serializer.fromJson<int>(json['projectId']),
      bucketId: serializer.fromJson<int?>(json['bucketId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      done: serializer.fromJson<bool>(json['done']),
      doneAt: serializer.fromJson<String?>(json['doneAt']),
      dueDate: serializer.fromJson<String?>(json['dueDate']),
      startDate: serializer.fromJson<String?>(json['startDate']),
      endDate: serializer.fromJson<String?>(json['endDate']),
      priority: serializer.fromJson<int?>(json['priority']),
      percentDone: serializer.fromJson<double?>(json['percentDone']),
      position: serializer.fromJson<double?>(json['position']),
      kanbanPosition: serializer.fromJson<double?>(json['kanbanPosition']),
      identifier: serializer.fromJson<String>(json['identifier']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      rawJson: serializer.fromJson<String>(json['rawJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'remoteId': serializer.toJson<int?>(remoteId),
      'updatedAtServer': serializer.toJson<String?>(updatedAtServer),
      'isDirty': serializer.toJson<bool>(isDirty),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'syncedAt': serializer.toJson<String?>(syncedAt),
      'id': serializer.toJson<int>(id),
      'projectId': serializer.toJson<int>(projectId),
      'bucketId': serializer.toJson<int?>(bucketId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'done': serializer.toJson<bool>(done),
      'doneAt': serializer.toJson<String?>(doneAt),
      'dueDate': serializer.toJson<String?>(dueDate),
      'startDate': serializer.toJson<String?>(startDate),
      'endDate': serializer.toJson<String?>(endDate),
      'priority': serializer.toJson<int?>(priority),
      'percentDone': serializer.toJson<double?>(percentDone),
      'position': serializer.toJson<double?>(position),
      'kanbanPosition': serializer.toJson<double?>(kanbanPosition),
      'identifier': serializer.toJson<String>(identifier),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'rawJson': serializer.toJson<String>(rawJson),
    };
  }

  TaskRow copyWith({
    Value<int?> remoteId = const Value.absent(),
    Value<String?> updatedAtServer = const Value.absent(),
    bool? isDirty,
    bool? isDeleted,
    Value<String?> syncedAt = const Value.absent(),
    int? id,
    int? projectId,
    Value<int?> bucketId = const Value.absent(),
    String? title,
    String? description,
    bool? done,
    Value<String?> doneAt = const Value.absent(),
    Value<String?> dueDate = const Value.absent(),
    Value<String?> startDate = const Value.absent(),
    Value<String?> endDate = const Value.absent(),
    Value<int?> priority = const Value.absent(),
    Value<double?> percentDone = const Value.absent(),
    Value<double?> position = const Value.absent(),
    Value<double?> kanbanPosition = const Value.absent(),
    String? identifier,
    String? createdAt,
    String? updatedAt,
    String? rawJson,
  }) => TaskRow(
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    updatedAtServer: updatedAtServer.present
        ? updatedAtServer.value
        : this.updatedAtServer,
    isDirty: isDirty ?? this.isDirty,
    isDeleted: isDeleted ?? this.isDeleted,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    bucketId: bucketId.present ? bucketId.value : this.bucketId,
    title: title ?? this.title,
    description: description ?? this.description,
    done: done ?? this.done,
    doneAt: doneAt.present ? doneAt.value : this.doneAt,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    startDate: startDate.present ? startDate.value : this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    priority: priority.present ? priority.value : this.priority,
    percentDone: percentDone.present ? percentDone.value : this.percentDone,
    position: position.present ? position.value : this.position,
    kanbanPosition: kanbanPosition.present
        ? kanbanPosition.value
        : this.kanbanPosition,
    identifier: identifier ?? this.identifier,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    rawJson: rawJson ?? this.rawJson,
  );
  TaskRow copyWithCompanion(TasksCompanion data) {
    return TaskRow(
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      updatedAtServer: data.updatedAtServer.present
          ? data.updatedAtServer.value
          : this.updatedAtServer,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      bucketId: data.bucketId.present ? data.bucketId.value : this.bucketId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      done: data.done.present ? data.done.value : this.done,
      doneAt: data.doneAt.present ? data.doneAt.value : this.doneAt,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      priority: data.priority.present ? data.priority.value : this.priority,
      percentDone: data.percentDone.present
          ? data.percentDone.value
          : this.percentDone,
      position: data.position.present ? data.position.value : this.position,
      kanbanPosition: data.kanbanPosition.present
          ? data.kanbanPosition.value
          : this.kanbanPosition,
      identifier: data.identifier.present
          ? data.identifier.value
          : this.identifier,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskRow(')
          ..write('remoteId: $remoteId, ')
          ..write('updatedAtServer: $updatedAtServer, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('bucketId: $bucketId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('done: $done, ')
          ..write('doneAt: $doneAt, ')
          ..write('dueDate: $dueDate, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('priority: $priority, ')
          ..write('percentDone: $percentDone, ')
          ..write('position: $position, ')
          ..write('kanbanPosition: $kanbanPosition, ')
          ..write('identifier: $identifier, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rawJson: $rawJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    remoteId,
    updatedAtServer,
    isDirty,
    isDeleted,
    syncedAt,
    id,
    projectId,
    bucketId,
    title,
    description,
    done,
    doneAt,
    dueDate,
    startDate,
    endDate,
    priority,
    percentDone,
    position,
    kanbanPosition,
    identifier,
    createdAt,
    updatedAt,
    rawJson,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskRow &&
          other.remoteId == this.remoteId &&
          other.updatedAtServer == this.updatedAtServer &&
          other.isDirty == this.isDirty &&
          other.isDeleted == this.isDeleted &&
          other.syncedAt == this.syncedAt &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.bucketId == this.bucketId &&
          other.title == this.title &&
          other.description == this.description &&
          other.done == this.done &&
          other.doneAt == this.doneAt &&
          other.dueDate == this.dueDate &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.priority == this.priority &&
          other.percentDone == this.percentDone &&
          other.position == this.position &&
          other.kanbanPosition == this.kanbanPosition &&
          other.identifier == this.identifier &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.rawJson == this.rawJson);
}

class TasksCompanion extends UpdateCompanion<TaskRow> {
  final Value<int?> remoteId;
  final Value<String?> updatedAtServer;
  final Value<bool> isDirty;
  final Value<bool> isDeleted;
  final Value<String?> syncedAt;
  final Value<int> id;
  final Value<int> projectId;
  final Value<int?> bucketId;
  final Value<String> title;
  final Value<String> description;
  final Value<bool> done;
  final Value<String?> doneAt;
  final Value<String?> dueDate;
  final Value<String?> startDate;
  final Value<String?> endDate;
  final Value<int?> priority;
  final Value<double?> percentDone;
  final Value<double?> position;
  final Value<double?> kanbanPosition;
  final Value<String> identifier;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String> rawJson;
  const TasksCompanion({
    this.remoteId = const Value.absent(),
    this.updatedAtServer = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.bucketId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.done = const Value.absent(),
    this.doneAt = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.priority = const Value.absent(),
    this.percentDone = const Value.absent(),
    this.position = const Value.absent(),
    this.kanbanPosition = const Value.absent(),
    this.identifier = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rawJson = const Value.absent(),
  });
  TasksCompanion.insert({
    this.remoteId = const Value.absent(),
    this.updatedAtServer = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.id = const Value.absent(),
    required int projectId,
    this.bucketId = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.done = const Value.absent(),
    this.doneAt = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.priority = const Value.absent(),
    this.percentDone = const Value.absent(),
    this.position = const Value.absent(),
    this.kanbanPosition = const Value.absent(),
    this.identifier = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    required String rawJson,
  }) : projectId = Value(projectId),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       rawJson = Value(rawJson);
  static Insertable<TaskRow> custom({
    Expression<int>? remoteId,
    Expression<String>? updatedAtServer,
    Expression<bool>? isDirty,
    Expression<bool>? isDeleted,
    Expression<String>? syncedAt,
    Expression<int>? id,
    Expression<int>? projectId,
    Expression<int>? bucketId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<bool>? done,
    Expression<String>? doneAt,
    Expression<String>? dueDate,
    Expression<String>? startDate,
    Expression<String>? endDate,
    Expression<int>? priority,
    Expression<double>? percentDone,
    Expression<double>? position,
    Expression<double>? kanbanPosition,
    Expression<String>? identifier,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? rawJson,
  }) {
    return RawValuesInsertable({
      if (remoteId != null) 'remote_id': remoteId,
      if (updatedAtServer != null) 'updated_at_server': updatedAtServer,
      if (isDirty != null) 'is_dirty': isDirty,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (bucketId != null) 'bucket_id': bucketId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (done != null) 'done': done,
      if (doneAt != null) 'done_at': doneAt,
      if (dueDate != null) 'due_date': dueDate,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (priority != null) 'priority': priority,
      if (percentDone != null) 'percent_done': percentDone,
      if (position != null) 'position': position,
      if (kanbanPosition != null) 'kanban_position': kanbanPosition,
      if (identifier != null) 'identifier': identifier,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rawJson != null) 'raw_json': rawJson,
    });
  }

  TasksCompanion copyWith({
    Value<int?>? remoteId,
    Value<String?>? updatedAtServer,
    Value<bool>? isDirty,
    Value<bool>? isDeleted,
    Value<String?>? syncedAt,
    Value<int>? id,
    Value<int>? projectId,
    Value<int?>? bucketId,
    Value<String>? title,
    Value<String>? description,
    Value<bool>? done,
    Value<String?>? doneAt,
    Value<String?>? dueDate,
    Value<String?>? startDate,
    Value<String?>? endDate,
    Value<int?>? priority,
    Value<double?>? percentDone,
    Value<double?>? position,
    Value<double?>? kanbanPosition,
    Value<String>? identifier,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String>? rawJson,
  }) {
    return TasksCompanion(
      remoteId: remoteId ?? this.remoteId,
      updatedAtServer: updatedAtServer ?? this.updatedAtServer,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      syncedAt: syncedAt ?? this.syncedAt,
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      bucketId: bucketId ?? this.bucketId,
      title: title ?? this.title,
      description: description ?? this.description,
      done: done ?? this.done,
      doneAt: doneAt ?? this.doneAt,
      dueDate: dueDate ?? this.dueDate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      priority: priority ?? this.priority,
      percentDone: percentDone ?? this.percentDone,
      position: position ?? this.position,
      kanbanPosition: kanbanPosition ?? this.kanbanPosition,
      identifier: identifier ?? this.identifier,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rawJson: rawJson ?? this.rawJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (remoteId.present) {
      map['remote_id'] = Variable<int>(remoteId.value);
    }
    if (updatedAtServer.present) {
      map['updated_at_server'] = Variable<String>(updatedAtServer.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<String>(syncedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (bucketId.present) {
      map['bucket_id'] = Variable<int>(bucketId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (done.present) {
      map['done'] = Variable<bool>(done.value);
    }
    if (doneAt.present) {
      map['done_at'] = Variable<String>(doneAt.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<String>(dueDate.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<String>(endDate.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (percentDone.present) {
      map['percent_done'] = Variable<double>(percentDone.value);
    }
    if (position.present) {
      map['position'] = Variable<double>(position.value);
    }
    if (kanbanPosition.present) {
      map['kanban_position'] = Variable<double>(kanbanPosition.value);
    }
    if (identifier.present) {
      map['identifier'] = Variable<String>(identifier.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rawJson.present) {
      map['raw_json'] = Variable<String>(rawJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('remoteId: $remoteId, ')
          ..write('updatedAtServer: $updatedAtServer, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('bucketId: $bucketId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('done: $done, ')
          ..write('doneAt: $doneAt, ')
          ..write('dueDate: $dueDate, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('priority: $priority, ')
          ..write('percentDone: $percentDone, ')
          ..write('position: $position, ')
          ..write('kanbanPosition: $kanbanPosition, ')
          ..write('identifier: $identifier, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rawJson: $rawJson')
          ..write(')'))
        .toString();
  }
}

class $LabelsTable extends Labels with TableInfo<$LabelsTable, LabelRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LabelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<int> remoteId = GeneratedColumn<int>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _updatedAtServerMeta = const VerificationMeta(
    'updatedAtServer',
  );
  @override
  late final GeneratedColumn<String> updatedAtServer = GeneratedColumn<String>(
    'updated_at_server',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<String> syncedAt = GeneratedColumn<String>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hexColorMeta = const VerificationMeta(
    'hexColor',
  );
  @override
  late final GeneratedColumn<String> hexColor = GeneratedColumn<String>(
    'hex_color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawJsonMeta = const VerificationMeta(
    'rawJson',
  );
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
    'raw_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    remoteId,
    updatedAtServer,
    isDirty,
    isDeleted,
    syncedAt,
    id,
    title,
    hexColor,
    rawJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'labels';
  @override
  VerificationContext validateIntegrity(
    Insertable<LabelRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('updated_at_server')) {
      context.handle(
        _updatedAtServerMeta,
        updatedAtServer.isAcceptableOrUnknown(
          data['updated_at_server']!,
          _updatedAtServerMeta,
        ),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('hex_color')) {
      context.handle(
        _hexColorMeta,
        hexColor.isAcceptableOrUnknown(data['hex_color']!, _hexColorMeta),
      );
    }
    if (data.containsKey('raw_json')) {
      context.handle(
        _rawJsonMeta,
        rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_rawJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LabelRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LabelRow(
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remote_id'],
      ),
      updatedAtServer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_server'],
      ),
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      hexColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hex_color'],
      ),
      rawJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_json'],
      )!,
    );
  }

  @override
  $LabelsTable createAlias(String alias) {
    return $LabelsTable(attachedDatabase, alias);
  }
}

class LabelRow extends DataClass implements Insertable<LabelRow> {
  final int? remoteId;
  final String? updatedAtServer;
  final bool isDirty;
  final bool isDeleted;
  final String? syncedAt;
  final int id;
  final String title;
  final String? hexColor;
  final String rawJson;
  const LabelRow({
    this.remoteId,
    this.updatedAtServer,
    required this.isDirty,
    required this.isDeleted,
    this.syncedAt,
    required this.id,
    required this.title,
    this.hexColor,
    required this.rawJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<int>(remoteId);
    }
    if (!nullToAbsent || updatedAtServer != null) {
      map['updated_at_server'] = Variable<String>(updatedAtServer);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<String>(syncedAt);
    }
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || hexColor != null) {
      map['hex_color'] = Variable<String>(hexColor);
    }
    map['raw_json'] = Variable<String>(rawJson);
    return map;
  }

  LabelsCompanion toCompanion(bool nullToAbsent) {
    return LabelsCompanion(
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      updatedAtServer: updatedAtServer == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAtServer),
      isDirty: Value(isDirty),
      isDeleted: Value(isDeleted),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      id: Value(id),
      title: Value(title),
      hexColor: hexColor == null && nullToAbsent
          ? const Value.absent()
          : Value(hexColor),
      rawJson: Value(rawJson),
    );
  }

  factory LabelRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LabelRow(
      remoteId: serializer.fromJson<int?>(json['remoteId']),
      updatedAtServer: serializer.fromJson<String?>(json['updatedAtServer']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      syncedAt: serializer.fromJson<String?>(json['syncedAt']),
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      hexColor: serializer.fromJson<String?>(json['hexColor']),
      rawJson: serializer.fromJson<String>(json['rawJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'remoteId': serializer.toJson<int?>(remoteId),
      'updatedAtServer': serializer.toJson<String?>(updatedAtServer),
      'isDirty': serializer.toJson<bool>(isDirty),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'syncedAt': serializer.toJson<String?>(syncedAt),
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'hexColor': serializer.toJson<String?>(hexColor),
      'rawJson': serializer.toJson<String>(rawJson),
    };
  }

  LabelRow copyWith({
    Value<int?> remoteId = const Value.absent(),
    Value<String?> updatedAtServer = const Value.absent(),
    bool? isDirty,
    bool? isDeleted,
    Value<String?> syncedAt = const Value.absent(),
    int? id,
    String? title,
    Value<String?> hexColor = const Value.absent(),
    String? rawJson,
  }) => LabelRow(
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    updatedAtServer: updatedAtServer.present
        ? updatedAtServer.value
        : this.updatedAtServer,
    isDirty: isDirty ?? this.isDirty,
    isDeleted: isDeleted ?? this.isDeleted,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    id: id ?? this.id,
    title: title ?? this.title,
    hexColor: hexColor.present ? hexColor.value : this.hexColor,
    rawJson: rawJson ?? this.rawJson,
  );
  LabelRow copyWithCompanion(LabelsCompanion data) {
    return LabelRow(
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      updatedAtServer: data.updatedAtServer.present
          ? data.updatedAtServer.value
          : this.updatedAtServer,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      hexColor: data.hexColor.present ? data.hexColor.value : this.hexColor,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LabelRow(')
          ..write('remoteId: $remoteId, ')
          ..write('updatedAtServer: $updatedAtServer, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('hexColor: $hexColor, ')
          ..write('rawJson: $rawJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    remoteId,
    updatedAtServer,
    isDirty,
    isDeleted,
    syncedAt,
    id,
    title,
    hexColor,
    rawJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LabelRow &&
          other.remoteId == this.remoteId &&
          other.updatedAtServer == this.updatedAtServer &&
          other.isDirty == this.isDirty &&
          other.isDeleted == this.isDeleted &&
          other.syncedAt == this.syncedAt &&
          other.id == this.id &&
          other.title == this.title &&
          other.hexColor == this.hexColor &&
          other.rawJson == this.rawJson);
}

class LabelsCompanion extends UpdateCompanion<LabelRow> {
  final Value<int?> remoteId;
  final Value<String?> updatedAtServer;
  final Value<bool> isDirty;
  final Value<bool> isDeleted;
  final Value<String?> syncedAt;
  final Value<int> id;
  final Value<String> title;
  final Value<String?> hexColor;
  final Value<String> rawJson;
  const LabelsCompanion({
    this.remoteId = const Value.absent(),
    this.updatedAtServer = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.hexColor = const Value.absent(),
    this.rawJson = const Value.absent(),
  });
  LabelsCompanion.insert({
    this.remoteId = const Value.absent(),
    this.updatedAtServer = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.id = const Value.absent(),
    required String title,
    this.hexColor = const Value.absent(),
    required String rawJson,
  }) : title = Value(title),
       rawJson = Value(rawJson);
  static Insertable<LabelRow> custom({
    Expression<int>? remoteId,
    Expression<String>? updatedAtServer,
    Expression<bool>? isDirty,
    Expression<bool>? isDeleted,
    Expression<String>? syncedAt,
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? hexColor,
    Expression<String>? rawJson,
  }) {
    return RawValuesInsertable({
      if (remoteId != null) 'remote_id': remoteId,
      if (updatedAtServer != null) 'updated_at_server': updatedAtServer,
      if (isDirty != null) 'is_dirty': isDirty,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (hexColor != null) 'hex_color': hexColor,
      if (rawJson != null) 'raw_json': rawJson,
    });
  }

  LabelsCompanion copyWith({
    Value<int?>? remoteId,
    Value<String?>? updatedAtServer,
    Value<bool>? isDirty,
    Value<bool>? isDeleted,
    Value<String?>? syncedAt,
    Value<int>? id,
    Value<String>? title,
    Value<String?>? hexColor,
    Value<String>? rawJson,
  }) {
    return LabelsCompanion(
      remoteId: remoteId ?? this.remoteId,
      updatedAtServer: updatedAtServer ?? this.updatedAtServer,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      syncedAt: syncedAt ?? this.syncedAt,
      id: id ?? this.id,
      title: title ?? this.title,
      hexColor: hexColor ?? this.hexColor,
      rawJson: rawJson ?? this.rawJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (remoteId.present) {
      map['remote_id'] = Variable<int>(remoteId.value);
    }
    if (updatedAtServer.present) {
      map['updated_at_server'] = Variable<String>(updatedAtServer.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<String>(syncedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (hexColor.present) {
      map['hex_color'] = Variable<String>(hexColor.value);
    }
    if (rawJson.present) {
      map['raw_json'] = Variable<String>(rawJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LabelsCompanion(')
          ..write('remoteId: $remoteId, ')
          ..write('updatedAtServer: $updatedAtServer, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('hexColor: $hexColor, ')
          ..write('rawJson: $rawJson')
          ..write(')'))
        .toString();
  }
}

class $UsersTable extends Users with TableInfo<$UsersTable, UserRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<int> remoteId = GeneratedColumn<int>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _updatedAtServerMeta = const VerificationMeta(
    'updatedAtServer',
  );
  @override
  late final GeneratedColumn<String> updatedAtServer = GeneratedColumn<String>(
    'updated_at_server',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<String> syncedAt = GeneratedColumn<String>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _rawJsonMeta = const VerificationMeta(
    'rawJson',
  );
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
    'raw_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    remoteId,
    updatedAtServer,
    isDirty,
    isDeleted,
    syncedAt,
    id,
    username,
    name,
    rawJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('updated_at_server')) {
      context.handle(
        _updatedAtServerMeta,
        updatedAtServer.isAcceptableOrUnknown(
          data['updated_at_server']!,
          _updatedAtServerMeta,
        ),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('raw_json')) {
      context.handle(
        _rawJsonMeta,
        rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_rawJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserRow(
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remote_id'],
      ),
      updatedAtServer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_server'],
      ),
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      rawJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_json'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class UserRow extends DataClass implements Insertable<UserRow> {
  final int? remoteId;
  final String? updatedAtServer;
  final bool isDirty;
  final bool isDeleted;
  final String? syncedAt;
  final int id;
  final String username;
  final String name;
  final String rawJson;
  const UserRow({
    this.remoteId,
    this.updatedAtServer,
    required this.isDirty,
    required this.isDeleted,
    this.syncedAt,
    required this.id,
    required this.username,
    required this.name,
    required this.rawJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<int>(remoteId);
    }
    if (!nullToAbsent || updatedAtServer != null) {
      map['updated_at_server'] = Variable<String>(updatedAtServer);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<String>(syncedAt);
    }
    map['id'] = Variable<int>(id);
    map['username'] = Variable<String>(username);
    map['name'] = Variable<String>(name);
    map['raw_json'] = Variable<String>(rawJson);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      updatedAtServer: updatedAtServer == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAtServer),
      isDirty: Value(isDirty),
      isDeleted: Value(isDeleted),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      id: Value(id),
      username: Value(username),
      name: Value(name),
      rawJson: Value(rawJson),
    );
  }

  factory UserRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserRow(
      remoteId: serializer.fromJson<int?>(json['remoteId']),
      updatedAtServer: serializer.fromJson<String?>(json['updatedAtServer']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      syncedAt: serializer.fromJson<String?>(json['syncedAt']),
      id: serializer.fromJson<int>(json['id']),
      username: serializer.fromJson<String>(json['username']),
      name: serializer.fromJson<String>(json['name']),
      rawJson: serializer.fromJson<String>(json['rawJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'remoteId': serializer.toJson<int?>(remoteId),
      'updatedAtServer': serializer.toJson<String?>(updatedAtServer),
      'isDirty': serializer.toJson<bool>(isDirty),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'syncedAt': serializer.toJson<String?>(syncedAt),
      'id': serializer.toJson<int>(id),
      'username': serializer.toJson<String>(username),
      'name': serializer.toJson<String>(name),
      'rawJson': serializer.toJson<String>(rawJson),
    };
  }

  UserRow copyWith({
    Value<int?> remoteId = const Value.absent(),
    Value<String?> updatedAtServer = const Value.absent(),
    bool? isDirty,
    bool? isDeleted,
    Value<String?> syncedAt = const Value.absent(),
    int? id,
    String? username,
    String? name,
    String? rawJson,
  }) => UserRow(
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    updatedAtServer: updatedAtServer.present
        ? updatedAtServer.value
        : this.updatedAtServer,
    isDirty: isDirty ?? this.isDirty,
    isDeleted: isDeleted ?? this.isDeleted,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    id: id ?? this.id,
    username: username ?? this.username,
    name: name ?? this.name,
    rawJson: rawJson ?? this.rawJson,
  );
  UserRow copyWithCompanion(UsersCompanion data) {
    return UserRow(
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      updatedAtServer: data.updatedAtServer.present
          ? data.updatedAtServer.value
          : this.updatedAtServer,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      id: data.id.present ? data.id.value : this.id,
      username: data.username.present ? data.username.value : this.username,
      name: data.name.present ? data.name.value : this.name,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserRow(')
          ..write('remoteId: $remoteId, ')
          ..write('updatedAtServer: $updatedAtServer, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('name: $name, ')
          ..write('rawJson: $rawJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    remoteId,
    updatedAtServer,
    isDirty,
    isDeleted,
    syncedAt,
    id,
    username,
    name,
    rawJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserRow &&
          other.remoteId == this.remoteId &&
          other.updatedAtServer == this.updatedAtServer &&
          other.isDirty == this.isDirty &&
          other.isDeleted == this.isDeleted &&
          other.syncedAt == this.syncedAt &&
          other.id == this.id &&
          other.username == this.username &&
          other.name == this.name &&
          other.rawJson == this.rawJson);
}

class UsersCompanion extends UpdateCompanion<UserRow> {
  final Value<int?> remoteId;
  final Value<String?> updatedAtServer;
  final Value<bool> isDirty;
  final Value<bool> isDeleted;
  final Value<String?> syncedAt;
  final Value<int> id;
  final Value<String> username;
  final Value<String> name;
  final Value<String> rawJson;
  const UsersCompanion({
    this.remoteId = const Value.absent(),
    this.updatedAtServer = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.name = const Value.absent(),
    this.rawJson = const Value.absent(),
  });
  UsersCompanion.insert({
    this.remoteId = const Value.absent(),
    this.updatedAtServer = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.id = const Value.absent(),
    required String username,
    this.name = const Value.absent(),
    required String rawJson,
  }) : username = Value(username),
       rawJson = Value(rawJson);
  static Insertable<UserRow> custom({
    Expression<int>? remoteId,
    Expression<String>? updatedAtServer,
    Expression<bool>? isDirty,
    Expression<bool>? isDeleted,
    Expression<String>? syncedAt,
    Expression<int>? id,
    Expression<String>? username,
    Expression<String>? name,
    Expression<String>? rawJson,
  }) {
    return RawValuesInsertable({
      if (remoteId != null) 'remote_id': remoteId,
      if (updatedAtServer != null) 'updated_at_server': updatedAtServer,
      if (isDirty != null) 'is_dirty': isDirty,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (name != null) 'name': name,
      if (rawJson != null) 'raw_json': rawJson,
    });
  }

  UsersCompanion copyWith({
    Value<int?>? remoteId,
    Value<String?>? updatedAtServer,
    Value<bool>? isDirty,
    Value<bool>? isDeleted,
    Value<String?>? syncedAt,
    Value<int>? id,
    Value<String>? username,
    Value<String>? name,
    Value<String>? rawJson,
  }) {
    return UsersCompanion(
      remoteId: remoteId ?? this.remoteId,
      updatedAtServer: updatedAtServer ?? this.updatedAtServer,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      syncedAt: syncedAt ?? this.syncedAt,
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      rawJson: rawJson ?? this.rawJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (remoteId.present) {
      map['remote_id'] = Variable<int>(remoteId.value);
    }
    if (updatedAtServer.present) {
      map['updated_at_server'] = Variable<String>(updatedAtServer.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<String>(syncedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rawJson.present) {
      map['raw_json'] = Variable<String>(rawJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('remoteId: $remoteId, ')
          ..write('updatedAtServer: $updatedAtServer, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('name: $name, ')
          ..write('rawJson: $rawJson')
          ..write(')'))
        .toString();
  }
}

class $BucketsTable extends Buckets with TableInfo<$BucketsTable, BucketRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BucketsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<int> remoteId = GeneratedColumn<int>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _updatedAtServerMeta = const VerificationMeta(
    'updatedAtServer',
  );
  @override
  late final GeneratedColumn<String> updatedAtServer = GeneratedColumn<String>(
    'updated_at_server',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<String> syncedAt = GeneratedColumn<String>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _viewIdMeta = const VerificationMeta('viewId');
  @override
  late final GeneratedColumn<int> viewId = GeneratedColumn<int>(
    'view_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<double> position = GeneratedColumn<double>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _taskLimitMeta = const VerificationMeta(
    'taskLimit',
  );
  @override
  late final GeneratedColumn<int> taskLimit = GeneratedColumn<int>(
    'task_limit',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDoneBucketMeta = const VerificationMeta(
    'isDoneBucket',
  );
  @override
  late final GeneratedColumn<bool> isDoneBucket = GeneratedColumn<bool>(
    'is_done_bucket',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_done_bucket" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _rawJsonMeta = const VerificationMeta(
    'rawJson',
  );
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
    'raw_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    remoteId,
    updatedAtServer,
    isDirty,
    isDeleted,
    syncedAt,
    id,
    projectId,
    viewId,
    title,
    position,
    taskLimit,
    isDoneBucket,
    rawJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'buckets';
  @override
  VerificationContext validateIntegrity(
    Insertable<BucketRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('updated_at_server')) {
      context.handle(
        _updatedAtServerMeta,
        updatedAtServer.isAcceptableOrUnknown(
          data['updated_at_server']!,
          _updatedAtServerMeta,
        ),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('view_id')) {
      context.handle(
        _viewIdMeta,
        viewId.isAcceptableOrUnknown(data['view_id']!, _viewIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('task_limit')) {
      context.handle(
        _taskLimitMeta,
        taskLimit.isAcceptableOrUnknown(data['task_limit']!, _taskLimitMeta),
      );
    }
    if (data.containsKey('is_done_bucket')) {
      context.handle(
        _isDoneBucketMeta,
        isDoneBucket.isAcceptableOrUnknown(
          data['is_done_bucket']!,
          _isDoneBucketMeta,
        ),
      );
    }
    if (data.containsKey('raw_json')) {
      context.handle(
        _rawJsonMeta,
        rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_rawJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BucketRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BucketRow(
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remote_id'],
      ),
      updatedAtServer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_server'],
      ),
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}project_id'],
      )!,
      viewId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}view_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}position'],
      )!,
      taskLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}task_limit'],
      ),
      isDoneBucket: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_done_bucket'],
      )!,
      rawJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_json'],
      )!,
    );
  }

  @override
  $BucketsTable createAlias(String alias) {
    return $BucketsTable(attachedDatabase, alias);
  }
}

class BucketRow extends DataClass implements Insertable<BucketRow> {
  final int? remoteId;
  final String? updatedAtServer;
  final bool isDirty;
  final bool isDeleted;
  final String? syncedAt;
  final int id;
  final int projectId;
  final int? viewId;
  final String title;
  final double position;
  final int? taskLimit;
  final bool isDoneBucket;
  final String rawJson;
  const BucketRow({
    this.remoteId,
    this.updatedAtServer,
    required this.isDirty,
    required this.isDeleted,
    this.syncedAt,
    required this.id,
    required this.projectId,
    this.viewId,
    required this.title,
    required this.position,
    this.taskLimit,
    required this.isDoneBucket,
    required this.rawJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<int>(remoteId);
    }
    if (!nullToAbsent || updatedAtServer != null) {
      map['updated_at_server'] = Variable<String>(updatedAtServer);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<String>(syncedAt);
    }
    map['id'] = Variable<int>(id);
    map['project_id'] = Variable<int>(projectId);
    if (!nullToAbsent || viewId != null) {
      map['view_id'] = Variable<int>(viewId);
    }
    map['title'] = Variable<String>(title);
    map['position'] = Variable<double>(position);
    if (!nullToAbsent || taskLimit != null) {
      map['task_limit'] = Variable<int>(taskLimit);
    }
    map['is_done_bucket'] = Variable<bool>(isDoneBucket);
    map['raw_json'] = Variable<String>(rawJson);
    return map;
  }

  BucketsCompanion toCompanion(bool nullToAbsent) {
    return BucketsCompanion(
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      updatedAtServer: updatedAtServer == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAtServer),
      isDirty: Value(isDirty),
      isDeleted: Value(isDeleted),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      id: Value(id),
      projectId: Value(projectId),
      viewId: viewId == null && nullToAbsent
          ? const Value.absent()
          : Value(viewId),
      title: Value(title),
      position: Value(position),
      taskLimit: taskLimit == null && nullToAbsent
          ? const Value.absent()
          : Value(taskLimit),
      isDoneBucket: Value(isDoneBucket),
      rawJson: Value(rawJson),
    );
  }

  factory BucketRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BucketRow(
      remoteId: serializer.fromJson<int?>(json['remoteId']),
      updatedAtServer: serializer.fromJson<String?>(json['updatedAtServer']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      syncedAt: serializer.fromJson<String?>(json['syncedAt']),
      id: serializer.fromJson<int>(json['id']),
      projectId: serializer.fromJson<int>(json['projectId']),
      viewId: serializer.fromJson<int?>(json['viewId']),
      title: serializer.fromJson<String>(json['title']),
      position: serializer.fromJson<double>(json['position']),
      taskLimit: serializer.fromJson<int?>(json['taskLimit']),
      isDoneBucket: serializer.fromJson<bool>(json['isDoneBucket']),
      rawJson: serializer.fromJson<String>(json['rawJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'remoteId': serializer.toJson<int?>(remoteId),
      'updatedAtServer': serializer.toJson<String?>(updatedAtServer),
      'isDirty': serializer.toJson<bool>(isDirty),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'syncedAt': serializer.toJson<String?>(syncedAt),
      'id': serializer.toJson<int>(id),
      'projectId': serializer.toJson<int>(projectId),
      'viewId': serializer.toJson<int?>(viewId),
      'title': serializer.toJson<String>(title),
      'position': serializer.toJson<double>(position),
      'taskLimit': serializer.toJson<int?>(taskLimit),
      'isDoneBucket': serializer.toJson<bool>(isDoneBucket),
      'rawJson': serializer.toJson<String>(rawJson),
    };
  }

  BucketRow copyWith({
    Value<int?> remoteId = const Value.absent(),
    Value<String?> updatedAtServer = const Value.absent(),
    bool? isDirty,
    bool? isDeleted,
    Value<String?> syncedAt = const Value.absent(),
    int? id,
    int? projectId,
    Value<int?> viewId = const Value.absent(),
    String? title,
    double? position,
    Value<int?> taskLimit = const Value.absent(),
    bool? isDoneBucket,
    String? rawJson,
  }) => BucketRow(
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    updatedAtServer: updatedAtServer.present
        ? updatedAtServer.value
        : this.updatedAtServer,
    isDirty: isDirty ?? this.isDirty,
    isDeleted: isDeleted ?? this.isDeleted,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    viewId: viewId.present ? viewId.value : this.viewId,
    title: title ?? this.title,
    position: position ?? this.position,
    taskLimit: taskLimit.present ? taskLimit.value : this.taskLimit,
    isDoneBucket: isDoneBucket ?? this.isDoneBucket,
    rawJson: rawJson ?? this.rawJson,
  );
  BucketRow copyWithCompanion(BucketsCompanion data) {
    return BucketRow(
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      updatedAtServer: data.updatedAtServer.present
          ? data.updatedAtServer.value
          : this.updatedAtServer,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      viewId: data.viewId.present ? data.viewId.value : this.viewId,
      title: data.title.present ? data.title.value : this.title,
      position: data.position.present ? data.position.value : this.position,
      taskLimit: data.taskLimit.present ? data.taskLimit.value : this.taskLimit,
      isDoneBucket: data.isDoneBucket.present
          ? data.isDoneBucket.value
          : this.isDoneBucket,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BucketRow(')
          ..write('remoteId: $remoteId, ')
          ..write('updatedAtServer: $updatedAtServer, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('viewId: $viewId, ')
          ..write('title: $title, ')
          ..write('position: $position, ')
          ..write('taskLimit: $taskLimit, ')
          ..write('isDoneBucket: $isDoneBucket, ')
          ..write('rawJson: $rawJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    remoteId,
    updatedAtServer,
    isDirty,
    isDeleted,
    syncedAt,
    id,
    projectId,
    viewId,
    title,
    position,
    taskLimit,
    isDoneBucket,
    rawJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BucketRow &&
          other.remoteId == this.remoteId &&
          other.updatedAtServer == this.updatedAtServer &&
          other.isDirty == this.isDirty &&
          other.isDeleted == this.isDeleted &&
          other.syncedAt == this.syncedAt &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.viewId == this.viewId &&
          other.title == this.title &&
          other.position == this.position &&
          other.taskLimit == this.taskLimit &&
          other.isDoneBucket == this.isDoneBucket &&
          other.rawJson == this.rawJson);
}

class BucketsCompanion extends UpdateCompanion<BucketRow> {
  final Value<int?> remoteId;
  final Value<String?> updatedAtServer;
  final Value<bool> isDirty;
  final Value<bool> isDeleted;
  final Value<String?> syncedAt;
  final Value<int> id;
  final Value<int> projectId;
  final Value<int?> viewId;
  final Value<String> title;
  final Value<double> position;
  final Value<int?> taskLimit;
  final Value<bool> isDoneBucket;
  final Value<String> rawJson;
  const BucketsCompanion({
    this.remoteId = const Value.absent(),
    this.updatedAtServer = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.viewId = const Value.absent(),
    this.title = const Value.absent(),
    this.position = const Value.absent(),
    this.taskLimit = const Value.absent(),
    this.isDoneBucket = const Value.absent(),
    this.rawJson = const Value.absent(),
  });
  BucketsCompanion.insert({
    this.remoteId = const Value.absent(),
    this.updatedAtServer = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.id = const Value.absent(),
    required int projectId,
    this.viewId = const Value.absent(),
    required String title,
    this.position = const Value.absent(),
    this.taskLimit = const Value.absent(),
    this.isDoneBucket = const Value.absent(),
    required String rawJson,
  }) : projectId = Value(projectId),
       title = Value(title),
       rawJson = Value(rawJson);
  static Insertable<BucketRow> custom({
    Expression<int>? remoteId,
    Expression<String>? updatedAtServer,
    Expression<bool>? isDirty,
    Expression<bool>? isDeleted,
    Expression<String>? syncedAt,
    Expression<int>? id,
    Expression<int>? projectId,
    Expression<int>? viewId,
    Expression<String>? title,
    Expression<double>? position,
    Expression<int>? taskLimit,
    Expression<bool>? isDoneBucket,
    Expression<String>? rawJson,
  }) {
    return RawValuesInsertable({
      if (remoteId != null) 'remote_id': remoteId,
      if (updatedAtServer != null) 'updated_at_server': updatedAtServer,
      if (isDirty != null) 'is_dirty': isDirty,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (viewId != null) 'view_id': viewId,
      if (title != null) 'title': title,
      if (position != null) 'position': position,
      if (taskLimit != null) 'task_limit': taskLimit,
      if (isDoneBucket != null) 'is_done_bucket': isDoneBucket,
      if (rawJson != null) 'raw_json': rawJson,
    });
  }

  BucketsCompanion copyWith({
    Value<int?>? remoteId,
    Value<String?>? updatedAtServer,
    Value<bool>? isDirty,
    Value<bool>? isDeleted,
    Value<String?>? syncedAt,
    Value<int>? id,
    Value<int>? projectId,
    Value<int?>? viewId,
    Value<String>? title,
    Value<double>? position,
    Value<int?>? taskLimit,
    Value<bool>? isDoneBucket,
    Value<String>? rawJson,
  }) {
    return BucketsCompanion(
      remoteId: remoteId ?? this.remoteId,
      updatedAtServer: updatedAtServer ?? this.updatedAtServer,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      syncedAt: syncedAt ?? this.syncedAt,
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      viewId: viewId ?? this.viewId,
      title: title ?? this.title,
      position: position ?? this.position,
      taskLimit: taskLimit ?? this.taskLimit,
      isDoneBucket: isDoneBucket ?? this.isDoneBucket,
      rawJson: rawJson ?? this.rawJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (remoteId.present) {
      map['remote_id'] = Variable<int>(remoteId.value);
    }
    if (updatedAtServer.present) {
      map['updated_at_server'] = Variable<String>(updatedAtServer.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<String>(syncedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (viewId.present) {
      map['view_id'] = Variable<int>(viewId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (position.present) {
      map['position'] = Variable<double>(position.value);
    }
    if (taskLimit.present) {
      map['task_limit'] = Variable<int>(taskLimit.value);
    }
    if (isDoneBucket.present) {
      map['is_done_bucket'] = Variable<bool>(isDoneBucket.value);
    }
    if (rawJson.present) {
      map['raw_json'] = Variable<String>(rawJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BucketsCompanion(')
          ..write('remoteId: $remoteId, ')
          ..write('updatedAtServer: $updatedAtServer, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('viewId: $viewId, ')
          ..write('title: $title, ')
          ..write('position: $position, ')
          ..write('taskLimit: $taskLimit, ')
          ..write('isDoneBucket: $isDoneBucket, ')
          ..write('rawJson: $rawJson')
          ..write(')'))
        .toString();
  }
}

class $TaskLabelsTable extends TaskLabels
    with TableInfo<$TaskLabelsTable, TaskLabelRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskLabelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelIdMeta = const VerificationMeta(
    'labelId',
  );
  @override
  late final GeneratedColumn<int> labelId = GeneratedColumn<int>(
    'label_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [taskId, labelId, isDirty];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_labels';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskLabelRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('label_id')) {
      context.handle(
        _labelIdMeta,
        labelId.isAcceptableOrUnknown(data['label_id']!, _labelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_labelIdMeta);
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {taskId, labelId};
  @override
  TaskLabelRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskLabelRow(
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}task_id'],
      )!,
      labelId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}label_id'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
    );
  }

  @override
  $TaskLabelsTable createAlias(String alias) {
    return $TaskLabelsTable(attachedDatabase, alias);
  }
}

class TaskLabelRow extends DataClass implements Insertable<TaskLabelRow> {
  final int taskId;
  final int labelId;
  final bool isDirty;
  const TaskLabelRow({
    required this.taskId,
    required this.labelId,
    required this.isDirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['task_id'] = Variable<int>(taskId);
    map['label_id'] = Variable<int>(labelId);
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }

  TaskLabelsCompanion toCompanion(bool nullToAbsent) {
    return TaskLabelsCompanion(
      taskId: Value(taskId),
      labelId: Value(labelId),
      isDirty: Value(isDirty),
    );
  }

  factory TaskLabelRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskLabelRow(
      taskId: serializer.fromJson<int>(json['taskId']),
      labelId: serializer.fromJson<int>(json['labelId']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'taskId': serializer.toJson<int>(taskId),
      'labelId': serializer.toJson<int>(labelId),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  TaskLabelRow copyWith({int? taskId, int? labelId, bool? isDirty}) =>
      TaskLabelRow(
        taskId: taskId ?? this.taskId,
        labelId: labelId ?? this.labelId,
        isDirty: isDirty ?? this.isDirty,
      );
  TaskLabelRow copyWithCompanion(TaskLabelsCompanion data) {
    return TaskLabelRow(
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      labelId: data.labelId.present ? data.labelId.value : this.labelId,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskLabelRow(')
          ..write('taskId: $taskId, ')
          ..write('labelId: $labelId, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(taskId, labelId, isDirty);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskLabelRow &&
          other.taskId == this.taskId &&
          other.labelId == this.labelId &&
          other.isDirty == this.isDirty);
}

class TaskLabelsCompanion extends UpdateCompanion<TaskLabelRow> {
  final Value<int> taskId;
  final Value<int> labelId;
  final Value<bool> isDirty;
  final Value<int> rowid;
  const TaskLabelsCompanion({
    this.taskId = const Value.absent(),
    this.labelId = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskLabelsCompanion.insert({
    required int taskId,
    required int labelId,
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : taskId = Value(taskId),
       labelId = Value(labelId);
  static Insertable<TaskLabelRow> custom({
    Expression<int>? taskId,
    Expression<int>? labelId,
    Expression<bool>? isDirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (taskId != null) 'task_id': taskId,
      if (labelId != null) 'label_id': labelId,
      if (isDirty != null) 'is_dirty': isDirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskLabelsCompanion copyWith({
    Value<int>? taskId,
    Value<int>? labelId,
    Value<bool>? isDirty,
    Value<int>? rowid,
  }) {
    return TaskLabelsCompanion(
      taskId: taskId ?? this.taskId,
      labelId: labelId ?? this.labelId,
      isDirty: isDirty ?? this.isDirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (taskId.present) {
      map['task_id'] = Variable<int>(taskId.value);
    }
    if (labelId.present) {
      map['label_id'] = Variable<int>(labelId.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskLabelsCompanion(')
          ..write('taskId: $taskId, ')
          ..write('labelId: $labelId, ')
          ..write('isDirty: $isDirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaskAssigneesTable extends TaskAssignees
    with TableInfo<$TaskAssigneesTable, TaskAssigneeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskAssigneesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [taskId, userId, isDirty];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_assignees';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskAssigneeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {taskId, userId};
  @override
  TaskAssigneeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskAssigneeRow(
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}task_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
    );
  }

  @override
  $TaskAssigneesTable createAlias(String alias) {
    return $TaskAssigneesTable(attachedDatabase, alias);
  }
}

class TaskAssigneeRow extends DataClass implements Insertable<TaskAssigneeRow> {
  final int taskId;
  final int userId;
  final bool isDirty;
  const TaskAssigneeRow({
    required this.taskId,
    required this.userId,
    required this.isDirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['task_id'] = Variable<int>(taskId);
    map['user_id'] = Variable<int>(userId);
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }

  TaskAssigneesCompanion toCompanion(bool nullToAbsent) {
    return TaskAssigneesCompanion(
      taskId: Value(taskId),
      userId: Value(userId),
      isDirty: Value(isDirty),
    );
  }

  factory TaskAssigneeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskAssigneeRow(
      taskId: serializer.fromJson<int>(json['taskId']),
      userId: serializer.fromJson<int>(json['userId']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'taskId': serializer.toJson<int>(taskId),
      'userId': serializer.toJson<int>(userId),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  TaskAssigneeRow copyWith({int? taskId, int? userId, bool? isDirty}) =>
      TaskAssigneeRow(
        taskId: taskId ?? this.taskId,
        userId: userId ?? this.userId,
        isDirty: isDirty ?? this.isDirty,
      );
  TaskAssigneeRow copyWithCompanion(TaskAssigneesCompanion data) {
    return TaskAssigneeRow(
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      userId: data.userId.present ? data.userId.value : this.userId,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskAssigneeRow(')
          ..write('taskId: $taskId, ')
          ..write('userId: $userId, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(taskId, userId, isDirty);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskAssigneeRow &&
          other.taskId == this.taskId &&
          other.userId == this.userId &&
          other.isDirty == this.isDirty);
}

class TaskAssigneesCompanion extends UpdateCompanion<TaskAssigneeRow> {
  final Value<int> taskId;
  final Value<int> userId;
  final Value<bool> isDirty;
  final Value<int> rowid;
  const TaskAssigneesCompanion({
    this.taskId = const Value.absent(),
    this.userId = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskAssigneesCompanion.insert({
    required int taskId,
    required int userId,
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : taskId = Value(taskId),
       userId = Value(userId);
  static Insertable<TaskAssigneeRow> custom({
    Expression<int>? taskId,
    Expression<int>? userId,
    Expression<bool>? isDirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (taskId != null) 'task_id': taskId,
      if (userId != null) 'user_id': userId,
      if (isDirty != null) 'is_dirty': isDirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskAssigneesCompanion copyWith({
    Value<int>? taskId,
    Value<int>? userId,
    Value<bool>? isDirty,
    Value<int>? rowid,
  }) {
    return TaskAssigneesCompanion(
      taskId: taskId ?? this.taskId,
      userId: userId ?? this.userId,
      isDirty: isDirty ?? this.isDirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (taskId.present) {
      map['task_id'] = Variable<int>(taskId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskAssigneesCompanion(')
          ..write('taskId: $taskId, ')
          ..write('userId: $userId, ')
          ..write('isDirty: $isDirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaskCommentsTable extends TaskComments
    with TableInfo<$TaskCommentsTable, TaskCommentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskCommentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<int> remoteId = GeneratedColumn<int>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _updatedAtServerMeta = const VerificationMeta(
    'updatedAtServer',
  );
  @override
  late final GeneratedColumn<String> updatedAtServer = GeneratedColumn<String>(
    'updated_at_server',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<String> syncedAt = GeneratedColumn<String>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorJsonMeta = const VerificationMeta(
    'authorJson',
  );
  @override
  late final GeneratedColumn<String> authorJson = GeneratedColumn<String>(
    'author_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _commentMeta = const VerificationMeta(
    'comment',
  );
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
    'comment',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawJsonMeta = const VerificationMeta(
    'rawJson',
  );
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
    'raw_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    remoteId,
    updatedAtServer,
    isDirty,
    isDeleted,
    syncedAt,
    id,
    taskId,
    authorJson,
    comment,
    createdAt,
    rawJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_comments';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskCommentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('updated_at_server')) {
      context.handle(
        _updatedAtServerMeta,
        updatedAtServer.isAcceptableOrUnknown(
          data['updated_at_server']!,
          _updatedAtServerMeta,
        ),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('author_json')) {
      context.handle(
        _authorJsonMeta,
        authorJson.isAcceptableOrUnknown(data['author_json']!, _authorJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_authorJsonMeta);
    }
    if (data.containsKey('comment')) {
      context.handle(
        _commentMeta,
        comment.isAcceptableOrUnknown(data['comment']!, _commentMeta),
      );
    } else if (isInserting) {
      context.missing(_commentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('raw_json')) {
      context.handle(
        _rawJsonMeta,
        rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_rawJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskCommentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskCommentRow(
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remote_id'],
      ),
      updatedAtServer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_server'],
      ),
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}task_id'],
      )!,
      authorJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_json'],
      )!,
      comment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comment'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      rawJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_json'],
      )!,
    );
  }

  @override
  $TaskCommentsTable createAlias(String alias) {
    return $TaskCommentsTable(attachedDatabase, alias);
  }
}

class TaskCommentRow extends DataClass implements Insertable<TaskCommentRow> {
  final int? remoteId;
  final String? updatedAtServer;
  final bool isDirty;
  final bool isDeleted;
  final String? syncedAt;
  final int id;
  final int taskId;
  final String authorJson;
  final String comment;
  final String createdAt;
  final String rawJson;
  const TaskCommentRow({
    this.remoteId,
    this.updatedAtServer,
    required this.isDirty,
    required this.isDeleted,
    this.syncedAt,
    required this.id,
    required this.taskId,
    required this.authorJson,
    required this.comment,
    required this.createdAt,
    required this.rawJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<int>(remoteId);
    }
    if (!nullToAbsent || updatedAtServer != null) {
      map['updated_at_server'] = Variable<String>(updatedAtServer);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<String>(syncedAt);
    }
    map['id'] = Variable<int>(id);
    map['task_id'] = Variable<int>(taskId);
    map['author_json'] = Variable<String>(authorJson);
    map['comment'] = Variable<String>(comment);
    map['created_at'] = Variable<String>(createdAt);
    map['raw_json'] = Variable<String>(rawJson);
    return map;
  }

  TaskCommentsCompanion toCompanion(bool nullToAbsent) {
    return TaskCommentsCompanion(
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      updatedAtServer: updatedAtServer == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAtServer),
      isDirty: Value(isDirty),
      isDeleted: Value(isDeleted),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      id: Value(id),
      taskId: Value(taskId),
      authorJson: Value(authorJson),
      comment: Value(comment),
      createdAt: Value(createdAt),
      rawJson: Value(rawJson),
    );
  }

  factory TaskCommentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskCommentRow(
      remoteId: serializer.fromJson<int?>(json['remoteId']),
      updatedAtServer: serializer.fromJson<String?>(json['updatedAtServer']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      syncedAt: serializer.fromJson<String?>(json['syncedAt']),
      id: serializer.fromJson<int>(json['id']),
      taskId: serializer.fromJson<int>(json['taskId']),
      authorJson: serializer.fromJson<String>(json['authorJson']),
      comment: serializer.fromJson<String>(json['comment']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      rawJson: serializer.fromJson<String>(json['rawJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'remoteId': serializer.toJson<int?>(remoteId),
      'updatedAtServer': serializer.toJson<String?>(updatedAtServer),
      'isDirty': serializer.toJson<bool>(isDirty),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'syncedAt': serializer.toJson<String?>(syncedAt),
      'id': serializer.toJson<int>(id),
      'taskId': serializer.toJson<int>(taskId),
      'authorJson': serializer.toJson<String>(authorJson),
      'comment': serializer.toJson<String>(comment),
      'createdAt': serializer.toJson<String>(createdAt),
      'rawJson': serializer.toJson<String>(rawJson),
    };
  }

  TaskCommentRow copyWith({
    Value<int?> remoteId = const Value.absent(),
    Value<String?> updatedAtServer = const Value.absent(),
    bool? isDirty,
    bool? isDeleted,
    Value<String?> syncedAt = const Value.absent(),
    int? id,
    int? taskId,
    String? authorJson,
    String? comment,
    String? createdAt,
    String? rawJson,
  }) => TaskCommentRow(
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    updatedAtServer: updatedAtServer.present
        ? updatedAtServer.value
        : this.updatedAtServer,
    isDirty: isDirty ?? this.isDirty,
    isDeleted: isDeleted ?? this.isDeleted,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    authorJson: authorJson ?? this.authorJson,
    comment: comment ?? this.comment,
    createdAt: createdAt ?? this.createdAt,
    rawJson: rawJson ?? this.rawJson,
  );
  TaskCommentRow copyWithCompanion(TaskCommentsCompanion data) {
    return TaskCommentRow(
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      updatedAtServer: data.updatedAtServer.present
          ? data.updatedAtServer.value
          : this.updatedAtServer,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      authorJson: data.authorJson.present
          ? data.authorJson.value
          : this.authorJson,
      comment: data.comment.present ? data.comment.value : this.comment,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskCommentRow(')
          ..write('remoteId: $remoteId, ')
          ..write('updatedAtServer: $updatedAtServer, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('authorJson: $authorJson, ')
          ..write('comment: $comment, ')
          ..write('createdAt: $createdAt, ')
          ..write('rawJson: $rawJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    remoteId,
    updatedAtServer,
    isDirty,
    isDeleted,
    syncedAt,
    id,
    taskId,
    authorJson,
    comment,
    createdAt,
    rawJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskCommentRow &&
          other.remoteId == this.remoteId &&
          other.updatedAtServer == this.updatedAtServer &&
          other.isDirty == this.isDirty &&
          other.isDeleted == this.isDeleted &&
          other.syncedAt == this.syncedAt &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.authorJson == this.authorJson &&
          other.comment == this.comment &&
          other.createdAt == this.createdAt &&
          other.rawJson == this.rawJson);
}

class TaskCommentsCompanion extends UpdateCompanion<TaskCommentRow> {
  final Value<int?> remoteId;
  final Value<String?> updatedAtServer;
  final Value<bool> isDirty;
  final Value<bool> isDeleted;
  final Value<String?> syncedAt;
  final Value<int> id;
  final Value<int> taskId;
  final Value<String> authorJson;
  final Value<String> comment;
  final Value<String> createdAt;
  final Value<String> rawJson;
  const TaskCommentsCompanion({
    this.remoteId = const Value.absent(),
    this.updatedAtServer = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.authorJson = const Value.absent(),
    this.comment = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rawJson = const Value.absent(),
  });
  TaskCommentsCompanion.insert({
    this.remoteId = const Value.absent(),
    this.updatedAtServer = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.id = const Value.absent(),
    required int taskId,
    required String authorJson,
    required String comment,
    required String createdAt,
    required String rawJson,
  }) : taskId = Value(taskId),
       authorJson = Value(authorJson),
       comment = Value(comment),
       createdAt = Value(createdAt),
       rawJson = Value(rawJson);
  static Insertable<TaskCommentRow> custom({
    Expression<int>? remoteId,
    Expression<String>? updatedAtServer,
    Expression<bool>? isDirty,
    Expression<bool>? isDeleted,
    Expression<String>? syncedAt,
    Expression<int>? id,
    Expression<int>? taskId,
    Expression<String>? authorJson,
    Expression<String>? comment,
    Expression<String>? createdAt,
    Expression<String>? rawJson,
  }) {
    return RawValuesInsertable({
      if (remoteId != null) 'remote_id': remoteId,
      if (updatedAtServer != null) 'updated_at_server': updatedAtServer,
      if (isDirty != null) 'is_dirty': isDirty,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (authorJson != null) 'author_json': authorJson,
      if (comment != null) 'comment': comment,
      if (createdAt != null) 'created_at': createdAt,
      if (rawJson != null) 'raw_json': rawJson,
    });
  }

  TaskCommentsCompanion copyWith({
    Value<int?>? remoteId,
    Value<String?>? updatedAtServer,
    Value<bool>? isDirty,
    Value<bool>? isDeleted,
    Value<String?>? syncedAt,
    Value<int>? id,
    Value<int>? taskId,
    Value<String>? authorJson,
    Value<String>? comment,
    Value<String>? createdAt,
    Value<String>? rawJson,
  }) {
    return TaskCommentsCompanion(
      remoteId: remoteId ?? this.remoteId,
      updatedAtServer: updatedAtServer ?? this.updatedAtServer,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      syncedAt: syncedAt ?? this.syncedAt,
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      authorJson: authorJson ?? this.authorJson,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      rawJson: rawJson ?? this.rawJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (remoteId.present) {
      map['remote_id'] = Variable<int>(remoteId.value);
    }
    if (updatedAtServer.present) {
      map['updated_at_server'] = Variable<String>(updatedAtServer.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<String>(syncedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<int>(taskId.value);
    }
    if (authorJson.present) {
      map['author_json'] = Variable<String>(authorJson.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rawJson.present) {
      map['raw_json'] = Variable<String>(rawJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskCommentsCompanion(')
          ..write('remoteId: $remoteId, ')
          ..write('updatedAtServer: $updatedAtServer, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('authorJson: $authorJson, ')
          ..write('comment: $comment, ')
          ..write('createdAt: $createdAt, ')
          ..write('rawJson: $rawJson')
          ..write(')'))
        .toString();
  }
}

class $TaskAttachmentsTable extends TaskAttachments
    with TableInfo<$TaskAttachmentsTable, TaskAttachmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskAttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<int> remoteId = GeneratedColumn<int>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _updatedAtServerMeta = const VerificationMeta(
    'updatedAtServer',
  );
  @override
  late final GeneratedColumn<String> updatedAtServer = GeneratedColumn<String>(
    'updated_at_server',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<String> syncedAt = GeneratedColumn<String>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileJsonMeta = const VerificationMeta(
    'fileJson',
  );
  @override
  late final GeneratedColumn<String> fileJson = GeneratedColumn<String>(
    'file_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localFilePathMeta = const VerificationMeta(
    'localFilePath',
  );
  @override
  late final GeneratedColumn<String> localFilePath = GeneratedColumn<String>(
    'local_file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawJsonMeta = const VerificationMeta(
    'rawJson',
  );
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
    'raw_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    remoteId,
    updatedAtServer,
    isDirty,
    isDeleted,
    syncedAt,
    id,
    taskId,
    fileJson,
    localFilePath,
    rawJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskAttachmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('updated_at_server')) {
      context.handle(
        _updatedAtServerMeta,
        updatedAtServer.isAcceptableOrUnknown(
          data['updated_at_server']!,
          _updatedAtServerMeta,
        ),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('file_json')) {
      context.handle(
        _fileJsonMeta,
        fileJson.isAcceptableOrUnknown(data['file_json']!, _fileJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_fileJsonMeta);
    }
    if (data.containsKey('local_file_path')) {
      context.handle(
        _localFilePathMeta,
        localFilePath.isAcceptableOrUnknown(
          data['local_file_path']!,
          _localFilePathMeta,
        ),
      );
    }
    if (data.containsKey('raw_json')) {
      context.handle(
        _rawJsonMeta,
        rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_rawJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskAttachmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskAttachmentRow(
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remote_id'],
      ),
      updatedAtServer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_server'],
      ),
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}task_id'],
      )!,
      fileJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_json'],
      )!,
      localFilePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_file_path'],
      ),
      rawJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_json'],
      )!,
    );
  }

  @override
  $TaskAttachmentsTable createAlias(String alias) {
    return $TaskAttachmentsTable(attachedDatabase, alias);
  }
}

class TaskAttachmentRow extends DataClass
    implements Insertable<TaskAttachmentRow> {
  final int? remoteId;
  final String? updatedAtServer;
  final bool isDirty;
  final bool isDeleted;
  final String? syncedAt;
  final int id;
  final int taskId;
  final String fileJson;

  /// Pfad der lokal heruntergeladenen/erzeugten Datei, falls vorhanden.
  final String? localFilePath;
  final String rawJson;
  const TaskAttachmentRow({
    this.remoteId,
    this.updatedAtServer,
    required this.isDirty,
    required this.isDeleted,
    this.syncedAt,
    required this.id,
    required this.taskId,
    required this.fileJson,
    this.localFilePath,
    required this.rawJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<int>(remoteId);
    }
    if (!nullToAbsent || updatedAtServer != null) {
      map['updated_at_server'] = Variable<String>(updatedAtServer);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<String>(syncedAt);
    }
    map['id'] = Variable<int>(id);
    map['task_id'] = Variable<int>(taskId);
    map['file_json'] = Variable<String>(fileJson);
    if (!nullToAbsent || localFilePath != null) {
      map['local_file_path'] = Variable<String>(localFilePath);
    }
    map['raw_json'] = Variable<String>(rawJson);
    return map;
  }

  TaskAttachmentsCompanion toCompanion(bool nullToAbsent) {
    return TaskAttachmentsCompanion(
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      updatedAtServer: updatedAtServer == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAtServer),
      isDirty: Value(isDirty),
      isDeleted: Value(isDeleted),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      id: Value(id),
      taskId: Value(taskId),
      fileJson: Value(fileJson),
      localFilePath: localFilePath == null && nullToAbsent
          ? const Value.absent()
          : Value(localFilePath),
      rawJson: Value(rawJson),
    );
  }

  factory TaskAttachmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskAttachmentRow(
      remoteId: serializer.fromJson<int?>(json['remoteId']),
      updatedAtServer: serializer.fromJson<String?>(json['updatedAtServer']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      syncedAt: serializer.fromJson<String?>(json['syncedAt']),
      id: serializer.fromJson<int>(json['id']),
      taskId: serializer.fromJson<int>(json['taskId']),
      fileJson: serializer.fromJson<String>(json['fileJson']),
      localFilePath: serializer.fromJson<String?>(json['localFilePath']),
      rawJson: serializer.fromJson<String>(json['rawJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'remoteId': serializer.toJson<int?>(remoteId),
      'updatedAtServer': serializer.toJson<String?>(updatedAtServer),
      'isDirty': serializer.toJson<bool>(isDirty),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'syncedAt': serializer.toJson<String?>(syncedAt),
      'id': serializer.toJson<int>(id),
      'taskId': serializer.toJson<int>(taskId),
      'fileJson': serializer.toJson<String>(fileJson),
      'localFilePath': serializer.toJson<String?>(localFilePath),
      'rawJson': serializer.toJson<String>(rawJson),
    };
  }

  TaskAttachmentRow copyWith({
    Value<int?> remoteId = const Value.absent(),
    Value<String?> updatedAtServer = const Value.absent(),
    bool? isDirty,
    bool? isDeleted,
    Value<String?> syncedAt = const Value.absent(),
    int? id,
    int? taskId,
    String? fileJson,
    Value<String?> localFilePath = const Value.absent(),
    String? rawJson,
  }) => TaskAttachmentRow(
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    updatedAtServer: updatedAtServer.present
        ? updatedAtServer.value
        : this.updatedAtServer,
    isDirty: isDirty ?? this.isDirty,
    isDeleted: isDeleted ?? this.isDeleted,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    fileJson: fileJson ?? this.fileJson,
    localFilePath: localFilePath.present
        ? localFilePath.value
        : this.localFilePath,
    rawJson: rawJson ?? this.rawJson,
  );
  TaskAttachmentRow copyWithCompanion(TaskAttachmentsCompanion data) {
    return TaskAttachmentRow(
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      updatedAtServer: data.updatedAtServer.present
          ? data.updatedAtServer.value
          : this.updatedAtServer,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      fileJson: data.fileJson.present ? data.fileJson.value : this.fileJson,
      localFilePath: data.localFilePath.present
          ? data.localFilePath.value
          : this.localFilePath,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskAttachmentRow(')
          ..write('remoteId: $remoteId, ')
          ..write('updatedAtServer: $updatedAtServer, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('fileJson: $fileJson, ')
          ..write('localFilePath: $localFilePath, ')
          ..write('rawJson: $rawJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    remoteId,
    updatedAtServer,
    isDirty,
    isDeleted,
    syncedAt,
    id,
    taskId,
    fileJson,
    localFilePath,
    rawJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskAttachmentRow &&
          other.remoteId == this.remoteId &&
          other.updatedAtServer == this.updatedAtServer &&
          other.isDirty == this.isDirty &&
          other.isDeleted == this.isDeleted &&
          other.syncedAt == this.syncedAt &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.fileJson == this.fileJson &&
          other.localFilePath == this.localFilePath &&
          other.rawJson == this.rawJson);
}

class TaskAttachmentsCompanion extends UpdateCompanion<TaskAttachmentRow> {
  final Value<int?> remoteId;
  final Value<String?> updatedAtServer;
  final Value<bool> isDirty;
  final Value<bool> isDeleted;
  final Value<String?> syncedAt;
  final Value<int> id;
  final Value<int> taskId;
  final Value<String> fileJson;
  final Value<String?> localFilePath;
  final Value<String> rawJson;
  const TaskAttachmentsCompanion({
    this.remoteId = const Value.absent(),
    this.updatedAtServer = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.fileJson = const Value.absent(),
    this.localFilePath = const Value.absent(),
    this.rawJson = const Value.absent(),
  });
  TaskAttachmentsCompanion.insert({
    this.remoteId = const Value.absent(),
    this.updatedAtServer = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.id = const Value.absent(),
    required int taskId,
    required String fileJson,
    this.localFilePath = const Value.absent(),
    required String rawJson,
  }) : taskId = Value(taskId),
       fileJson = Value(fileJson),
       rawJson = Value(rawJson);
  static Insertable<TaskAttachmentRow> custom({
    Expression<int>? remoteId,
    Expression<String>? updatedAtServer,
    Expression<bool>? isDirty,
    Expression<bool>? isDeleted,
    Expression<String>? syncedAt,
    Expression<int>? id,
    Expression<int>? taskId,
    Expression<String>? fileJson,
    Expression<String>? localFilePath,
    Expression<String>? rawJson,
  }) {
    return RawValuesInsertable({
      if (remoteId != null) 'remote_id': remoteId,
      if (updatedAtServer != null) 'updated_at_server': updatedAtServer,
      if (isDirty != null) 'is_dirty': isDirty,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (fileJson != null) 'file_json': fileJson,
      if (localFilePath != null) 'local_file_path': localFilePath,
      if (rawJson != null) 'raw_json': rawJson,
    });
  }

  TaskAttachmentsCompanion copyWith({
    Value<int?>? remoteId,
    Value<String?>? updatedAtServer,
    Value<bool>? isDirty,
    Value<bool>? isDeleted,
    Value<String?>? syncedAt,
    Value<int>? id,
    Value<int>? taskId,
    Value<String>? fileJson,
    Value<String?>? localFilePath,
    Value<String>? rawJson,
  }) {
    return TaskAttachmentsCompanion(
      remoteId: remoteId ?? this.remoteId,
      updatedAtServer: updatedAtServer ?? this.updatedAtServer,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      syncedAt: syncedAt ?? this.syncedAt,
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      fileJson: fileJson ?? this.fileJson,
      localFilePath: localFilePath ?? this.localFilePath,
      rawJson: rawJson ?? this.rawJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (remoteId.present) {
      map['remote_id'] = Variable<int>(remoteId.value);
    }
    if (updatedAtServer.present) {
      map['updated_at_server'] = Variable<String>(updatedAtServer.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<String>(syncedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<int>(taskId.value);
    }
    if (fileJson.present) {
      map['file_json'] = Variable<String>(fileJson.value);
    }
    if (localFilePath.present) {
      map['local_file_path'] = Variable<String>(localFilePath.value);
    }
    if (rawJson.present) {
      map['raw_json'] = Variable<String>(rawJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskAttachmentsCompanion(')
          ..write('remoteId: $remoteId, ')
          ..write('updatedAtServer: $updatedAtServer, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('fileJson: $fileJson, ')
          ..write('localFilePath: $localFilePath, ')
          ..write('rawJson: $rawJson')
          ..write(')'))
        .toString();
  }
}

class $KeyValuesTable extends KeyValues
    with TableInfo<$KeyValuesTable, KeyValueRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KeyValuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'key_values';
  @override
  VerificationContext validateIntegrity(
    Insertable<KeyValueRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  KeyValueRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KeyValueRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $KeyValuesTable createAlias(String alias) {
    return $KeyValuesTable(attachedDatabase, alias);
  }
}

class KeyValueRow extends DataClass implements Insertable<KeyValueRow> {
  final String key;
  final String value;
  const KeyValueRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  KeyValuesCompanion toCompanion(bool nullToAbsent) {
    return KeyValuesCompanion(key: Value(key), value: Value(value));
  }

  factory KeyValueRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KeyValueRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  KeyValueRow copyWith({String? key, String? value}) =>
      KeyValueRow(key: key ?? this.key, value: value ?? this.value);
  KeyValueRow copyWithCompanion(KeyValuesCompanion data) {
    return KeyValueRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KeyValueRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KeyValueRow &&
          other.key == this.key &&
          other.value == this.value);
}

class KeyValuesCompanion extends UpdateCompanion<KeyValueRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const KeyValuesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KeyValuesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<KeyValueRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KeyValuesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return KeyValuesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KeyValuesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingOpsTable extends PendingOps
    with TableInfo<$PendingOpsTable, PendingOpRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingOpsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<int> opId = GeneratedColumn<int>(
    'op_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opTypeMeta = const VerificationMeta('opType');
  @override
  late final GeneratedColumn<String> opType = GeneratedColumn<String>(
    'op_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localFilePathsJsonMeta =
      const VerificationMeta('localFilePathsJson');
  @override
  late final GeneratedColumn<String> localFilePathsJson =
      GeneratedColumn<String>(
        'local_file_paths_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    opId,
    entityType,
    localId,
    opType,
    payloadJson,
    localFilePathsJson,
    createdAt,
    retryCount,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_ops';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingOpRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('op_id')) {
      context.handle(
        _opIdMeta,
        opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta),
      );
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('op_type')) {
      context.handle(
        _opTypeMeta,
        opType.isAcceptableOrUnknown(data['op_type']!, _opTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_opTypeMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('local_file_paths_json')) {
      context.handle(
        _localFilePathsJsonMeta,
        localFilePathsJson.isAcceptableOrUnknown(
          data['local_file_paths_json']!,
          _localFilePathsJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {opId};
  @override
  PendingOpRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingOpRow(
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}op_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_id'],
      )!,
      opType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_type'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      localFilePathsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_file_paths_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $PendingOpsTable createAlias(String alias) {
    return $PendingOpsTable(attachedDatabase, alias);
  }
}

class PendingOpRow extends DataClass implements Insertable<PendingOpRow> {
  final int opId;
  final String entityType;
  final int localId;
  final String opType;
  final String payloadJson;
  final String? localFilePathsJson;
  final String createdAt;
  final int retryCount;
  final String? lastError;
  const PendingOpRow({
    required this.opId,
    required this.entityType,
    required this.localId,
    required this.opType,
    required this.payloadJson,
    this.localFilePathsJson,
    required this.createdAt,
    required this.retryCount,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['op_id'] = Variable<int>(opId);
    map['entity_type'] = Variable<String>(entityType);
    map['local_id'] = Variable<int>(localId);
    map['op_type'] = Variable<String>(opType);
    map['payload_json'] = Variable<String>(payloadJson);
    if (!nullToAbsent || localFilePathsJson != null) {
      map['local_file_paths_json'] = Variable<String>(localFilePathsJson);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  PendingOpsCompanion toCompanion(bool nullToAbsent) {
    return PendingOpsCompanion(
      opId: Value(opId),
      entityType: Value(entityType),
      localId: Value(localId),
      opType: Value(opType),
      payloadJson: Value(payloadJson),
      localFilePathsJson: localFilePathsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(localFilePathsJson),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory PendingOpRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingOpRow(
      opId: serializer.fromJson<int>(json['opId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      localId: serializer.fromJson<int>(json['localId']),
      opType: serializer.fromJson<String>(json['opType']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      localFilePathsJson: serializer.fromJson<String?>(
        json['localFilePathsJson'],
      ),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'opId': serializer.toJson<int>(opId),
      'entityType': serializer.toJson<String>(entityType),
      'localId': serializer.toJson<int>(localId),
      'opType': serializer.toJson<String>(opType),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'localFilePathsJson': serializer.toJson<String?>(localFilePathsJson),
      'createdAt': serializer.toJson<String>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  PendingOpRow copyWith({
    int? opId,
    String? entityType,
    int? localId,
    String? opType,
    String? payloadJson,
    Value<String?> localFilePathsJson = const Value.absent(),
    String? createdAt,
    int? retryCount,
    Value<String?> lastError = const Value.absent(),
  }) => PendingOpRow(
    opId: opId ?? this.opId,
    entityType: entityType ?? this.entityType,
    localId: localId ?? this.localId,
    opType: opType ?? this.opType,
    payloadJson: payloadJson ?? this.payloadJson,
    localFilePathsJson: localFilePathsJson.present
        ? localFilePathsJson.value
        : this.localFilePathsJson,
    createdAt: createdAt ?? this.createdAt,
    retryCount: retryCount ?? this.retryCount,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  PendingOpRow copyWithCompanion(PendingOpsCompanion data) {
    return PendingOpRow(
      opId: data.opId.present ? data.opId.value : this.opId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      localId: data.localId.present ? data.localId.value : this.localId,
      opType: data.opType.present ? data.opType.value : this.opType,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      localFilePathsJson: data.localFilePathsJson.present
          ? data.localFilePathsJson.value
          : this.localFilePathsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingOpRow(')
          ..write('opId: $opId, ')
          ..write('entityType: $entityType, ')
          ..write('localId: $localId, ')
          ..write('opType: $opType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('localFilePathsJson: $localFilePathsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    opId,
    entityType,
    localId,
    opType,
    payloadJson,
    localFilePathsJson,
    createdAt,
    retryCount,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingOpRow &&
          other.opId == this.opId &&
          other.entityType == this.entityType &&
          other.localId == this.localId &&
          other.opType == this.opType &&
          other.payloadJson == this.payloadJson &&
          other.localFilePathsJson == this.localFilePathsJson &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError);
}

class PendingOpsCompanion extends UpdateCompanion<PendingOpRow> {
  final Value<int> opId;
  final Value<String> entityType;
  final Value<int> localId;
  final Value<String> opType;
  final Value<String> payloadJson;
  final Value<String?> localFilePathsJson;
  final Value<String> createdAt;
  final Value<int> retryCount;
  final Value<String?> lastError;
  const PendingOpsCompanion({
    this.opId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.localId = const Value.absent(),
    this.opType = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.localFilePathsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  PendingOpsCompanion.insert({
    this.opId = const Value.absent(),
    required String entityType,
    required int localId,
    required String opType,
    required String payloadJson,
    this.localFilePathsJson = const Value.absent(),
    required String createdAt,
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
  }) : entityType = Value(entityType),
       localId = Value(localId),
       opType = Value(opType),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt);
  static Insertable<PendingOpRow> custom({
    Expression<int>? opId,
    Expression<String>? entityType,
    Expression<int>? localId,
    Expression<String>? opType,
    Expression<String>? payloadJson,
    Expression<String>? localFilePathsJson,
    Expression<String>? createdAt,
    Expression<int>? retryCount,
    Expression<String>? lastError,
  }) {
    return RawValuesInsertable({
      if (opId != null) 'op_id': opId,
      if (entityType != null) 'entity_type': entityType,
      if (localId != null) 'local_id': localId,
      if (opType != null) 'op_type': opType,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (localFilePathsJson != null)
        'local_file_paths_json': localFilePathsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
    });
  }

  PendingOpsCompanion copyWith({
    Value<int>? opId,
    Value<String>? entityType,
    Value<int>? localId,
    Value<String>? opType,
    Value<String>? payloadJson,
    Value<String?>? localFilePathsJson,
    Value<String>? createdAt,
    Value<int>? retryCount,
    Value<String?>? lastError,
  }) {
    return PendingOpsCompanion(
      opId: opId ?? this.opId,
      entityType: entityType ?? this.entityType,
      localId: localId ?? this.localId,
      opType: opType ?? this.opType,
      payloadJson: payloadJson ?? this.payloadJson,
      localFilePathsJson: localFilePathsJson ?? this.localFilePathsJson,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (opId.present) {
      map['op_id'] = Variable<int>(opId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (opType.present) {
      map['op_type'] = Variable<String>(opType.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (localFilePathsJson.present) {
      map['local_file_paths_json'] = Variable<String>(localFilePathsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingOpsCompanion(')
          ..write('opId: $opId, ')
          ..write('entityType: $entityType, ')
          ..write('localId: $localId, ')
          ..write('opType: $opType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('localFilePathsJson: $localFilePathsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }
}

class $ImageCachesTable extends ImageCaches
    with TableInfo<$ImageCachesTable, ImageCacheRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImageCachesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _urlHashMeta = const VerificationMeta(
    'urlHash',
  );
  @override
  late final GeneratedColumn<String> urlHash = GeneratedColumn<String>(
    'url_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<String> fetchedAt = GeneratedColumn<String>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [urlHash, filePath, fetchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'image_caches';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImageCacheRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('url_hash')) {
      context.handle(
        _urlHashMeta,
        urlHash.isAcceptableOrUnknown(data['url_hash']!, _urlHashMeta),
      );
    } else if (isInserting) {
      context.missing(_urlHashMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {urlHash};
  @override
  ImageCacheRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImageCacheRow(
      urlHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url_hash'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $ImageCachesTable createAlias(String alias) {
    return $ImageCachesTable(attachedDatabase, alias);
  }
}

class ImageCacheRow extends DataClass implements Insertable<ImageCacheRow> {
  final String urlHash;
  final String filePath;
  final String fetchedAt;
  const ImageCacheRow({
    required this.urlHash,
    required this.filePath,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['url_hash'] = Variable<String>(urlHash);
    map['file_path'] = Variable<String>(filePath);
    map['fetched_at'] = Variable<String>(fetchedAt);
    return map;
  }

  ImageCachesCompanion toCompanion(bool nullToAbsent) {
    return ImageCachesCompanion(
      urlHash: Value(urlHash),
      filePath: Value(filePath),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory ImageCacheRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImageCacheRow(
      urlHash: serializer.fromJson<String>(json['urlHash']),
      filePath: serializer.fromJson<String>(json['filePath']),
      fetchedAt: serializer.fromJson<String>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'urlHash': serializer.toJson<String>(urlHash),
      'filePath': serializer.toJson<String>(filePath),
      'fetchedAt': serializer.toJson<String>(fetchedAt),
    };
  }

  ImageCacheRow copyWith({
    String? urlHash,
    String? filePath,
    String? fetchedAt,
  }) => ImageCacheRow(
    urlHash: urlHash ?? this.urlHash,
    filePath: filePath ?? this.filePath,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  ImageCacheRow copyWithCompanion(ImageCachesCompanion data) {
    return ImageCacheRow(
      urlHash: data.urlHash.present ? data.urlHash.value : this.urlHash,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImageCacheRow(')
          ..write('urlHash: $urlHash, ')
          ..write('filePath: $filePath, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(urlHash, filePath, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImageCacheRow &&
          other.urlHash == this.urlHash &&
          other.filePath == this.filePath &&
          other.fetchedAt == this.fetchedAt);
}

class ImageCachesCompanion extends UpdateCompanion<ImageCacheRow> {
  final Value<String> urlHash;
  final Value<String> filePath;
  final Value<String> fetchedAt;
  final Value<int> rowid;
  const ImageCachesCompanion({
    this.urlHash = const Value.absent(),
    this.filePath = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImageCachesCompanion.insert({
    required String urlHash,
    required String filePath,
    required String fetchedAt,
    this.rowid = const Value.absent(),
  }) : urlHash = Value(urlHash),
       filePath = Value(filePath),
       fetchedAt = Value(fetchedAt);
  static Insertable<ImageCacheRow> custom({
    Expression<String>? urlHash,
    Expression<String>? filePath,
    Expression<String>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (urlHash != null) 'url_hash': urlHash,
      if (filePath != null) 'file_path': filePath,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImageCachesCompanion copyWith({
    Value<String>? urlHash,
    Value<String>? filePath,
    Value<String>? fetchedAt,
    Value<int>? rowid,
  }) {
    return ImageCachesCompanion(
      urlHash: urlHash ?? this.urlHash,
      filePath: filePath ?? this.filePath,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (urlHash.present) {
      map['url_hash'] = Variable<String>(urlHash.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<String>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImageCachesCompanion(')
          ..write('urlHash: $urlHash, ')
          ..write('filePath: $filePath, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $LabelsTable labels = $LabelsTable(this);
  late final $UsersTable users = $UsersTable(this);
  late final $BucketsTable buckets = $BucketsTable(this);
  late final $TaskLabelsTable taskLabels = $TaskLabelsTable(this);
  late final $TaskAssigneesTable taskAssignees = $TaskAssigneesTable(this);
  late final $TaskCommentsTable taskComments = $TaskCommentsTable(this);
  late final $TaskAttachmentsTable taskAttachments = $TaskAttachmentsTable(
    this,
  );
  late final $KeyValuesTable keyValues = $KeyValuesTable(this);
  late final $PendingOpsTable pendingOps = $PendingOpsTable(this);
  late final $ImageCachesTable imageCaches = $ImageCachesTable(this);
  late final ProjectsDao projectsDao = ProjectsDao(this as AppDatabase);
  late final TasksDao tasksDao = TasksDao(this as AppDatabase);
  late final LabelsDao labelsDao = LabelsDao(this as AppDatabase);
  late final UsersDao usersDao = UsersDao(this as AppDatabase);
  late final BucketsDao bucketsDao = BucketsDao(this as AppDatabase);
  late final TaskLabelsDao taskLabelsDao = TaskLabelsDao(this as AppDatabase);
  late final TaskAssigneesDao taskAssigneesDao = TaskAssigneesDao(
    this as AppDatabase,
  );
  late final TaskCommentsDao taskCommentsDao = TaskCommentsDao(
    this as AppDatabase,
  );
  late final TaskAttachmentsDao taskAttachmentsDao = TaskAttachmentsDao(
    this as AppDatabase,
  );
  late final KeyValueDao keyValueDao = KeyValueDao(this as AppDatabase);
  late final PendingOpsDao pendingOpsDao = PendingOpsDao(this as AppDatabase);
  late final ImageCacheDao imageCacheDao = ImageCacheDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    projects,
    tasks,
    labels,
    users,
    buckets,
    taskLabels,
    taskAssignees,
    taskComments,
    taskAttachments,
    keyValues,
    pendingOps,
    imageCaches,
  ];
}

typedef $$ProjectsTableCreateCompanionBuilder =
    ProjectsCompanion Function({
      Value<int?> remoteId,
      Value<String?> updatedAtServer,
      Value<bool> isDirty,
      Value<bool> isDeleted,
      Value<String?> syncedAt,
      Value<int> id,
      required String title,
      Value<String> description,
      Value<int?> parentProjectId,
      Value<double> position,
      Value<bool> isFavourite,
      Value<String?> hexColor,
      Value<String> viewsJson,
      Value<String?> ownerJson,
      required String rawJson,
    });
typedef $$ProjectsTableUpdateCompanionBuilder =
    ProjectsCompanion Function({
      Value<int?> remoteId,
      Value<String?> updatedAtServer,
      Value<bool> isDirty,
      Value<bool> isDeleted,
      Value<String?> syncedAt,
      Value<int> id,
      Value<String> title,
      Value<String> description,
      Value<int?> parentProjectId,
      Value<double> position,
      Value<bool> isFavourite,
      Value<String?> hexColor,
      Value<String> viewsJson,
      Value<String?> ownerJson,
      Value<String> rawJson,
    });

class $$ProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAtServer => $composableBuilder(
    column: $table.updatedAtServer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parentProjectId => $composableBuilder(
    column: $table.parentProjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavourite => $composableBuilder(
    column: $table.isFavourite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hexColor => $composableBuilder(
    column: $table.hexColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get viewsJson => $composableBuilder(
    column: $table.viewsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerJson => $composableBuilder(
    column: $table.ownerJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAtServer => $composableBuilder(
    column: $table.updatedAtServer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parentProjectId => $composableBuilder(
    column: $table.parentProjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavourite => $composableBuilder(
    column: $table.isFavourite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hexColor => $composableBuilder(
    column: $table.hexColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get viewsJson => $composableBuilder(
    column: $table.viewsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerJson => $composableBuilder(
    column: $table.ownerJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get updatedAtServer => $composableBuilder(
    column: $table.updatedAtServer,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get parentProjectId => $composableBuilder(
    column: $table.parentProjectId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<bool> get isFavourite => $composableBuilder(
    column: $table.isFavourite,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hexColor =>
      $composableBuilder(column: $table.hexColor, builder: (column) => column);

  GeneratedColumn<String> get viewsJson =>
      $composableBuilder(column: $table.viewsJson, builder: (column) => column);

  GeneratedColumn<String> get ownerJson =>
      $composableBuilder(column: $table.ownerJson, builder: (column) => column);

  GeneratedColumn<String> get rawJson =>
      $composableBuilder(column: $table.rawJson, builder: (column) => column);
}

class $$ProjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectsTable,
          ProjectRow,
          $$ProjectsTableFilterComposer,
          $$ProjectsTableOrderingComposer,
          $$ProjectsTableAnnotationComposer,
          $$ProjectsTableCreateCompanionBuilder,
          $$ProjectsTableUpdateCompanionBuilder,
          (
            ProjectRow,
            BaseReferences<_$AppDatabase, $ProjectsTable, ProjectRow>,
          ),
          ProjectRow,
          PrefetchHooks Function()
        > {
  $$ProjectsTableTableManager(_$AppDatabase db, $ProjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int?> remoteId = const Value.absent(),
                Value<String?> updatedAtServer = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int?> parentProjectId = const Value.absent(),
                Value<double> position = const Value.absent(),
                Value<bool> isFavourite = const Value.absent(),
                Value<String?> hexColor = const Value.absent(),
                Value<String> viewsJson = const Value.absent(),
                Value<String?> ownerJson = const Value.absent(),
                Value<String> rawJson = const Value.absent(),
              }) => ProjectsCompanion(
                remoteId: remoteId,
                updatedAtServer: updatedAtServer,
                isDirty: isDirty,
                isDeleted: isDeleted,
                syncedAt: syncedAt,
                id: id,
                title: title,
                description: description,
                parentProjectId: parentProjectId,
                position: position,
                isFavourite: isFavourite,
                hexColor: hexColor,
                viewsJson: viewsJson,
                ownerJson: ownerJson,
                rawJson: rawJson,
              ),
          createCompanionCallback:
              ({
                Value<int?> remoteId = const Value.absent(),
                Value<String?> updatedAtServer = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                required String title,
                Value<String> description = const Value.absent(),
                Value<int?> parentProjectId = const Value.absent(),
                Value<double> position = const Value.absent(),
                Value<bool> isFavourite = const Value.absent(),
                Value<String?> hexColor = const Value.absent(),
                Value<String> viewsJson = const Value.absent(),
                Value<String?> ownerJson = const Value.absent(),
                required String rawJson,
              }) => ProjectsCompanion.insert(
                remoteId: remoteId,
                updatedAtServer: updatedAtServer,
                isDirty: isDirty,
                isDeleted: isDeleted,
                syncedAt: syncedAt,
                id: id,
                title: title,
                description: description,
                parentProjectId: parentProjectId,
                position: position,
                isFavourite: isFavourite,
                hexColor: hexColor,
                viewsJson: viewsJson,
                ownerJson: ownerJson,
                rawJson: rawJson,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectsTable,
      ProjectRow,
      $$ProjectsTableFilterComposer,
      $$ProjectsTableOrderingComposer,
      $$ProjectsTableAnnotationComposer,
      $$ProjectsTableCreateCompanionBuilder,
      $$ProjectsTableUpdateCompanionBuilder,
      (ProjectRow, BaseReferences<_$AppDatabase, $ProjectsTable, ProjectRow>),
      ProjectRow,
      PrefetchHooks Function()
    >;
typedef $$TasksTableCreateCompanionBuilder =
    TasksCompanion Function({
      Value<int?> remoteId,
      Value<String?> updatedAtServer,
      Value<bool> isDirty,
      Value<bool> isDeleted,
      Value<String?> syncedAt,
      Value<int> id,
      required int projectId,
      Value<int?> bucketId,
      required String title,
      Value<String> description,
      Value<bool> done,
      Value<String?> doneAt,
      Value<String?> dueDate,
      Value<String?> startDate,
      Value<String?> endDate,
      Value<int?> priority,
      Value<double?> percentDone,
      Value<double?> position,
      Value<double?> kanbanPosition,
      Value<String> identifier,
      required String createdAt,
      required String updatedAt,
      required String rawJson,
    });
typedef $$TasksTableUpdateCompanionBuilder =
    TasksCompanion Function({
      Value<int?> remoteId,
      Value<String?> updatedAtServer,
      Value<bool> isDirty,
      Value<bool> isDeleted,
      Value<String?> syncedAt,
      Value<int> id,
      Value<int> projectId,
      Value<int?> bucketId,
      Value<String> title,
      Value<String> description,
      Value<bool> done,
      Value<String?> doneAt,
      Value<String?> dueDate,
      Value<String?> startDate,
      Value<String?> endDate,
      Value<int?> priority,
      Value<double?> percentDone,
      Value<double?> position,
      Value<double?> kanbanPosition,
      Value<String> identifier,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String> rawJson,
    });

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAtServer => $composableBuilder(
    column: $table.updatedAtServer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bucketId => $composableBuilder(
    column: $table.bucketId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doneAt => $composableBuilder(
    column: $table.doneAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get percentDone => $composableBuilder(
    column: $table.percentDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kanbanPosition => $composableBuilder(
    column: $table.kanbanPosition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get identifier => $composableBuilder(
    column: $table.identifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAtServer => $composableBuilder(
    column: $table.updatedAtServer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bucketId => $composableBuilder(
    column: $table.bucketId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doneAt => $composableBuilder(
    column: $table.doneAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get percentDone => $composableBuilder(
    column: $table.percentDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kanbanPosition => $composableBuilder(
    column: $table.kanbanPosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get identifier => $composableBuilder(
    column: $table.identifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get updatedAtServer => $composableBuilder(
    column: $table.updatedAtServer,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<int> get bucketId =>
      $composableBuilder(column: $table.bucketId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get done =>
      $composableBuilder(column: $table.done, builder: (column) => column);

  GeneratedColumn<String> get doneAt =>
      $composableBuilder(column: $table.doneAt, builder: (column) => column);

  GeneratedColumn<String> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<double> get percentDone => $composableBuilder(
    column: $table.percentDone,
    builder: (column) => column,
  );

  GeneratedColumn<double> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<double> get kanbanPosition => $composableBuilder(
    column: $table.kanbanPosition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get identifier => $composableBuilder(
    column: $table.identifier,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get rawJson =>
      $composableBuilder(column: $table.rawJson, builder: (column) => column);
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          TaskRow,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (TaskRow, BaseReferences<_$AppDatabase, $TasksTable, TaskRow>),
          TaskRow,
          PrefetchHooks Function()
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int?> remoteId = const Value.absent(),
                Value<String?> updatedAtServer = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<int> projectId = const Value.absent(),
                Value<int?> bucketId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<String?> doneAt = const Value.absent(),
                Value<String?> dueDate = const Value.absent(),
                Value<String?> startDate = const Value.absent(),
                Value<String?> endDate = const Value.absent(),
                Value<int?> priority = const Value.absent(),
                Value<double?> percentDone = const Value.absent(),
                Value<double?> position = const Value.absent(),
                Value<double?> kanbanPosition = const Value.absent(),
                Value<String> identifier = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String> rawJson = const Value.absent(),
              }) => TasksCompanion(
                remoteId: remoteId,
                updatedAtServer: updatedAtServer,
                isDirty: isDirty,
                isDeleted: isDeleted,
                syncedAt: syncedAt,
                id: id,
                projectId: projectId,
                bucketId: bucketId,
                title: title,
                description: description,
                done: done,
                doneAt: doneAt,
                dueDate: dueDate,
                startDate: startDate,
                endDate: endDate,
                priority: priority,
                percentDone: percentDone,
                position: position,
                kanbanPosition: kanbanPosition,
                identifier: identifier,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rawJson: rawJson,
              ),
          createCompanionCallback:
              ({
                Value<int?> remoteId = const Value.absent(),
                Value<String?> updatedAtServer = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                required int projectId,
                Value<int?> bucketId = const Value.absent(),
                required String title,
                Value<String> description = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<String?> doneAt = const Value.absent(),
                Value<String?> dueDate = const Value.absent(),
                Value<String?> startDate = const Value.absent(),
                Value<String?> endDate = const Value.absent(),
                Value<int?> priority = const Value.absent(),
                Value<double?> percentDone = const Value.absent(),
                Value<double?> position = const Value.absent(),
                Value<double?> kanbanPosition = const Value.absent(),
                Value<String> identifier = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                required String rawJson,
              }) => TasksCompanion.insert(
                remoteId: remoteId,
                updatedAtServer: updatedAtServer,
                isDirty: isDirty,
                isDeleted: isDeleted,
                syncedAt: syncedAt,
                id: id,
                projectId: projectId,
                bucketId: bucketId,
                title: title,
                description: description,
                done: done,
                doneAt: doneAt,
                dueDate: dueDate,
                startDate: startDate,
                endDate: endDate,
                priority: priority,
                percentDone: percentDone,
                position: position,
                kanbanPosition: kanbanPosition,
                identifier: identifier,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rawJson: rawJson,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      TaskRow,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (TaskRow, BaseReferences<_$AppDatabase, $TasksTable, TaskRow>),
      TaskRow,
      PrefetchHooks Function()
    >;
typedef $$LabelsTableCreateCompanionBuilder =
    LabelsCompanion Function({
      Value<int?> remoteId,
      Value<String?> updatedAtServer,
      Value<bool> isDirty,
      Value<bool> isDeleted,
      Value<String?> syncedAt,
      Value<int> id,
      required String title,
      Value<String?> hexColor,
      required String rawJson,
    });
typedef $$LabelsTableUpdateCompanionBuilder =
    LabelsCompanion Function({
      Value<int?> remoteId,
      Value<String?> updatedAtServer,
      Value<bool> isDirty,
      Value<bool> isDeleted,
      Value<String?> syncedAt,
      Value<int> id,
      Value<String> title,
      Value<String?> hexColor,
      Value<String> rawJson,
    });

class $$LabelsTableFilterComposer
    extends Composer<_$AppDatabase, $LabelsTable> {
  $$LabelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAtServer => $composableBuilder(
    column: $table.updatedAtServer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hexColor => $composableBuilder(
    column: $table.hexColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LabelsTableOrderingComposer
    extends Composer<_$AppDatabase, $LabelsTable> {
  $$LabelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAtServer => $composableBuilder(
    column: $table.updatedAtServer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hexColor => $composableBuilder(
    column: $table.hexColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LabelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LabelsTable> {
  $$LabelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get updatedAtServer => $composableBuilder(
    column: $table.updatedAtServer,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get hexColor =>
      $composableBuilder(column: $table.hexColor, builder: (column) => column);

  GeneratedColumn<String> get rawJson =>
      $composableBuilder(column: $table.rawJson, builder: (column) => column);
}

class $$LabelsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LabelsTable,
          LabelRow,
          $$LabelsTableFilterComposer,
          $$LabelsTableOrderingComposer,
          $$LabelsTableAnnotationComposer,
          $$LabelsTableCreateCompanionBuilder,
          $$LabelsTableUpdateCompanionBuilder,
          (LabelRow, BaseReferences<_$AppDatabase, $LabelsTable, LabelRow>),
          LabelRow,
          PrefetchHooks Function()
        > {
  $$LabelsTableTableManager(_$AppDatabase db, $LabelsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LabelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LabelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LabelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int?> remoteId = const Value.absent(),
                Value<String?> updatedAtServer = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> hexColor = const Value.absent(),
                Value<String> rawJson = const Value.absent(),
              }) => LabelsCompanion(
                remoteId: remoteId,
                updatedAtServer: updatedAtServer,
                isDirty: isDirty,
                isDeleted: isDeleted,
                syncedAt: syncedAt,
                id: id,
                title: title,
                hexColor: hexColor,
                rawJson: rawJson,
              ),
          createCompanionCallback:
              ({
                Value<int?> remoteId = const Value.absent(),
                Value<String?> updatedAtServer = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                required String title,
                Value<String?> hexColor = const Value.absent(),
                required String rawJson,
              }) => LabelsCompanion.insert(
                remoteId: remoteId,
                updatedAtServer: updatedAtServer,
                isDirty: isDirty,
                isDeleted: isDeleted,
                syncedAt: syncedAt,
                id: id,
                title: title,
                hexColor: hexColor,
                rawJson: rawJson,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LabelsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LabelsTable,
      LabelRow,
      $$LabelsTableFilterComposer,
      $$LabelsTableOrderingComposer,
      $$LabelsTableAnnotationComposer,
      $$LabelsTableCreateCompanionBuilder,
      $$LabelsTableUpdateCompanionBuilder,
      (LabelRow, BaseReferences<_$AppDatabase, $LabelsTable, LabelRow>),
      LabelRow,
      PrefetchHooks Function()
    >;
typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      Value<int?> remoteId,
      Value<String?> updatedAtServer,
      Value<bool> isDirty,
      Value<bool> isDeleted,
      Value<String?> syncedAt,
      Value<int> id,
      required String username,
      Value<String> name,
      required String rawJson,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<int?> remoteId,
      Value<String?> updatedAtServer,
      Value<bool> isDirty,
      Value<bool> isDeleted,
      Value<String?> syncedAt,
      Value<int> id,
      Value<String> username,
      Value<String> name,
      Value<String> rawJson,
    });

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAtServer => $composableBuilder(
    column: $table.updatedAtServer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAtServer => $composableBuilder(
    column: $table.updatedAtServer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get updatedAtServer => $composableBuilder(
    column: $table.updatedAtServer,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get rawJson =>
      $composableBuilder(column: $table.rawJson, builder: (column) => column);
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          UserRow,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (UserRow, BaseReferences<_$AppDatabase, $UsersTable, UserRow>),
          UserRow,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int?> remoteId = const Value.absent(),
                Value<String?> updatedAtServer = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> rawJson = const Value.absent(),
              }) => UsersCompanion(
                remoteId: remoteId,
                updatedAtServer: updatedAtServer,
                isDirty: isDirty,
                isDeleted: isDeleted,
                syncedAt: syncedAt,
                id: id,
                username: username,
                name: name,
                rawJson: rawJson,
              ),
          createCompanionCallback:
              ({
                Value<int?> remoteId = const Value.absent(),
                Value<String?> updatedAtServer = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                required String username,
                Value<String> name = const Value.absent(),
                required String rawJson,
              }) => UsersCompanion.insert(
                remoteId: remoteId,
                updatedAtServer: updatedAtServer,
                isDirty: isDirty,
                isDeleted: isDeleted,
                syncedAt: syncedAt,
                id: id,
                username: username,
                name: name,
                rawJson: rawJson,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      UserRow,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (UserRow, BaseReferences<_$AppDatabase, $UsersTable, UserRow>),
      UserRow,
      PrefetchHooks Function()
    >;
typedef $$BucketsTableCreateCompanionBuilder =
    BucketsCompanion Function({
      Value<int?> remoteId,
      Value<String?> updatedAtServer,
      Value<bool> isDirty,
      Value<bool> isDeleted,
      Value<String?> syncedAt,
      Value<int> id,
      required int projectId,
      Value<int?> viewId,
      required String title,
      Value<double> position,
      Value<int?> taskLimit,
      Value<bool> isDoneBucket,
      required String rawJson,
    });
typedef $$BucketsTableUpdateCompanionBuilder =
    BucketsCompanion Function({
      Value<int?> remoteId,
      Value<String?> updatedAtServer,
      Value<bool> isDirty,
      Value<bool> isDeleted,
      Value<String?> syncedAt,
      Value<int> id,
      Value<int> projectId,
      Value<int?> viewId,
      Value<String> title,
      Value<double> position,
      Value<int?> taskLimit,
      Value<bool> isDoneBucket,
      Value<String> rawJson,
    });

class $$BucketsTableFilterComposer
    extends Composer<_$AppDatabase, $BucketsTable> {
  $$BucketsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAtServer => $composableBuilder(
    column: $table.updatedAtServer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get viewId => $composableBuilder(
    column: $table.viewId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get taskLimit => $composableBuilder(
    column: $table.taskLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDoneBucket => $composableBuilder(
    column: $table.isDoneBucket,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BucketsTableOrderingComposer
    extends Composer<_$AppDatabase, $BucketsTable> {
  $$BucketsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAtServer => $composableBuilder(
    column: $table.updatedAtServer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get viewId => $composableBuilder(
    column: $table.viewId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get taskLimit => $composableBuilder(
    column: $table.taskLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDoneBucket => $composableBuilder(
    column: $table.isDoneBucket,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BucketsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BucketsTable> {
  $$BucketsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get updatedAtServer => $composableBuilder(
    column: $table.updatedAtServer,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<int> get viewId =>
      $composableBuilder(column: $table.viewId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<double> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get taskLimit =>
      $composableBuilder(column: $table.taskLimit, builder: (column) => column);

  GeneratedColumn<bool> get isDoneBucket => $composableBuilder(
    column: $table.isDoneBucket,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawJson =>
      $composableBuilder(column: $table.rawJson, builder: (column) => column);
}

class $$BucketsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BucketsTable,
          BucketRow,
          $$BucketsTableFilterComposer,
          $$BucketsTableOrderingComposer,
          $$BucketsTableAnnotationComposer,
          $$BucketsTableCreateCompanionBuilder,
          $$BucketsTableUpdateCompanionBuilder,
          (BucketRow, BaseReferences<_$AppDatabase, $BucketsTable, BucketRow>),
          BucketRow,
          PrefetchHooks Function()
        > {
  $$BucketsTableTableManager(_$AppDatabase db, $BucketsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BucketsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BucketsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BucketsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int?> remoteId = const Value.absent(),
                Value<String?> updatedAtServer = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<int> projectId = const Value.absent(),
                Value<int?> viewId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<double> position = const Value.absent(),
                Value<int?> taskLimit = const Value.absent(),
                Value<bool> isDoneBucket = const Value.absent(),
                Value<String> rawJson = const Value.absent(),
              }) => BucketsCompanion(
                remoteId: remoteId,
                updatedAtServer: updatedAtServer,
                isDirty: isDirty,
                isDeleted: isDeleted,
                syncedAt: syncedAt,
                id: id,
                projectId: projectId,
                viewId: viewId,
                title: title,
                position: position,
                taskLimit: taskLimit,
                isDoneBucket: isDoneBucket,
                rawJson: rawJson,
              ),
          createCompanionCallback:
              ({
                Value<int?> remoteId = const Value.absent(),
                Value<String?> updatedAtServer = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                required int projectId,
                Value<int?> viewId = const Value.absent(),
                required String title,
                Value<double> position = const Value.absent(),
                Value<int?> taskLimit = const Value.absent(),
                Value<bool> isDoneBucket = const Value.absent(),
                required String rawJson,
              }) => BucketsCompanion.insert(
                remoteId: remoteId,
                updatedAtServer: updatedAtServer,
                isDirty: isDirty,
                isDeleted: isDeleted,
                syncedAt: syncedAt,
                id: id,
                projectId: projectId,
                viewId: viewId,
                title: title,
                position: position,
                taskLimit: taskLimit,
                isDoneBucket: isDoneBucket,
                rawJson: rawJson,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BucketsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BucketsTable,
      BucketRow,
      $$BucketsTableFilterComposer,
      $$BucketsTableOrderingComposer,
      $$BucketsTableAnnotationComposer,
      $$BucketsTableCreateCompanionBuilder,
      $$BucketsTableUpdateCompanionBuilder,
      (BucketRow, BaseReferences<_$AppDatabase, $BucketsTable, BucketRow>),
      BucketRow,
      PrefetchHooks Function()
    >;
typedef $$TaskLabelsTableCreateCompanionBuilder =
    TaskLabelsCompanion Function({
      required int taskId,
      required int labelId,
      Value<bool> isDirty,
      Value<int> rowid,
    });
typedef $$TaskLabelsTableUpdateCompanionBuilder =
    TaskLabelsCompanion Function({
      Value<int> taskId,
      Value<int> labelId,
      Value<bool> isDirty,
      Value<int> rowid,
    });

class $$TaskLabelsTableFilterComposer
    extends Composer<_$AppDatabase, $TaskLabelsTable> {
  $$TaskLabelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get labelId => $composableBuilder(
    column: $table.labelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TaskLabelsTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskLabelsTable> {
  $$TaskLabelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get labelId => $composableBuilder(
    column: $table.labelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TaskLabelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskLabelsTable> {
  $$TaskLabelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<int> get labelId =>
      $composableBuilder(column: $table.labelId, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);
}

class $$TaskLabelsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskLabelsTable,
          TaskLabelRow,
          $$TaskLabelsTableFilterComposer,
          $$TaskLabelsTableOrderingComposer,
          $$TaskLabelsTableAnnotationComposer,
          $$TaskLabelsTableCreateCompanionBuilder,
          $$TaskLabelsTableUpdateCompanionBuilder,
          (
            TaskLabelRow,
            BaseReferences<_$AppDatabase, $TaskLabelsTable, TaskLabelRow>,
          ),
          TaskLabelRow,
          PrefetchHooks Function()
        > {
  $$TaskLabelsTableTableManager(_$AppDatabase db, $TaskLabelsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskLabelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskLabelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskLabelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> taskId = const Value.absent(),
                Value<int> labelId = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskLabelsCompanion(
                taskId: taskId,
                labelId: labelId,
                isDirty: isDirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int taskId,
                required int labelId,
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskLabelsCompanion.insert(
                taskId: taskId,
                labelId: labelId,
                isDirty: isDirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TaskLabelsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskLabelsTable,
      TaskLabelRow,
      $$TaskLabelsTableFilterComposer,
      $$TaskLabelsTableOrderingComposer,
      $$TaskLabelsTableAnnotationComposer,
      $$TaskLabelsTableCreateCompanionBuilder,
      $$TaskLabelsTableUpdateCompanionBuilder,
      (
        TaskLabelRow,
        BaseReferences<_$AppDatabase, $TaskLabelsTable, TaskLabelRow>,
      ),
      TaskLabelRow,
      PrefetchHooks Function()
    >;
typedef $$TaskAssigneesTableCreateCompanionBuilder =
    TaskAssigneesCompanion Function({
      required int taskId,
      required int userId,
      Value<bool> isDirty,
      Value<int> rowid,
    });
typedef $$TaskAssigneesTableUpdateCompanionBuilder =
    TaskAssigneesCompanion Function({
      Value<int> taskId,
      Value<int> userId,
      Value<bool> isDirty,
      Value<int> rowid,
    });

class $$TaskAssigneesTableFilterComposer
    extends Composer<_$AppDatabase, $TaskAssigneesTable> {
  $$TaskAssigneesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TaskAssigneesTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskAssigneesTable> {
  $$TaskAssigneesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TaskAssigneesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskAssigneesTable> {
  $$TaskAssigneesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);
}

class $$TaskAssigneesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskAssigneesTable,
          TaskAssigneeRow,
          $$TaskAssigneesTableFilterComposer,
          $$TaskAssigneesTableOrderingComposer,
          $$TaskAssigneesTableAnnotationComposer,
          $$TaskAssigneesTableCreateCompanionBuilder,
          $$TaskAssigneesTableUpdateCompanionBuilder,
          (
            TaskAssigneeRow,
            BaseReferences<_$AppDatabase, $TaskAssigneesTable, TaskAssigneeRow>,
          ),
          TaskAssigneeRow,
          PrefetchHooks Function()
        > {
  $$TaskAssigneesTableTableManager(_$AppDatabase db, $TaskAssigneesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskAssigneesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskAssigneesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskAssigneesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> taskId = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskAssigneesCompanion(
                taskId: taskId,
                userId: userId,
                isDirty: isDirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int taskId,
                required int userId,
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskAssigneesCompanion.insert(
                taskId: taskId,
                userId: userId,
                isDirty: isDirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TaskAssigneesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskAssigneesTable,
      TaskAssigneeRow,
      $$TaskAssigneesTableFilterComposer,
      $$TaskAssigneesTableOrderingComposer,
      $$TaskAssigneesTableAnnotationComposer,
      $$TaskAssigneesTableCreateCompanionBuilder,
      $$TaskAssigneesTableUpdateCompanionBuilder,
      (
        TaskAssigneeRow,
        BaseReferences<_$AppDatabase, $TaskAssigneesTable, TaskAssigneeRow>,
      ),
      TaskAssigneeRow,
      PrefetchHooks Function()
    >;
typedef $$TaskCommentsTableCreateCompanionBuilder =
    TaskCommentsCompanion Function({
      Value<int?> remoteId,
      Value<String?> updatedAtServer,
      Value<bool> isDirty,
      Value<bool> isDeleted,
      Value<String?> syncedAt,
      Value<int> id,
      required int taskId,
      required String authorJson,
      required String comment,
      required String createdAt,
      required String rawJson,
    });
typedef $$TaskCommentsTableUpdateCompanionBuilder =
    TaskCommentsCompanion Function({
      Value<int?> remoteId,
      Value<String?> updatedAtServer,
      Value<bool> isDirty,
      Value<bool> isDeleted,
      Value<String?> syncedAt,
      Value<int> id,
      Value<int> taskId,
      Value<String> authorJson,
      Value<String> comment,
      Value<String> createdAt,
      Value<String> rawJson,
    });

class $$TaskCommentsTableFilterComposer
    extends Composer<_$AppDatabase, $TaskCommentsTable> {
  $$TaskCommentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAtServer => $composableBuilder(
    column: $table.updatedAtServer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorJson => $composableBuilder(
    column: $table.authorJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TaskCommentsTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskCommentsTable> {
  $$TaskCommentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAtServer => $composableBuilder(
    column: $table.updatedAtServer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorJson => $composableBuilder(
    column: $table.authorJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TaskCommentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskCommentsTable> {
  $$TaskCommentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get updatedAtServer => $composableBuilder(
    column: $table.updatedAtServer,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get authorJson => $composableBuilder(
    column: $table.authorJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get rawJson =>
      $composableBuilder(column: $table.rawJson, builder: (column) => column);
}

class $$TaskCommentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskCommentsTable,
          TaskCommentRow,
          $$TaskCommentsTableFilterComposer,
          $$TaskCommentsTableOrderingComposer,
          $$TaskCommentsTableAnnotationComposer,
          $$TaskCommentsTableCreateCompanionBuilder,
          $$TaskCommentsTableUpdateCompanionBuilder,
          (
            TaskCommentRow,
            BaseReferences<_$AppDatabase, $TaskCommentsTable, TaskCommentRow>,
          ),
          TaskCommentRow,
          PrefetchHooks Function()
        > {
  $$TaskCommentsTableTableManager(_$AppDatabase db, $TaskCommentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskCommentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskCommentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskCommentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int?> remoteId = const Value.absent(),
                Value<String?> updatedAtServer = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<int> taskId = const Value.absent(),
                Value<String> authorJson = const Value.absent(),
                Value<String> comment = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> rawJson = const Value.absent(),
              }) => TaskCommentsCompanion(
                remoteId: remoteId,
                updatedAtServer: updatedAtServer,
                isDirty: isDirty,
                isDeleted: isDeleted,
                syncedAt: syncedAt,
                id: id,
                taskId: taskId,
                authorJson: authorJson,
                comment: comment,
                createdAt: createdAt,
                rawJson: rawJson,
              ),
          createCompanionCallback:
              ({
                Value<int?> remoteId = const Value.absent(),
                Value<String?> updatedAtServer = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                required int taskId,
                required String authorJson,
                required String comment,
                required String createdAt,
                required String rawJson,
              }) => TaskCommentsCompanion.insert(
                remoteId: remoteId,
                updatedAtServer: updatedAtServer,
                isDirty: isDirty,
                isDeleted: isDeleted,
                syncedAt: syncedAt,
                id: id,
                taskId: taskId,
                authorJson: authorJson,
                comment: comment,
                createdAt: createdAt,
                rawJson: rawJson,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TaskCommentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskCommentsTable,
      TaskCommentRow,
      $$TaskCommentsTableFilterComposer,
      $$TaskCommentsTableOrderingComposer,
      $$TaskCommentsTableAnnotationComposer,
      $$TaskCommentsTableCreateCompanionBuilder,
      $$TaskCommentsTableUpdateCompanionBuilder,
      (
        TaskCommentRow,
        BaseReferences<_$AppDatabase, $TaskCommentsTable, TaskCommentRow>,
      ),
      TaskCommentRow,
      PrefetchHooks Function()
    >;
typedef $$TaskAttachmentsTableCreateCompanionBuilder =
    TaskAttachmentsCompanion Function({
      Value<int?> remoteId,
      Value<String?> updatedAtServer,
      Value<bool> isDirty,
      Value<bool> isDeleted,
      Value<String?> syncedAt,
      Value<int> id,
      required int taskId,
      required String fileJson,
      Value<String?> localFilePath,
      required String rawJson,
    });
typedef $$TaskAttachmentsTableUpdateCompanionBuilder =
    TaskAttachmentsCompanion Function({
      Value<int?> remoteId,
      Value<String?> updatedAtServer,
      Value<bool> isDirty,
      Value<bool> isDeleted,
      Value<String?> syncedAt,
      Value<int> id,
      Value<int> taskId,
      Value<String> fileJson,
      Value<String?> localFilePath,
      Value<String> rawJson,
    });

class $$TaskAttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $TaskAttachmentsTable> {
  $$TaskAttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAtServer => $composableBuilder(
    column: $table.updatedAtServer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileJson => $composableBuilder(
    column: $table.fileJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TaskAttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskAttachmentsTable> {
  $$TaskAttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAtServer => $composableBuilder(
    column: $table.updatedAtServer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileJson => $composableBuilder(
    column: $table.fileJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TaskAttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskAttachmentsTable> {
  $$TaskAttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get updatedAtServer => $composableBuilder(
    column: $table.updatedAtServer,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get fileJson =>
      $composableBuilder(column: $table.fileJson, builder: (column) => column);

  GeneratedColumn<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawJson =>
      $composableBuilder(column: $table.rawJson, builder: (column) => column);
}

class $$TaskAttachmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskAttachmentsTable,
          TaskAttachmentRow,
          $$TaskAttachmentsTableFilterComposer,
          $$TaskAttachmentsTableOrderingComposer,
          $$TaskAttachmentsTableAnnotationComposer,
          $$TaskAttachmentsTableCreateCompanionBuilder,
          $$TaskAttachmentsTableUpdateCompanionBuilder,
          (
            TaskAttachmentRow,
            BaseReferences<
              _$AppDatabase,
              $TaskAttachmentsTable,
              TaskAttachmentRow
            >,
          ),
          TaskAttachmentRow,
          PrefetchHooks Function()
        > {
  $$TaskAttachmentsTableTableManager(
    _$AppDatabase db,
    $TaskAttachmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskAttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskAttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskAttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int?> remoteId = const Value.absent(),
                Value<String?> updatedAtServer = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<int> taskId = const Value.absent(),
                Value<String> fileJson = const Value.absent(),
                Value<String?> localFilePath = const Value.absent(),
                Value<String> rawJson = const Value.absent(),
              }) => TaskAttachmentsCompanion(
                remoteId: remoteId,
                updatedAtServer: updatedAtServer,
                isDirty: isDirty,
                isDeleted: isDeleted,
                syncedAt: syncedAt,
                id: id,
                taskId: taskId,
                fileJson: fileJson,
                localFilePath: localFilePath,
                rawJson: rawJson,
              ),
          createCompanionCallback:
              ({
                Value<int?> remoteId = const Value.absent(),
                Value<String?> updatedAtServer = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                required int taskId,
                required String fileJson,
                Value<String?> localFilePath = const Value.absent(),
                required String rawJson,
              }) => TaskAttachmentsCompanion.insert(
                remoteId: remoteId,
                updatedAtServer: updatedAtServer,
                isDirty: isDirty,
                isDeleted: isDeleted,
                syncedAt: syncedAt,
                id: id,
                taskId: taskId,
                fileJson: fileJson,
                localFilePath: localFilePath,
                rawJson: rawJson,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TaskAttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskAttachmentsTable,
      TaskAttachmentRow,
      $$TaskAttachmentsTableFilterComposer,
      $$TaskAttachmentsTableOrderingComposer,
      $$TaskAttachmentsTableAnnotationComposer,
      $$TaskAttachmentsTableCreateCompanionBuilder,
      $$TaskAttachmentsTableUpdateCompanionBuilder,
      (
        TaskAttachmentRow,
        BaseReferences<_$AppDatabase, $TaskAttachmentsTable, TaskAttachmentRow>,
      ),
      TaskAttachmentRow,
      PrefetchHooks Function()
    >;
typedef $$KeyValuesTableCreateCompanionBuilder =
    KeyValuesCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$KeyValuesTableUpdateCompanionBuilder =
    KeyValuesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$KeyValuesTableFilterComposer
    extends Composer<_$AppDatabase, $KeyValuesTable> {
  $$KeyValuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KeyValuesTableOrderingComposer
    extends Composer<_$AppDatabase, $KeyValuesTable> {
  $$KeyValuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KeyValuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $KeyValuesTable> {
  $$KeyValuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$KeyValuesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KeyValuesTable,
          KeyValueRow,
          $$KeyValuesTableFilterComposer,
          $$KeyValuesTableOrderingComposer,
          $$KeyValuesTableAnnotationComposer,
          $$KeyValuesTableCreateCompanionBuilder,
          $$KeyValuesTableUpdateCompanionBuilder,
          (
            KeyValueRow,
            BaseReferences<_$AppDatabase, $KeyValuesTable, KeyValueRow>,
          ),
          KeyValueRow,
          PrefetchHooks Function()
        > {
  $$KeyValuesTableTableManager(_$AppDatabase db, $KeyValuesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KeyValuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KeyValuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KeyValuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KeyValuesCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => KeyValuesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KeyValuesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KeyValuesTable,
      KeyValueRow,
      $$KeyValuesTableFilterComposer,
      $$KeyValuesTableOrderingComposer,
      $$KeyValuesTableAnnotationComposer,
      $$KeyValuesTableCreateCompanionBuilder,
      $$KeyValuesTableUpdateCompanionBuilder,
      (
        KeyValueRow,
        BaseReferences<_$AppDatabase, $KeyValuesTable, KeyValueRow>,
      ),
      KeyValueRow,
      PrefetchHooks Function()
    >;
typedef $$PendingOpsTableCreateCompanionBuilder =
    PendingOpsCompanion Function({
      Value<int> opId,
      required String entityType,
      required int localId,
      required String opType,
      required String payloadJson,
      Value<String?> localFilePathsJson,
      required String createdAt,
      Value<int> retryCount,
      Value<String?> lastError,
    });
typedef $$PendingOpsTableUpdateCompanionBuilder =
    PendingOpsCompanion Function({
      Value<int> opId,
      Value<String> entityType,
      Value<int> localId,
      Value<String> opType,
      Value<String> payloadJson,
      Value<String?> localFilePathsJson,
      Value<String> createdAt,
      Value<int> retryCount,
      Value<String?> lastError,
    });

class $$PendingOpsTableFilterComposer
    extends Composer<_$AppDatabase, $PendingOpsTable> {
  $$PendingOpsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get opType => $composableBuilder(
    column: $table.opType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localFilePathsJson => $composableBuilder(
    column: $table.localFilePathsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingOpsTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingOpsTable> {
  $$PendingOpsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get opType => $composableBuilder(
    column: $table.opType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localFilePathsJson => $composableBuilder(
    column: $table.localFilePathsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingOpsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingOpsTable> {
  $$PendingOpsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get opType =>
      $composableBuilder(column: $table.opType, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localFilePathsJson => $composableBuilder(
    column: $table.localFilePathsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$PendingOpsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingOpsTable,
          PendingOpRow,
          $$PendingOpsTableFilterComposer,
          $$PendingOpsTableOrderingComposer,
          $$PendingOpsTableAnnotationComposer,
          $$PendingOpsTableCreateCompanionBuilder,
          $$PendingOpsTableUpdateCompanionBuilder,
          (
            PendingOpRow,
            BaseReferences<_$AppDatabase, $PendingOpsTable, PendingOpRow>,
          ),
          PendingOpRow,
          PrefetchHooks Function()
        > {
  $$PendingOpsTableTableManager(_$AppDatabase db, $PendingOpsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingOpsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingOpsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingOpsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> opId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<int> localId = const Value.absent(),
                Value<String> opType = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String?> localFilePathsJson = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => PendingOpsCompanion(
                opId: opId,
                entityType: entityType,
                localId: localId,
                opType: opType,
                payloadJson: payloadJson,
                localFilePathsJson: localFilePathsJson,
                createdAt: createdAt,
                retryCount: retryCount,
                lastError: lastError,
              ),
          createCompanionCallback:
              ({
                Value<int> opId = const Value.absent(),
                required String entityType,
                required int localId,
                required String opType,
                required String payloadJson,
                Value<String?> localFilePathsJson = const Value.absent(),
                required String createdAt,
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => PendingOpsCompanion.insert(
                opId: opId,
                entityType: entityType,
                localId: localId,
                opType: opType,
                payloadJson: payloadJson,
                localFilePathsJson: localFilePathsJson,
                createdAt: createdAt,
                retryCount: retryCount,
                lastError: lastError,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingOpsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingOpsTable,
      PendingOpRow,
      $$PendingOpsTableFilterComposer,
      $$PendingOpsTableOrderingComposer,
      $$PendingOpsTableAnnotationComposer,
      $$PendingOpsTableCreateCompanionBuilder,
      $$PendingOpsTableUpdateCompanionBuilder,
      (
        PendingOpRow,
        BaseReferences<_$AppDatabase, $PendingOpsTable, PendingOpRow>,
      ),
      PendingOpRow,
      PrefetchHooks Function()
    >;
typedef $$ImageCachesTableCreateCompanionBuilder =
    ImageCachesCompanion Function({
      required String urlHash,
      required String filePath,
      required String fetchedAt,
      Value<int> rowid,
    });
typedef $$ImageCachesTableUpdateCompanionBuilder =
    ImageCachesCompanion Function({
      Value<String> urlHash,
      Value<String> filePath,
      Value<String> fetchedAt,
      Value<int> rowid,
    });

class $$ImageCachesTableFilterComposer
    extends Composer<_$AppDatabase, $ImageCachesTable> {
  $$ImageCachesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get urlHash => $composableBuilder(
    column: $table.urlHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ImageCachesTableOrderingComposer
    extends Composer<_$AppDatabase, $ImageCachesTable> {
  $$ImageCachesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get urlHash => $composableBuilder(
    column: $table.urlHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImageCachesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImageCachesTable> {
  $$ImageCachesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get urlHash =>
      $composableBuilder(column: $table.urlHash, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$ImageCachesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImageCachesTable,
          ImageCacheRow,
          $$ImageCachesTableFilterComposer,
          $$ImageCachesTableOrderingComposer,
          $$ImageCachesTableAnnotationComposer,
          $$ImageCachesTableCreateCompanionBuilder,
          $$ImageCachesTableUpdateCompanionBuilder,
          (
            ImageCacheRow,
            BaseReferences<_$AppDatabase, $ImageCachesTable, ImageCacheRow>,
          ),
          ImageCacheRow,
          PrefetchHooks Function()
        > {
  $$ImageCachesTableTableManager(_$AppDatabase db, $ImageCachesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImageCachesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImageCachesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImageCachesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> urlHash = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImageCachesCompanion(
                urlHash: urlHash,
                filePath: filePath,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String urlHash,
                required String filePath,
                required String fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => ImageCachesCompanion.insert(
                urlHash: urlHash,
                filePath: filePath,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ImageCachesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImageCachesTable,
      ImageCacheRow,
      $$ImageCachesTableFilterComposer,
      $$ImageCachesTableOrderingComposer,
      $$ImageCachesTableAnnotationComposer,
      $$ImageCachesTableCreateCompanionBuilder,
      $$ImageCachesTableUpdateCompanionBuilder,
      (
        ImageCacheRow,
        BaseReferences<_$AppDatabase, $ImageCachesTable, ImageCacheRow>,
      ),
      ImageCacheRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$LabelsTableTableManager get labels =>
      $$LabelsTableTableManager(_db, _db.labels);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$BucketsTableTableManager get buckets =>
      $$BucketsTableTableManager(_db, _db.buckets);
  $$TaskLabelsTableTableManager get taskLabels =>
      $$TaskLabelsTableTableManager(_db, _db.taskLabels);
  $$TaskAssigneesTableTableManager get taskAssignees =>
      $$TaskAssigneesTableTableManager(_db, _db.taskAssignees);
  $$TaskCommentsTableTableManager get taskComments =>
      $$TaskCommentsTableTableManager(_db, _db.taskComments);
  $$TaskAttachmentsTableTableManager get taskAttachments =>
      $$TaskAttachmentsTableTableManager(_db, _db.taskAttachments);
  $$KeyValuesTableTableManager get keyValues =>
      $$KeyValuesTableTableManager(_db, _db.keyValues);
  $$PendingOpsTableTableManager get pendingOps =>
      $$PendingOpsTableTableManager(_db, _db.pendingOps);
  $$ImageCachesTableTableManager get imageCaches =>
      $$ImageCachesTableTableManager(_db, _db.imageCaches);
}
