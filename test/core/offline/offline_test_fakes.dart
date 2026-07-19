import 'package:vikunja_app/core/network/response.dart';
import 'package:vikunja_app/core/offline/offline_writer.dart';
import 'package:vikunja_app/core/offline/op_executor.dart';
import 'package:vikunja_app/core/offline/outbox.dart';
import 'package:vikunja_app/core/offline/push_processor.dart';
import 'package:vikunja_app/core/offline/temp_ids.dart';
import 'package:vikunja_app/data/data_sources/bucket_data_source.dart';
import 'package:vikunja_app/data/data_sources/label_data_source.dart';
import 'package:vikunja_app/data/data_sources/project_data_source.dart';
import 'package:vikunja_app/data/data_sources/project_view_data_source.dart';
import 'package:vikunja_app/data/data_sources/task_comment_data_source.dart';
import 'package:vikunja_app/data/data_sources/task_data_source.dart';
import 'package:vikunja_app/data/data_sources/task_label_bulk_data_source.dart';
import 'package:vikunja_app/data/data_sources/user_data_source.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/data/models/task_comment_dto.dart';
import 'package:vikunja_app/data/models/task_dto.dart';
import 'package:vikunja_app/data/models/user_dto.dart';

/// Gemeinsame Fakes + Builder für OfflineWriter-/OpExecutor-Tests.
///
/// Unstubbte Methoden liefern standardmäßig eine [ExceptionResponse] (offline),
/// damit „offline"-Tests ohne Stub auskommen; „online"-Tests setzen den
/// jeweiligen Stub.

Response<T> _offline<T>() =>
    ExceptionResponse<T>(Exception('offline'), StackTrace.empty);

class FakeTaskDataSource implements TaskDataSource {
  FakeTaskDataSource([List<String>? log]) : log = log ?? [];
  final List<String> log;

  Response<TaskDto> Function(int projectId, TaskDto task)? addStub;
  Response<TaskDto> Function(TaskDto task)? updateStub;
  Response<Object> Function(int taskId)? deleteStub;
  Response<Object> Function(int taskId, List<UserDto> assignees)? assigneesStub;

  @override
  Future<Response<TaskDto>> add(int projectId, TaskDto task) async {
    log.add('add(project=$projectId,id=${task.id})');
    return addStub?.call(projectId, task) ?? _offline();
  }

  @override
  Future<Response<TaskDto>> update(TaskDto task) async {
    log.add('update(id=${task.id})');
    return updateStub?.call(task) ?? _offline();
  }

  @override
  Future<Response<Object>> delete(int taskId) async {
    log.add('delete(id=$taskId)');
    return deleteStub?.call(taskId) ?? _offline();
  }

  @override
  Future<Response<Object>> setAssignees(int taskId, List<UserDto> assignees) async {
    log.add('setAssignees(task=$taskId,n=${assignees.length})');
    return assigneesStub?.call(taskId, assignees) ?? _offline();
  }

  @override
  dynamic noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
}

class FakeCommentDataSource implements TaskCommentDataSource {
  FakeCommentDataSource([List<String>? log]) : log = log ?? [];
  final List<String> log;

  Response<TaskCommentDto> Function(int taskId, TaskCommentDto c)? createStub;
  Response<TaskCommentDto> Function(int taskId, TaskCommentDto c)? updateStub;
  Response<Object> Function(int taskId, int commentId)? deleteStub;

  @override
  Future<Response<TaskCommentDto>> create(int taskId, TaskCommentDto c) async {
    log.add('comment.create(task=$taskId)');
    return createStub?.call(taskId, c) ?? _offline();
  }

  @override
  Future<Response<TaskCommentDto>> update(int taskId, TaskCommentDto c) async {
    log.add('comment.update(task=$taskId,id=${c.id})');
    return updateStub?.call(taskId, c) ?? _offline();
  }

  @override
  Future<Response<Object>> delete(int taskId, int commentId) async {
    log.add('comment.delete(task=$taskId,id=$commentId)');
    return deleteStub?.call(taskId, commentId) ?? _offline();
  }

  @override
  dynamic noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
}

class _FakeProjectDataSource implements ProjectDataSource {
  @override
  dynamic noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
}

class _FakeBucketDataSource implements BucketDataSource {
  @override
  dynamic noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
}

class _FakeTaskLabelBulkDataSource implements TaskLabelBulkDataSource {
  @override
  dynamic noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
}

class _FakeLabelDataSource implements LabelDataSource {
  @override
  dynamic noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
}

class _FakeProjectViewDataSource implements ProjectViewDataSource {
  @override
  dynamic noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
}

class _FakeUserDataSource implements UserDataSource {
  @override
  dynamic noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
}

/// Baut einen [OpExecutor] über einer Test-DB mit (optional) gestubbten
/// Task-/Kommentar-Data-Sources.
OpExecutor buildExecutor(
  AppDatabase db, {
  FakeTaskDataSource? task,
  FakeCommentDataSource? comment,
}) => OpExecutor(
  db: db,
  taskDataSource: task ?? FakeTaskDataSource(),
  taskCommentDataSource: comment ?? FakeCommentDataSource(),
  projectDataSource: _FakeProjectDataSource(),
  bucketDataSource: _FakeBucketDataSource(),
  taskLabelBulkDataSource: _FakeTaskLabelBulkDataSource(),
  labelDataSource: _FakeLabelDataSource(),
  projectViewDataSource: _FakeProjectViewDataSource(),
  userDataSource: _FakeUserDataSource(),
  tasksDao: db.tasksDao,
  projectsDao: db.projectsDao,
  bucketsDao: db.bucketsDao,
  labelsDao: db.labelsDao,
  taskCommentsDao: db.taskCommentsDao,
  pendingOpsDao: db.pendingOpsDao,
  keyValueDao: db.keyValueDao,
);

Outbox buildOutbox(AppDatabase db) => Outbox(
  pendingOpsDao: db.pendingOpsDao,
  tempIds: TempIdAllocator(db: db, keyValueDao: db.keyValueDao),
);

/// Baut einen [PushProcessor] über derselben Test-DB, der den geteilten
/// [OpExecutor] mit denselben Fakes benutzt (für Ende-zu-Ende-Tests).
PushProcessor buildPushProcessor(
  AppDatabase db, {
  FakeTaskDataSource? task,
  FakeCommentDataSource? comment,
}) {
  final t = task ?? FakeTaskDataSource();
  final c = comment ?? FakeCommentDataSource();
  return PushProcessor(
    db: db,
    taskDataSource: t,
    taskCommentDataSource: c,
    projectDataSource: _FakeProjectDataSource(),
    bucketDataSource: _FakeBucketDataSource(),
    taskLabelBulkDataSource: _FakeTaskLabelBulkDataSource(),
    labelDataSource: _FakeLabelDataSource(),
    projectViewDataSource: _FakeProjectViewDataSource(),
    userDataSource: _FakeUserDataSource(),
    tasksDao: db.tasksDao,
    projectsDao: db.projectsDao,
    bucketsDao: db.bucketsDao,
    labelsDao: db.labelsDao,
    taskCommentsDao: db.taskCommentsDao,
    pendingOpsDao: db.pendingOpsDao,
    keyValueDao: db.keyValueDao,
    executor: buildExecutor(db, task: t, comment: c),
  );
}

OfflineWriter buildWriter(AppDatabase db, OpExecutor executor) => OfflineWriter(
  db: db,
  outbox: buildOutbox(db),
  executor: executor,
  tasksDao: db.tasksDao,
  projectsDao: db.projectsDao,
  bucketsDao: db.bucketsDao,
  labelsDao: db.labelsDao,
  taskCommentsDao: db.taskCommentsDao,
  taskLabelsDao: db.taskLabelsDao,
  taskAssigneesDao: db.taskAssigneesDao,
  pendingOpsDao: db.pendingOpsDao,
  keyValueDao: db.keyValueDao,
);
