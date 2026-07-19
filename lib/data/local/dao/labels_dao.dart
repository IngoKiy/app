import 'package:drift/drift.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/data/local/tables/labels_table.dart';

part 'labels_dao.g.dart';

@DriftAccessor(tables: [Labels])
class LabelsDao extends DatabaseAccessor<AppDatabase> with _$LabelsDaoMixin {
  LabelsDao(super.db);

  Stream<List<LabelRow>> watchAllLabels() =>
      (select(labels)..where((l) => l.isDeleted.equals(false))).watch();

  Stream<LabelRow?> watchLabel(int id) =>
      (select(labels)..where((l) => l.id.equals(id))).watchSingleOrNull();

  Future<LabelRow?> getById(int id) =>
      (select(labels)..where((l) => l.id.equals(id))).getSingleOrNull();

  /// Merge vom Server, siehe [ProjectsDao.upsertFromServer].
  Future<void> upsertFromServer(LabelsCompanion data) async {
    final remoteId = data.remoteId.value;
    if (remoteId == null) {
      throw ArgumentError('upsertFromServer benötigt eine remoteId');
    }
    final existing = await (select(
      labels,
    )..where((l) => l.remoteId.equals(remoteId))).getSingleOrNull();

    if (existing != null && existing.isDirty) return;

    final localId = existing?.id ?? remoteId;
    await into(
      labels,
    ).insertOnConflictUpdate(data.copyWith(id: Value(localId)));
  }

  Future<void> upsertLocal(LabelsCompanion data) async {
    await into(
      labels,
    ).insertOnConflictUpdate(data.copyWith(isDirty: const Value(true)));
  }

  Future<int> deleteMissingClean(Iterable<int> keepRemoteIds) {
    return (delete(labels)..where(
          (l) =>
              l.isDirty.equals(false) &
              l.remoteId.isNotNull() &
              l.remoteId.isNotIn(keepRemoteIds),
        ))
        .go();
  }

  Future<int> wipeAll() => delete(labels).go();
}
