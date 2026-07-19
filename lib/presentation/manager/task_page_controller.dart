import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vikunja_app/core/di/database_provider.dart';
import 'package:vikunja_app/core/di/network_provider.dart';
import 'package:vikunja_app/core/di/notification_provider.dart';
import 'package:vikunja_app/core/di/repository_provider.dart';
import 'package:vikunja_app/core/di/sync_provider.dart';
import 'package:vikunja_app/core/sync/dto_companion_mapper.dart';
import 'package:vikunja_app/data/local/row_mappers.dart';
import 'package:vikunja_app/data/models/task_dto.dart';
import 'package:vikunja_app/domain/entities/task.dart';
import 'package:vikunja_app/domain/entities/task_page_model.dart';
import 'package:vikunja_app/presentation/manager/widget_controller.dart';

part 'task_page_controller.g.dart';

/// Übersicht (Landing-Page). Standardfälle (offene Tasks, optional nur mit
/// Fälligkeit) kommen reaktiv aus der DB. Ein benutzerdefinierter Übersichts-
/// Filter (filter_id) wird online geladen; schlägt das fehl (offline), fällt
/// er auf den DB-Standard zurück (lokaler Filter-Evaluator kommt in M3).
@riverpod
class TaskPageController extends _$TaskPageController {
  static const _mapper = DtoCompanionMapper();

  @override
  Future<TaskPageModel> build() async {
    final filterId = _overviewFilterId();
    if (filterId != null) {
      final online = await _loadFilteredOnline(filterId);
      if (online != null) return online;
      // offline/Fehler -> Fallback auf DB-Standard.
    }
    return _watchStandard();
  }

  int? _overviewFilterId() {
    final user = ref.read(currentUserProvider);
    final settings = user?.settings?.frontendSettings;
    final filterId = settings?['filter_id_used_on_overview'];
    if (filterId is int && filterId != 0) return filterId;
    return null;
  }

  /// Standardfall: offene Tasks projektübergreifend, reaktiv aus der DB.
  Future<TaskPageModel> _watchStandard() async {
    final onlyDue = await ref
        .read(settingsRepositoryProvider)
        .getLandingPageOnlyDueDateTasks();

    final dao = ref.read(tasksDaoProvider);
    final completer = Completer<TaskPageModel>();

    final sub = dao.watchOverviewTasks(onlyDueDate: onlyDue).listen((rows) async {
      final tasks = rows.map(taskFromRow).toList();
      final model = await _createPageModel(tasks, onlyDue, isInitial: !completer.isCompleted);
      if (!completer.isCompleted) {
        completer.complete(model);
      } else {
        state = AsyncData(model);
      }
    });
    ref.onDispose(sub.cancel);

    return completer.future;
  }

  /// Benutzerdefinierter Übersichts-Filter: online wie bisher. Rückgabe null
  /// signalisiert offline/Fehler -> Aufrufer fällt auf den DB-Standard zurück.
  Future<TaskPageModel?> _loadFilteredOnline(int filterId) async {
    final onlyDue = await ref
        .read(settingsRepositoryProvider)
        .getLandingPageOnlyDueDateTasks();

    final response = await ref
        .read(taskRepositoryProvider)
        .getAllByProject(filterId, {
          "sort_by": ["due_date", "id"],
          "order_by": ["asc", "desc"],
          "page": ["1"],
        });

    if (response.isSuccessful) {
      return _createPageModel(
        response.toSuccess().body,
        onlyDue,
        isInitial: true,
      );
    }
    return null;
  }

  Future<TaskPageModel> _createPageModel(
    List<Task> tasks,
    bool onlyDue, {
    bool isInitial = false,
  }) async {
    // Projekte lokal zuordnen (für Untertitel etc.).
    final projectRows = await ref.read(projectsDaoProvider).getAll();
    final projectsById = {for (final r in projectRows) r.id: projectFromRow(r)};
    for (final task in tasks) {
      task.project = projectsById[task.projectId];
    }

    final defaultProjectId =
        ref.read(currentUserProvider)?.settings?.defaultProjectId ?? 0;

    // Seiteneffekte (Home-Widget/Notifications) nur beim ersten Aufbau, damit
    // Stream-Updates nicht bei jedem DB-Tick neu aufgebaut werden.
    // Datenquelle ist ab M3 die lokale DB (siehe widget_controller.dart /
    // notifications.dart), kein Netzwerk-Aufruf mehr nötig.
    if (isInitial) {
      final dao = ref.read(tasksDaoProvider);
      unawaited(updateWidget(tasksDao: dao).catchError((_) {}));
      ref.read(notificationProvider)?.scheduleDueNotifications(dao);
    }

    return TaskPageModel(tasks, onlyDue, defaultProjectId, false);
  }

  /// Pull-to-Refresh: Voll-Pull anstoßen und neu aufbauen (deckt auch den
  /// Online-Filterpfad ab).
  Future<void> reload() async {
    unawaited(ref.read(syncServiceProvider).syncNow());
    ref.invalidateSelf();
  }

  /// Pagination entfällt bei DB-Reads (alles lokal) — No-Op für API-Kompat.
  Future<void> loadNextPage() async {}

  Future<void> setLandingPageOnlyDueDateTasks(bool newValue) async {
    await ref
        .read(settingsRepositoryProvider)
        .setLandingPageOnlyDueDateTasks(newValue);
    ref.invalidateSelf();
  }

  Future<bool> addTask(int projectId, Task task) async {
    final response = await ref.read(taskRepositoryProvider).add(projectId, task);
    if (response.isSuccessful) {
      await _upsertTask(response.toSuccess().body, projectId: projectId);
      return true;
    }
    return false;
  }

  Future<bool> deleteTask(int id) async {
    final response = await ref.read(taskRepositoryProvider).delete(id);
    if (response.isSuccessful) {
      await ref.read(tasksDaoProvider).deleteById(id);
      return true;
    }
    return false;
  }

  Future<bool> updateTask(Task task) async {
    final response = await ref.read(taskRepositoryProvider).update(task);
    if (response.isSuccessful) {
      await _upsertTask(response.toSuccess().body, projectId: task.projectId);
      return true;
    }
    return false;
  }

  Future<bool> markAsDone(Task task) async {
    task.done = true;
    final response = await ref.read(taskRepositoryProvider).update(task);
    if (response.isSuccessful) {
      await _upsertTask(response.toSuccess().body, projectId: task.projectId);
      return true;
    }
    return false;
  }

  Future<void> _upsertTask(Task task, {int? projectId}) {
    return ref
        .read(tasksDaoProvider)
        .upsertFromServer(
          _mapper.task(
            TaskDto.fromDomain(task),
            DateTime.now(),
            projectId: projectId ?? task.projectId,
          ),
        );
  }
}
