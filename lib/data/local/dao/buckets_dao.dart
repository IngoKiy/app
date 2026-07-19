import 'package:drift/drift.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/data/local/tables/buckets_table.dart';

part 'buckets_dao.g.dart';

@DriftAccessor(tables: [Buckets])
class BucketsDao extends DatabaseAccessor<AppDatabase> with _$BucketsDaoMixin {
  BucketsDao(super.db);

  Stream<List<BucketRow>> watchBucketsByProject(int projectId) =>
      (select(buckets)
            ..where(
              (b) =>
                  b.projectId.equals(projectId) & b.isDeleted.equals(false),
            )
            ..orderBy([(b) => OrderingTerm(expression: b.position)]))
          .watch();

  Stream<BucketRow?> watchBucket(int id) =>
      (select(buckets)..where((b) => b.id.equals(id))).watchSingleOrNull();

  Future<BucketRow?> getById(int id) =>
      (select(buckets)..where((b) => b.id.equals(id))).getSingleOrNull();

  /// Löscht eine einzelne Zeile (z.B. nach erfolgreichem Server-Delete).
  Future<int> deleteById(int id) =>
      (delete(buckets)..where((b) => b.id.equals(id))).go();

  /// Merge vom Server, siehe [ProjectsDao.upsertFromServer].
  Future<void> upsertFromServer(BucketsCompanion data) async {
    final remoteId = data.remoteId.value;
    if (remoteId == null) {
      throw ArgumentError('upsertFromServer benötigt eine remoteId');
    }
    final existing = await (select(
      buckets,
    )..where((b) => b.remoteId.equals(remoteId))).getSingleOrNull();

    if (existing != null && existing.isDirty) return;

    final localId = existing?.id ?? remoteId;
    await into(
      buckets,
    ).insertOnConflictUpdate(data.copyWith(id: Value(localId)));
  }

  Future<void> upsertLocal(BucketsCompanion data) async {
    await into(
      buckets,
    ).insertOnConflictUpdate(data.copyWith(isDirty: const Value(true)));
  }

  Future<int> deleteMissingClean(Iterable<int> keepRemoteIds) {
    return (delete(buckets)..where(
          (b) =>
              b.isDirty.equals(false) &
              b.remoteId.isNotNull() &
              b.remoteId.isNotIn(keepRemoteIds),
        ))
        .go();
  }

  /// Wie [deleteMissingClean], aber auf ein Projekt beschränkt (analog zu
  /// [TasksDao.deleteMissingCleanForProject]).
  Future<int> deleteMissingCleanForProject(
    int projectId,
    Iterable<int> keepRemoteIds,
  ) {
    return (delete(buckets)..where(
          (b) =>
              b.projectId.equals(projectId) &
              b.isDirty.equals(false) &
              b.remoteId.isNotNull() &
              b.remoteId.isNotIn(keepRemoteIds),
        ))
        .go();
  }

  Future<int> wipeAll() => delete(buckets).go();
}
