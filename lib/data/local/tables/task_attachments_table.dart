import 'package:drift/drift.dart';
import 'package:vikunja_app/data/local/tables/sync_columns.dart';

@DataClassName('TaskAttachmentRow')
class TaskAttachments extends Table with SyncColumns {
  IntColumn get id => integer()();
  IntColumn get taskId => integer()();
  TextColumn get fileJson => text()();

  /// Pfad der lokal heruntergeladenen/erzeugten Datei, falls vorhanden.
  TextColumn get localFilePath => text().nullable()();
  TextColumn get rawJson => text()();

  @override
  Set<Column> get primaryKey => {id};
}
