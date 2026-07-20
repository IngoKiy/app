import 'dart:ui';

import 'package:vikunja_app/domain/entities/project_view.dart';
import 'package:vikunja_app/domain/entities/user.dart';

class Project {
  int id;
  double position;
  User? owner;
  int parentProjectId;
  String description;
  String title;
  DateTime created, updated;
  Color? color;
  bool isArchived, isFavourite;
  List<ProjectView> views;

  Iterable<Project> subprojects = [];

  /// Vikunja liefert gespeicherte Filter als Pseudo-Projekte mit negativer ID
  /// (Formel: projectId = filterId * -1 - 1, also -2, -3, …). Die ID -1 ist das
  /// Favoriten-Pseudo-Projekt, echte Projekte haben positive IDs. Wird in der
  /// Projektliste genutzt, um Filter optisch von echten Projekten zu trennen.
  /// Hinweis: Offline erzeugte Projekte tragen kurzzeitig ebenfalls negative
  /// Temp-IDs; nach dem Sync erhalten sie ihre positive Server-ID.
  bool get isSavedFilter => id < -1;

  Project({
    this.id = 0,
    this.owner,
    this.parentProjectId = 0,
    this.description = '',
    this.position = 0,
    this.color,
    this.isArchived = false,
    this.isFavourite = false,
    this.views = const [],
    required this.title,
    created,
    updated,
  }) : created = created ?? DateTime.now(),
       updated = updated ?? DateTime.now();

  Project copyWith({
    int? id,
    DateTime? created,
    DateTime? updated,
    String? title,
    User? owner,
    String? description,
    int? parentProjectId,
    Color? color,
    bool? isArchived,
    bool? isFavourite,
    int? doneBucketId,
    double? position,
  }) {
    return Project(
      id: id ?? this.id,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      title: title ?? this.title,
      owner: owner ?? this.owner,
      description: description ?? this.description,
      parentProjectId: parentProjectId ?? this.parentProjectId,
      color: color ?? this.color,
      isArchived: isArchived ?? this.isArchived,
      isFavourite: isFavourite ?? this.isFavourite,
      position: position ?? this.position,
    );
  }
}
