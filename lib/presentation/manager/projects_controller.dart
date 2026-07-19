import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vikunja_app/core/di/database_provider.dart';
import 'package:vikunja_app/core/di/offline_provider.dart';
import 'package:vikunja_app/core/di/sync_provider.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/data/local/row_mappers.dart';
import 'package:vikunja_app/domain/entities/project.dart';
import 'package:vikunja_app/domain/entities/project_list_model.dart';

part 'projects_controller.g.dart';

/// Liest die Projektliste reaktiv aus der lokalen DB (watch-Stream). Schreib-
/// Methoden laufen über den [OfflineWriter] (lokal anwenden + Outbox).
@riverpod
class ProjectsController extends _$ProjectsController {
  @override
  Future<ProjectListModel> build() {
    final dao = ref.watch(projectsDaoProvider);
    final completer = Completer<ProjectListModel>();

    final sub = dao.watchProjects().listen((rows) {
      final model = _toModel(rows);
      if (!completer.isCompleted) {
        completer.complete(model);
      } else {
        state = AsyncData(model);
      }
    });
    ref.onDispose(sub.cancel);

    return completer.future;
  }

  ProjectListModel _toModel(List<ProjectRow> rows) {
    final projects = rows.map(projectFromRow).toList();
    final topLevel = projects.where((p) => p.parentProjectId == 0).toList();
    for (final p in topLevel) {
      _findSubproject(p, projects);
    }
    return ProjectListModel(topLevel);
  }

  void _findSubproject(Project project, List<Project> projects) {
    project.subprojects = projects
        .where((e) => e.parentProjectId == project.id)
        .toList();
    for (final e in project.subprojects) {
      _findSubproject(e, projects);
    }
  }

  /// Pull-to-Refresh: stößt einen Voll-Pull an; die DB-Streams liefern das
  /// Ergebnis. Fehler (offline) werden vom SyncService still behandelt.
  Future<void> reload() => ref.read(syncServiceProvider).syncNow();

  /// Pagination entfällt bei DB-Reads (alles lokal) — No-Op für API-Kompat.
  Future<void> loadNextPage() async {}

  void create(Project project) async {
    // Lokal anlegen + online versuchen; bei Netzwerkfehler in die Outbox. Der
    // DB-Stream aktualisiert die UI (optimistisch).
    await ref.read(offlineWriterProvider).createProject(project);
  }
}
