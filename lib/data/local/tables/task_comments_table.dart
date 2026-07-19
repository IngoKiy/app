import 'package:drift/drift.dart';
import 'package:vikunja_app/data/local/tables/sync_columns.dart';

@DataClassName('TaskCommentRow')
class TaskComments extends Table with SyncColumns {
  IntColumn get id => integer()();
  IntColumn get taskId => integer()();
  TextColumn get authorJson => text()();
  TextColumn get comment => text()();
  TextColumn get createdAt => text()();
  TextColumn get rawJson => text()();

  @override
  Set<Column> get primaryKey => {id};
}
