import 'dart:convert';

import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/data/models/bucket_dto.dart';
import 'package:vikunja_app/data/models/project_dto.dart';
import 'package:vikunja_app/data/models/task_dto.dart';
import 'package:vikunja_app/domain/entities/bucket.dart';
import 'package:vikunja_app/domain/entities/project.dart';
import 'package:vikunja_app/domain/entities/task.dart';

/// Baut Domain-Objekte aus den DB-Zeilen. Die Wahrheit steckt im `rawJson`
/// (komplettes DTO-JSON); die einzelnen Spalten dienen nur Query/Sortierung.
/// Konvention: jsonDecode(rawJson) -> DTO.fromJson -> toDomain.
///
/// Die DTO-`fromJson` sind null-tolerant, damit auch rawJson aus `toJSON`
/// (das leere Werte als null schreibt) verlustfrei zurückgelesen werden kann.

Project projectFromRow(ProjectRow row) {
  final map = jsonDecode(row.rawJson) as Map<String, dynamic>;
  // Views stehen nicht im rawJson (ProjectDto.toJSON lässt sie weg), sondern
  // in einer eigenen Spalte -> zurückspielen, damit List-/Kanban-Views
  // wieder rekonstruiert werden.
  map['views'] = jsonDecode(row.viewsJson);
  return ProjectDto.fromJson(map).toDomain();
}

Task taskFromRow(TaskRow row) {
  final map = jsonDecode(row.rawJson) as Map<String, dynamic>;
  return TaskDto.fromJson(map).toDomain();
}

Bucket bucketFromRow(BucketRow row) {
  final map = jsonDecode(row.rawJson) as Map<String, dynamic>;
  return BucketDto.fromJSON(map).toDomain();
}
