import 'package:drift/drift.dart';
import 'package:vikunja_app/data/local/tables/sync_columns.dart';

@DataClassName('BucketRow')
class Buckets extends Table with SyncColumns {
  IntColumn get id => integer()();
  IntColumn get projectId => integer()();
  IntColumn get viewId => integer().nullable()();
  TextColumn get title => text()();
  RealColumn get position => real().withDefault(const Constant(0))();
  IntColumn get taskLimit => integer().nullable()();
  BoolColumn get isDoneBucket =>
      boolean().withDefault(const Constant(false))();
  TextColumn get rawJson => text()();

  @override
  Set<Column> get primaryKey => {id};
}
