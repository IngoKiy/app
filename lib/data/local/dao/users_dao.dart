import 'package:drift/drift.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/data/local/tables/users_table.dart';

part 'users_dao.g.dart';

@DriftAccessor(tables: [Users])
class UsersDao extends DatabaseAccessor<AppDatabase> with _$UsersDaoMixin {
  UsersDao(super.db);

  Stream<List<UserRow>> watchAllUsers() => select(users).watch();

  Stream<UserRow?> watchUser(int id) =>
      (select(users)..where((u) => u.id.equals(id))).watchSingleOrNull();

  Future<UserRow?> getById(int id) =>
      (select(users)..where((u) => u.id.equals(id))).getSingleOrNull();

  /// Merge vom Server, siehe [ProjectsDao.upsertFromServer].
  Future<void> upsertFromServer(UsersCompanion data) async {
    final remoteId = data.remoteId.value;
    if (remoteId == null) {
      throw ArgumentError('upsertFromServer benötigt eine remoteId');
    }
    final existing = await (select(
      users,
    )..where((u) => u.remoteId.equals(remoteId))).getSingleOrNull();

    if (existing != null && existing.isDirty) return;

    final localId = existing?.id ?? remoteId;
    await into(users).insertOnConflictUpdate(data.copyWith(id: Value(localId)));
  }

  Future<void> upsertLocal(UsersCompanion data) async {
    await into(
      users,
    ).insertOnConflictUpdate(data.copyWith(isDirty: const Value(true)));
  }

  Future<int> deleteMissingClean(Iterable<int> keepRemoteIds) {
    return (delete(users)..where(
          (u) =>
              u.isDirty.equals(false) &
              u.remoteId.isNotNull() &
              u.remoteId.isNotIn(keepRemoteIds),
        ))
        .go();
  }

  Future<int> wipeAll() => delete(users).go();
}
