import 'package:drift/drift.dart';
import 'package:vikunja_app/data/local/tables/sync_columns.dart';

@DataClassName('UserRow')
class Users extends Table with SyncColumns {
  IntColumn get id => integer()();
  TextColumn get username => text()();
  TextColumn get name => text().withDefault(const Constant(''))();
  TextColumn get rawJson => text()();

  @override
  Set<Column> get primaryKey => {id};
}
