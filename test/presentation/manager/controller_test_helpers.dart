import 'package:drift/native.dart';
import 'package:vikunja_app/core/sync/dto_companion_mapper.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/data/models/project_dto.dart';
import 'package:vikunja_app/data/models/project_view_dto.dart';
import 'package:vikunja_app/data/models/task_dto.dart';

/// Gemeinsame Seed-Helfer für die DB-first Controller-Tests. Legen Daten so an,
/// wie sie der Pull-Sync ablegt (rawJson + Spalten via DtoCompanionMapper).

final testTime = DateTime.utc(2026, 1, 1);
const testMapper = DtoCompanionMapper();

AppDatabase createTestDatabase() =>
    AppDatabase.forTesting(NativeDatabase.memory());

ProjectViewDto listViewDto({
  required int id,
  required int projectId,
}) => ProjectViewDto(
  testTime,
  0,
  0,
  id,
  0,
  projectId,
  'List View',
  testTime,
  null,
  null,
  'manual',
  'list',
);

Future<void> seedProject(
  AppDatabase db, {
  required int id,
  required String title,
  int parentProjectId = 0,
  double position = 0,
  List<ProjectViewDto> views = const [],
}) {
  final dto = ProjectDto(
    id: id,
    title: title,
    parentProjectId: parentProjectId,
    position: position,
    views: views,
    created: testTime,
    updated: testTime,
  );
  return db.projectsDao.upsertFromServer(testMapper.project(dto, testTime));
}

Future<void> seedTask(
  AppDatabase db, {
  required int id,
  required int projectId,
  String title = 'Task',
  double? position,
  bool done = false,
  DateTime? dueDate,
  int? priority,
}) {
  final dto = TaskDto(
    id: id,
    title: title,
    projectId: projectId,
    createdBy: null,
    done: done,
    position: position,
    dueDate: dueDate,
    priority: priority,
    created: testTime,
    updated: testTime,
  );
  return db.tasksDao.upsertFromServer(
    testMapper.task(dto, testTime, projectId: projectId),
  );
}
