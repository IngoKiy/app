import 'dart:async';

import 'package:background_downloader/background_downloader.dart'
    show TaskStatusUpdate;
import 'package:vikunja_app/core/network/response.dart';
import 'package:vikunja_app/core/utils/mapping_extensions.dart';
import 'package:vikunja_app/data/data_sources/task_data_source.dart';
import 'package:vikunja_app/data/models/task_attachment_dto.dart';
import 'package:vikunja_app/data/models/task_dto.dart';
import 'package:vikunja_app/data/models/user_dto.dart';
import 'package:vikunja_app/domain/entities/task.dart';
import 'package:vikunja_app/domain/entities/task_attachment.dart';
import 'package:vikunja_app/domain/entities/user.dart';
import 'package:vikunja_app/domain/repositories/task_repository.dart';

class TaskRepositoryImpl extends TaskRepository {
  final TaskDataSource _dataSource;

  TaskRepositoryImpl(this._dataSource);

  @override
  Future<Response<Task>> add(int projectId, Task task) async {
    return (await _dataSource.add(
      projectId,
      TaskDto.fromDomain(task),
    )).toDomain();
  }

  @override
  Future<Response<Object>> delete(int taskId) async {
    return _dataSource.delete(taskId);
  }

  @override
  Future<Response<Task>> update(Task task) async {
    return (await _dataSource.update(TaskDto.fromDomain(task))).toDomain();
  }

  @override
  Future<Response<Task>> getTask(int id) async {
    return (await _dataSource.getTask(id)).toDomain();
  }

  @override
  Future<Response<List<Task>>> getAllByProject(
    int projectId, [
    Map<String, List<String>>? queryParameters,
  ]) async {
    var response = await _dataSource.getAllByProject(
      projectId,
      queryParameters,
    );

    return response.toDomain();
  }

  @override
  Future<Response<List<Task>>> getAllByProjectView(
    int projectId,
    int view, [
    Map<String, List<String>>? queryParameters,
  ]) async {
    var response = await _dataSource.getAllByProjectView(
      projectId,
      view,
      queryParameters,
    );

    return response.toDomain();
  }

  @override
  Future<Response<List<Task>>> getByFilterString(
    String filterString, [
    Map<String, List<String>>? queryParameters,
  ]) async {
    return (await _dataSource.getByFilterString(
      filterString,
      queryParameters,
    )).toDomain();
  }

  @override
  Future<TaskStatusUpdate> downloadAttachment(
    int taskId,
    TaskAttachment attachment,
  ) async {
    return _dataSource.downloadAttachment(
      taskId,
      TaskAttachmentDto.fromDomain(attachment),
    );
  }

  @override
  Future<Response<Object>> setAssignees(int taskId, List<User> assignees) {
    return _dataSource.setAssignees(
      taskId,
      assignees.map((e) => UserDto.fromDomain(e)).toList(),
    );
  }

  @override
  Future<Response<List<User>>> getAssignableUsers(
    int projectId, [
    String? query,
  ]) async {
    return (await _dataSource.getAssignableUsers(projectId, query)).toDomain();
  }

  @override
  Future<Response<List<TaskAttachment>>> uploadAttachments(
    int taskId,
    List<String> filePaths,
  ) async {
    return (await _dataSource.uploadAttachments(taskId, filePaths)).toDomain();
  }

  @override
  Future<Response<Object>> deleteAttachment(int taskId, int attachmentId) {
    return _dataSource.deleteAttachment(taskId, attachmentId);
  }

  @override
  String attachmentUrl(int taskId, int attachmentId, {String? previewSize}) {
    return _dataSource.attachmentUrl(
      taskId,
      attachmentId,
      previewSize: previewSize,
    );
  }

  @override
  Future<Map<String, String>> attachmentHeaders() {
    return _dataSource.authHeaders();
  }
}
