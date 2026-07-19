import 'package:drift/drift.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/data/local/tables/projects_table.dart';

part 'projects_dao.g.dart';

@DriftAccessor(tables: [Projects])
class ProjectsDao extends DatabaseAccessor<AppDatabase>
    with _$ProjectsDaoMixin {
  ProjectsDao(super.db);

  Stream<List<ProjectRow>> watchProjects() =>
      (select(projects)
            ..where((p) => p.isDeleted.equals(false))
            ..orderBy([(p) => OrderingTerm(expression: p.position)]))
          .watch();

  Stream<ProjectRow?> watchProject(int id) =>
      (select(projects)..where((p) => p.id.equals(id))).watchSingleOrNull();

  Future<ProjectRow?> getById(int id) =>
      (select(projects)..where((p) => p.id.equals(id))).getSingleOrNull();

  /// Merge vom Server: legt neue Projekte an bzw. aktualisiert bestehende
  /// per [ProjectsCompanion.remoteId]. Ist der lokale Datensatz dirty
  /// (unpushte lokale Änderung), wird er NICHT überschrieben.
  Future<void> upsertFromServer(ProjectsCompanion data) async {
    final remoteId = data.remoteId.value;
    if (remoteId == null) {
      throw ArgumentError('upsertFromServer benötigt eine remoteId');
    }
    final existing = await (select(
      projects,
    )..where((p) => p.remoteId.equals(remoteId))).getSingleOrNull();

    if (existing != null && existing.isDirty) return;

    final localId = existing?.id ?? remoteId;
    await into(
      projects,
    ).insertOnConflictUpdate(data.copyWith(id: Value(localId)));
  }

  /// Speichert eine lokale Änderung (Create/Update durch den Nutzer) und
  /// markiert den Datensatz als dirty, damit der Pull-Sync ihn nicht
  /// überschreibt, bis er gepusht wurde.
  Future<void> upsertLocal(ProjectsCompanion data) async {
    await into(
      projects,
    ).insertOnConflictUpdate(data.copyWith(isDirty: const Value(true)));
  }

  /// Löscht alle nicht-dirty Datensätze, deren remoteId nicht in
  /// [keepRemoteIds] enthalten ist (z.B. am Ende eines Full-Pull-Sync).
  /// Rein lokale, noch nie synchronisierte Datensätze (remoteId == null)
  /// bleiben unangetastet.
  Future<int> deleteMissingClean(Iterable<int> keepRemoteIds) {
    return (delete(projects)..where(
          (p) =>
              p.isDirty.equals(false) &
              p.remoteId.isNotNull() &
              p.remoteId.isNotIn(keepRemoteIds),
        ))
        .go();
  }

  Future<int> wipeAll() => delete(projects).go();
}
