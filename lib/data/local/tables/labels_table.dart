import 'package:drift/drift.dart';
import 'package:vikunja_app/data/local/tables/sync_columns.dart';

@DataClassName('LabelRow')
class Labels extends Table with SyncColumns {
  IntColumn get id => integer()();
  TextColumn get title => text()();
  TextColumn get hexColor => text().nullable()();
  TextColumn get rawJson => text()();

  @override
  Set<Column> get primaryKey => {id};
}
