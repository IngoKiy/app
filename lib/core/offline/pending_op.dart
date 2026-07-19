import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:vikunja_app/data/local/database.dart';

/// Alle Operationstypen, die der Push-Sync (Outbox) kennt. Der Name (`.name`)
/// wird in der `pending_ops`-Tabelle als `opType` gespeichert.
///
/// ## Enqueue-Konventionen (payload + tempIdRefs je OpType)
///
/// [payload] ist das DTO-JSON der Operation; [tempIdRefs] bildet logische
/// FK-Namen auf noch nicht aufgelöste Temp-IDs ab (nur nötig, wenn die
/// referenzierte Entität selbst offline erzeugt wurde). Der [PushProcessor]
/// löst die Refs beim Senden über das Temp-ID-Mapping auf; für Update/Delete
/// wird die primäre Entität über [PendingOp.localId] (ggf. Temp-ID) aufgelöst.
///
/// | OpType            | localId        | payload (relevante Schlüssel)                 | tempIdRefs        |
/// |-------------------|----------------|-----------------------------------------------|-------------------|
/// | taskCreate        | Task-Temp-ID   | `TaskDto.toJSON()` inkl. `project_id`         | `projectId?`      |
/// | taskUpdate        | Task-ID        | `TaskDto.toJSON()` (`id` wird überschrieben)  | –                 |
/// | taskDelete        | Task-ID        | `{}`                                          | –                 |
/// | taskSetAssignees  | Task-ID        | `{assignees: [UserDto.toJSON()...]}`          | `taskId?`         |
/// | taskLabelBulk     | Task-ID        | `{labels: [LabelDto.toJSON()...]}`            | `taskId?`         |
/// | labelCreate       | Label-Temp-ID  | `LabelDto.toJSON()`                           | –                 |
/// | commentCreate     | Comment-Temp   | `TaskCommentDto.toJSON()` + `task_id`         | `taskId?`         |
/// | commentUpdate     | Comment-ID     | `TaskCommentDto.toJSON()` + `task_id`         | `taskId?`         |
/// | commentDelete     | Comment-ID     | `{task_id}`                                   | `taskId?`         |
/// | projectCreate     | Project-Temp   | `ProjectDto.toJSON()`                         | –                 |
/// | projectUpdate     | Project-ID     | `ProjectDto.toJSON()`                         | –                 |
/// | bucketCreate      | Bucket-Temp    | `BucketDto.toJSON()` + `project_id`,`view_id` | `projectId?,viewId?` |
/// | bucketUpdate      | Bucket-ID      | `BucketDto.toJSON()` + `project_id`,`view_id` | `projectId?,viewId?` |
/// | bucketDelete      | Bucket-ID      | `{project_id, view_id}`                        | `projectId?,viewId?` |
/// | taskMoveBucket    | Task-ID        | `{bucket_id, project_id, view_id}`            | `taskId?,bucketId?,projectId?` |
/// | taskPosition      | Task-ID        | `{position, view_id}`                          | `taskId?`         |
/// | projectViewUpdate | View-ID        | `ProjectViewDto.toJSON()`                     | –                 |
/// | userSettings      | 0              | `UserSettingsDto.toJson()`                    | –                 |
/// | attachment*       | Task-ID        | (M4, siehe push_processor)                    | `taskId?`         |
///
/// Die FIFO-Reihenfolge kodiert Abhängigkeiten: eine liefernde Create-Op wird
/// immer vor ihren Nutzern enqueued.
enum PendingOpType {
  taskCreate,
  taskUpdate,
  taskDelete,
  taskSetAssignees,
  taskLabelBulk,
  labelCreate,
  commentCreate,
  commentUpdate,
  commentDelete,
  projectCreate,
  projectUpdate,
  bucketCreate,
  bucketUpdate,
  bucketDelete,
  taskMoveBucket,
  taskPosition,
  projectViewUpdate,
  userSettings,
  attachmentUpload,
  attachmentDelete,
}

extension PendingOpTypeX on PendingOpType {
  /// Create-Ops erzeugen eine neue Server-Entität und liefern beim Erfolg eine
  /// Server-ID, auf die abhängige Ops per Temp-ID-Mapping umgebogen werden.
  bool get isCreate =>
      this == PendingOpType.taskCreate ||
      this == PendingOpType.commentCreate ||
      this == PendingOpType.projectCreate ||
      this == PendingOpType.bucketCreate ||
      this == PendingOpType.labelCreate;

  /// Grobe Entitätskategorie (für die `entityType`-Spalte / Debugging).
  String get entityType {
    switch (this) {
      case PendingOpType.taskCreate:
      case PendingOpType.taskUpdate:
      case PendingOpType.taskDelete:
      case PendingOpType.taskSetAssignees:
      case PendingOpType.taskLabelBulk:
      case PendingOpType.taskMoveBucket:
      case PendingOpType.taskPosition:
        return 'task';
      case PendingOpType.labelCreate:
        return 'label';
      case PendingOpType.commentCreate:
      case PendingOpType.commentUpdate:
      case PendingOpType.commentDelete:
        return 'comment';
      case PendingOpType.projectCreate:
      case PendingOpType.projectUpdate:
        return 'project';
      case PendingOpType.bucketCreate:
      case PendingOpType.bucketUpdate:
      case PendingOpType.bucketDelete:
        return 'bucket';
      case PendingOpType.projectViewUpdate:
        return 'projectView';
      case PendingOpType.userSettings:
        return 'user';
      case PendingOpType.attachmentUpload:
      case PendingOpType.attachmentDelete:
        return 'attachment';
    }
  }
}

/// Typisiertes Op-Modell über der `pending_ops`-Tabelle.
///
/// Serialisierung: Die Tabellenspalte `payloadJson` enthält einen Envelope
/// `{"payload": {...}, "tempIdRefs": {"taskId": -3}}`. [payload] ist das
/// DTO-JSON (bzw. op-spezifische Argumente), [tempIdRefs] bildet logische
/// Referenznamen auf noch nicht aufgelöste Temp-IDs ab. Beim Create-Erfolg der
/// liefernden Op wird der Temp-Wert transaktional durch die Server-ID ersetzt.
class PendingOp {
  const PendingOp({
    this.opId,
    required this.type,
    required this.localId,
    required this.payload,
    this.tempIdRefs = const {},
    this.localFilePaths,
    required this.createdAt,
    this.retryCount = 0,
    this.lastError,
  });

  /// Von der DB vergebene ID (null vor dem Persistieren).
  final int? opId;
  final PendingOpType type;

  /// Lokale ID der primären Entität (Temp-ID bei Create, sonst reale ID).
  final int localId;
  final Map<String, dynamic> payload;
  final Map<String, int> tempIdRefs;
  final List<String>? localFilePaths;
  final String createdAt;
  final int retryCount;
  final String? lastError;

  /// Serialisiert [payload] + [tempIdRefs] in den Envelope für `payloadJson`.
  String encodePayload() =>
      jsonEncode({'payload': payload, 'tempIdRefs': tempIdRefs});

  /// Baut das Modell aus einer Tabellenzeile.
  factory PendingOp.fromRow(PendingOpRow row) {
    final env = jsonDecode(row.payloadJson) as Map<String, dynamic>;
    final payload = (env['payload'] as Map).cast<String, dynamic>();
    final refsRaw = (env['tempIdRefs'] as Map?)?.cast<String, dynamic>() ?? {};
    final refs = refsRaw.map((k, v) => MapEntry(k, (v as num).toInt()));
    final paths = row.localFilePathsJson == null
        ? null
        : (jsonDecode(row.localFilePathsJson!) as List).cast<String>();
    return PendingOp(
      opId: row.opId,
      type: PendingOpType.values.byName(row.opType),
      localId: row.localId,
      payload: payload,
      tempIdRefs: refs,
      localFilePaths: paths,
      createdAt: row.createdAt,
      retryCount: row.retryCount,
      lastError: row.lastError,
    );
  }

  /// Companion zum Einfügen in die `pending_ops`-Tabelle.
  PendingOpsCompanion toCompanion() => PendingOpsCompanion.insert(
    entityType: type.entityType,
    localId: localId,
    opType: type.name,
    payloadJson: encodePayload(),
    createdAt: createdAt,
    localFilePathsJson: Value(
      localFilePaths == null ? null : jsonEncode(localFilePaths),
    ),
  );

  PendingOp copyWith({
    Map<String, dynamic>? payload,
    Map<String, int>? tempIdRefs,
    int? localId,
  }) => PendingOp(
    opId: opId,
    type: type,
    localId: localId ?? this.localId,
    payload: payload ?? this.payload,
    tempIdRefs: tempIdRefs ?? this.tempIdRefs,
    localFilePaths: localFilePaths,
    createdAt: createdAt,
    retryCount: retryCount,
    lastError: lastError,
  );
}
