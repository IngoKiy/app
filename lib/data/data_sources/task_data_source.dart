import 'dart:async';

import 'package:background_downloader/background_downloader.dart';
import 'package:vikunja_app/core/network/remote_data_source.dart';
import 'package:vikunja_app/core/network/response.dart';
import 'package:vikunja_app/data/models/task_attachment_dto.dart';
import 'package:vikunja_app/data/models/task_dto.dart';

class TaskDataSource extends RemoteDataSource {
  TaskDataSource(super.client);

  Future<Response<TaskDto>> add(int projectId, TaskDto task) {
    return client.put(
      url: '/projects/$projectId/tasks',
      body: task.toJSON(),
      mapper: (body) {
        return TaskDto.fromJson(body);
      },
    );
  }

  Future<Response<Object>> delete(int taskId) async {
    return client.delete(url: '/tasks/$taskId');
  }

  Future<Response<TaskDto>> update(TaskDto task) async {
    return await client.post(
      url: '/tasks/${task.id}',
      body: task.toJSON(),
      mapper: (body) {
        return TaskDto.fromJson(body);
      },
    );
  }

  Future<Response<List<TaskDto>>> getAllByProject(
    int projectId, [
    Map<String, List<String>>? queryParameters,
  ]) {
    return client.get(
      url: '/projects/$projectId/tasks',
      mapper: (body) {
        return convertList(body, (result) => TaskDto.fromJson(result));
      },
      queryParameters: queryParameters,
    );
  }

  Future<Response<TaskDto>> getTask(int taskId) async {
    return await client.get(
      url: '/tasks/$taskId',
      mapper: (body) {
        return TaskDto.fromJson(body);
      },
    );
  }

  Future<Response<List<TaskDto>>> getAllByProjectView(
    int projectId,
    int view, [
    Map<String, List<String>>? queryParameters,
  ]) {
    return client.get(
      url: '/projects/$projectId/views/$view/tasks',
      mapper: (body) {
        return convertList(body, (result) => TaskDto.fromJson(result));
      },
      queryParameters: queryParameters,
    );
  }

  Future<Response<List<TaskDto>>> getByFilterString(
    String filterString, [
    Map<String, List<String>>? queryParameters,
  ]) async {
    Map<String, List<String>> parameters = {
      "filter": [filterString],
      ...?queryParameters,
    };

    return await client.get(
      url: '/tasks',
      mapper: (body) {
        return convertList(body, (result) => TaskDto.fromJson(result));
      },
      queryParameters: parameters,
    );
  }

  Future<Response<List<TaskAttachmentDto>>> uploadAttachments(
    int taskId,
    List<String> filePaths,
  ) {
    return client.uploadFiles(
      url: '/tasks/$taskId/attachments',
      filePaths: filePaths,
      mapper: (body) {
        final success = (body['success'] as List<dynamic>?) ?? [];
        return success
            .map((e) => TaskAttachmentDto.fromJSON(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<Response<Object>> deleteAttachment(int taskId, int attachmentId) {
    return client.delete(url: '/tasks/$taskId/attachments/$attachmentId');
  }

  /// URL zum direkten Laden eines Anhangs (z. B. für Bild-Vorschauen).
  /// [previewSize]: sm, md, lg oder xl liefert für Bilder eine verkleinerte Vorschau.
  String attachmentUrl(int taskId, int attachmentId, {String? previewSize}) {
    var url = '${client.apiBase}/tasks/$taskId/attachments/$attachmentId';
    if (previewSize != null) {
      url += '?preview_size=$previewSize';
    }
    return url;
  }

  Future<Map<String, String>> authHeaders() => client.getHeaders();

  Future<TaskStatusUpdate> downloadAttachment(
    int taskId,
    TaskAttachmentDto attachment,
  ) async {
    String url = client.apiBase;
    url += '/tasks/$taskId/attachments/${attachment.id}';

    final task = DownloadTask(
      url: url,
      baseDirectory: BaseDirectory.applicationSupport,
      filename: attachment.file.name,
      headers: await client.getHeaders(),
      updates: Updates.statusAndProgress,
    );

    return await FileDownloader().download(task);
  }
}
