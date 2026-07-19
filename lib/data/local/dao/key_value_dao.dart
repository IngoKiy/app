import 'package:drift/drift.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/data/local/tables/key_value_table.dart';

part 'key_value_dao.g.dart';

@DriftAccessor(tables: [KeyValues])
class KeyValueDao extends DatabaseAccessor<AppDatabase>
    with _$KeyValueDaoMixin {
  KeyValueDao(super.db);

  Future<String?> get(String key) async {
    final row = await (select(
      keyValues,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Stream<String?> watch(String key) =>
      (select(keyValues)..where((t) => t.key.equals(key)))
          .watchSingleOrNull()
          .map((row) => row?.value);

  Future<void> set(String key, String value) => into(
    keyValues,
  ).insertOnConflictUpdate(KeyValuesCompanion.insert(key: key, value: value));

  Future<void> remove(String key) =>
      (delete(keyValues)..where((t) => t.key.equals(key))).go();

  Future<int> wipeAll() => delete(keyValues).go();
}
