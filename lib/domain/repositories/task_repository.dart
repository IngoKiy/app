import 'dart:async';

import 'package:background_downloader/background_downloader.dart'
    show TaskStatusUpdate;
import 'package:vikunja_app/core/network/response.dart';
import 'package:vikunja_app/domain/entities/task.dart';
import 'package:vikunja_app/domain/entities/task_attachment.dart';
import 'package:vikunja_app/domain/entities/user.dart';

abstract class TaskRepository {
  Future<Response<Task>> add(int projectId, Task task);

  Future delete(int taskId);

  Future<Response<Task>> update(Task task);

  Future<Response<Task>> getTask(int id);

  Future<Response<List<Task>>> getAllByProject(
    int projectId, [
    Map<String, List<String>>? queryParameters,
  ]);

  Future<Response<List<Task>>> getAllByProjectView(
    int projectId,
    int view, [
    Map<String, List<String>>? queryParameters,
  ]);

  Future<Response<List<Task>>> getByFilterString(
    String filterString, [
    Map<String, List<String>>? queryParameters,
  ]);

  Future<TaskStatusUpdate> downloadAttachment(
    int taskId,
    TaskAttachment attachment, {
    void Function(double)? onProgress,
  });

  /// Setzt die komplette Zuweisungsliste einer Aufgabe (ersetzt vorhandene).
  Future<Response<Object>> setAssignees(int taskId, List<User> assignees);

  /// Nutzer mit Zugriff auf das Projekt (für die Zuweisungs-Auswahl).
  Future<Response<List<User>>> getAssignableUsers(
    int projectId, [
    String? query,
  ]);

  Future<Response<List<TaskAttachment>>> uploadAttachments(
    int taskId,
    List<String> filePaths,
  );

  Future<Response<Object>> deleteAttachment(int taskId, int attachmentId);

  /// URL zum direkten Laden eines Anhangs; für Bilder liefert
  /// [previewSize] (sm/md/lg/xl) eine verkleinerte Vorschau.
  String attachmentUrl(int taskId, int attachmentId, {String? previewSize});

  /// Auth-Header für das direkte Laden von Anhängen (z. B. Image.network).
  Future<Map<String, String>> attachmentHeaders();
}
