import 'package:drift/drift.dart';

/// n:m-Relation Task<->Label. Kein eigenes remoteId/rawJson nötig, die
/// Relation selbst ist die Nutzlast; [isDirty] markiert lokale
/// Änderungen (Hinzufügen/Entfernen), die noch auf den Push warten.
@DataClassName('TaskLabelRow')
class TaskLabels extends Table {
  IntColumn get taskId => integer()();
  IntColumn get labelId => integer()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {taskId, labelId};
}
