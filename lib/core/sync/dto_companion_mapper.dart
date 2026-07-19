import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/data/models/bucket_dto.dart';
import 'package:vikunja_app/data/models/label_dto.dart';
import 'package:vikunja_app/data/models/project_dto.dart';
import 'package:vikunja_app/data/models/task_comment_dto.dart';
import 'package:vikunja_app/data/models/task_dto.dart';
import 'package:vikunja_app/data/models/user_dto.dart';

/// Übersetzt Server-DTOs in Drift-Companions für den Pull-Sync.
///
/// Konvention pro Entität: eigene Spalten aus dem DTO befüllen, das komplette
/// DTO-JSON in `rawJson`, `remoteId = dto.id`, `updatedAtServer = dto.updated`
/// und `syncedAt = now` (Zeitpunkt des Abgleichs). Für Tasks werden zusätzlich
/// die Label-/Assignee-IDs für die n:m-Tabellen bereitgestellt.
class DtoCompanionMapper {
  const DtoCompanionMapper();

  String _iso(DateTime dt) => dt.toUtc().toIso8601String();

  /// Leere Vikunja-Datumsangaben kommen als Jahr 0001 zurück; die behandeln
  /// wir als "kein Datum" (null).
  String? _isoDate(DateTime? dt) =>
      (dt == null || dt.year <= 1) ? null : dt.toUtc().toIso8601String();

  ProjectsCompanion project(ProjectDto dto, DateTime now) {
    final raw = dto.toJSON();
    return ProjectsCompanion.insert(
      id: Value(dto.id),
      title: dto.title,
      rawJson: jsonEncode(raw),
      remoteId: Value(dto.id),
      description: Value(dto.description),
      parentProjectId: Value(dto.parentProjectId),
      position: Value(dto.position),
      isFavourite: Value(dto.isFavourite),
      hexColor: Value(raw['hex_color'] as String?),
      viewsJson: Value(jsonEncode(dto.views.map((v) => v.toJSON()).toList())),
      ownerJson: Value(
        dto.owner != null ? jsonEncode(dto.owner!.toJSON()) : null,
      ),
      updatedAtServer: Value(_iso(dto.updated)),
      syncedAt: Value(_iso(now)),
    );
  }

  TasksCompanion task(
    TaskDto dto,
    DateTime now, {
    int? projectId,
    int? bucketId,
  }) {
    final raw = dto.toJSON();
    return TasksCompanion.insert(
      id: Value(dto.id),
      projectId: projectId ?? dto.projectId ?? 0,
      title: dto.title,
      createdAt: _iso(dto.created),
      updatedAt: _iso(dto.updated),
      rawJson: jsonEncode(raw),
      remoteId: Value(dto.id),
      bucketId: Value(bucketId ?? dto.bucketId),
      description: Value(dto.description),
      done: Value(dto.done),
      dueDate: Value(_isoDate(dto.dueDate)),
      startDate: Value(_isoDate(dto.startDate)),
      endDate: Value(_isoDate(dto.endDate)),
      priority: Value(dto.priority),
      percentDone: Value(dto.percentDone),
      position: Value(dto.position),
      identifier: Value(dto.identifier),
      updatedAtServer: Value(_iso(dto.updated)),
      syncedAt: Value(_iso(now)),
    );
  }

  /// Label-IDs eines Tasks für die task_labels-Tabelle.
  List<int> taskLabelIds(TaskDto dto) =>
      dto.labels.map((l) => l.id).toList(growable: false);

  /// Assignee-IDs eines Tasks für die task_assignees-Tabelle.
  List<int> taskAssigneeIds(TaskDto dto) =>
      dto.assignees.map((u) => u.id).toList(growable: false);

  LabelsCompanion label(LabelDto dto, DateTime now) {
    final raw = dto.toJSON();
    return LabelsCompanion.insert(
      id: Value(dto.id),
      title: dto.title,
      rawJson: jsonEncode(raw),
      remoteId: Value(dto.id),
      hexColor: Value(raw['hex_color'] as String?),
      updatedAtServer: Value(_iso(dto.updated)),
      syncedAt: Value(_iso(now)),
    );
  }

  UsersCompanion user(UserDto dto, DateTime now) {
    return UsersCompanion.insert(
      id: Value(dto.id),
      username: dto.username,
      rawJson: jsonEncode(dto.toJSON()),
      remoteId: Value(dto.id),
      name: Value(dto.name),
      updatedAtServer: Value(_iso(dto.updated)),
      syncedAt: Value(_iso(now)),
    );
  }

  BucketsCompanion bucket(
    BucketDto dto,
    DateTime now, {
    required int projectId,
    int? viewId,
    bool isDoneBucket = false,
  }) {
    return BucketsCompanion.insert(
      id: Value(dto.id),
      projectId: projectId,
      title: dto.title,
      rawJson: jsonEncode(dto.toJSON()),
      remoteId: Value(dto.id),
      viewId: Value(viewId ?? dto.projectViewId),
      position: Value(dto.position ?? 0),
      taskLimit: Value(dto.limit),
      isDoneBucket: Value(isDoneBucket),
      updatedAtServer: Value(_iso(dto.updated)),
      syncedAt: Value(_iso(now)),
    );
  }

  TaskCommentsCompanion taskComment(
    TaskCommentDto dto,
    DateTime now, {
    required int taskId,
  }) {
    return TaskCommentsCompanion.insert(
      id: Value(dto.id),
      taskId: taskId,
      authorJson: jsonEncode(dto.author.toJSON()),
      comment: dto.comment,
      createdAt: _iso(dto.created),
      rawJson: jsonEncode(dto.toJSON()),
      remoteId: Value(dto.id),
      updatedAtServer: Value(_iso(dto.updated)),
      syncedAt: Value(_iso(now)),
    );
  }
}
