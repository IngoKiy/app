import 'package:drift/drift.dart';

/// n:m-Relation Task<->User (Assignee). Analog zu [TaskLabels].
@DataClassName('TaskAssigneeRow')
class TaskAssignees extends Table {
  IntColumn get taskId => integer()();
  IntColumn get userId => integer()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {taskId, userId};
}
