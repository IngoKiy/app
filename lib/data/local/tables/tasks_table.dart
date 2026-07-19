import 'package:drift/drift.dart';
import 'package:vikunja_app/data/local/tables/sync_columns.dart';

/// Lokale Tasks. Die einzelnen Spalten dienen Queries/Sortierung; die
/// Wahrheit für die Detailansicht (Reminders, Subtasks, Attachments, Labels,
/// Assignees) steckt im [rawJson] des kompletten TaskDto.
@DataClassName('TaskRow')
class Tasks extends Table with SyncColumns {
  IntColumn get id => integer()();
  IntColumn get projectId => integer()();
  IntColumn get bucketId => integer().nullable()();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  TextColumn get doneAt => text().nullable()();
  TextColumn get dueDate => text().nullable()();
  TextColumn get startDate => text().nullable()();
  TextColumn get endDate => text().nullable()();
  IntColumn get priority => integer().nullable()();
  RealColumn get percentDone => real().nullable()();
  RealColumn get position => real().nullable()();
  RealColumn get kanbanPosition => real().nullable()();
  TextColumn get identifier => text().withDefault(const Constant(''))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  /// Komplettes TaskDto-JSON (inkl. reminders/subtasks/attachments/labels/
  /// assignees) als Fallback für Felder ohne eigene Spalte.
  TextColumn get rawJson => text()();

  @override
  Set<Column> get primaryKey => {id};
}
