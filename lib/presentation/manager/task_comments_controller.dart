import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vikunja_app/core/di/network_provider.dart';
import 'package:vikunja_app/core/di/offline_provider.dart';
import 'package:vikunja_app/core/di/repository_provider.dart';
import 'package:vikunja_app/core/offline/offline_writer.dart';
import 'package:vikunja_app/data/models/task_comment_dto.dart';
import 'package:vikunja_app/domain/entities/task_comment.dart';

part 'task_comments_controller.g.dart';

@riverpod
class TaskCommentsController extends _$TaskCommentsController {
  @override
  Future<List<TaskComment>> build(int taskId) async {
    var response = await ref.read(taskCommentRepositoryProvider).getAll(taskId);
    if (response.isSuccessful) {
      return response.toSuccess().body;
    } else if (response.isException) {
      throw Exception(response.toException().message);
    } else {
      throw Exception(response.toError().error);
    }
  }

  Future<void> reload() async {
    var response = await ref.read(taskCommentRepositoryProvider).getAll(taskId);
    if (response.isSuccessful) {
      state = AsyncData(response.toSuccess().body);
    } else if (response.isException) {
      state = AsyncError(
        response.toException().message,
        response.toException().stackTrace,
      );
    } else {
      state = AsyncError(response.toError().error, StackTrace.empty);
    }
  }

  /// Schreibpfade laufen über den [OfflineWriter] (lokal + Outbox). Die Liste
  /// wird optimistisch gepatcht statt online neu geladen, damit sie auch offline
  /// aktuell bleibt.
  Future<bool> addComment(String text) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return false;

    final result = await ref
        .read(offlineWriterProvider)
        .addComment(taskId, text, currentUser);
    if (!result.ok) return false;

    final added = result.status == OfflineWriteStatus.synced
        ? (result.body as TaskCommentDto).toDomain()
        : TaskComment(comment: text, author: currentUser);
    state = AsyncData([...(state.value ?? const []), added]);
    return true;
  }

  Future<bool> updateComment(TaskComment comment, String text) async {
    final result = await ref
        .read(offlineWriterProvider)
        .updateComment(taskId, comment, text);
    if (!result.ok) return false;

    state = AsyncData([
      for (final c in state.value ?? const <TaskComment>[])
        if (c.id == comment.id)
          TaskComment(
            id: comment.id,
            comment: text,
            author: comment.author,
            created: comment.created,
          )
        else
          c,
    ]);
    return true;
  }

  Future<bool> deleteComment(int commentId) async {
    final result = await ref
        .read(offlineWriterProvider)
        .deleteComment(taskId, commentId);
    if (!result.ok) return false;

    state = AsyncData(
      (state.value ?? const <TaskComment>[])
          .where((c) => c.id != commentId)
          .toList(),
    );
    return true;
  }
}
