import 'dart:async';
import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vikunja_app/core/di/database_provider.dart';
import 'package:vikunja_app/core/sync/filter/filter_ast.dart';
import 'package:vikunja_app/core/sync/filter/filter_evaluator.dart';
import 'package:vikunja_app/core/sync/filter/filter_parser.dart';
import 'package:vikunja_app/core/di/network_provider.dart';
import 'package:vikunja_app/core/di/notification_provider.dart';
import 'package:vikunja_app/core/di/offline_provider.dart';
import 'package:vikunja_app/core/di/repository_provider.dart';
import 'package:vikunja_app/core/di/sync_provider.dart';
import 'package:vikunja_app/data/local/row_mappers.dart';
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
  @override
  Future<TaskPageModel> build() async {
    final filterId = _overviewFilterId();
    if (filterId != null) {
      // M3/F1: gespeicherten Filter, sofern lokal verfügbar, direkt gegen den
      // Task-Stream auswerten (funktioniert offline). Nur wenn kein lokaler
      // Filterstring vorliegt oder er nicht auswertbar ist, den Online-Pfad
      // gehen.
      final expr = await _localFilterExpr(filterId);
      if (expr != null) return _watchFiltered(expr);

      final online = await _loadFilteredOnline(filterId);
      if (online != null) return online;
      // offline/Fehler -> Fallback auf DB-Standard.
    }
    return _watchStandard();
  }

  /// Beschafft den lokal gespeicherten Filterstring des Pseudo-Projekts
  /// [filterId] und parst ihn. Rückgabe `null`, wenn kein Filterstring
  /// verfügbar ist oder er nicht lokal auswertbar ist
  /// ([UnsupportedFilterException]) -> Aufrufer nutzt den Online-Pfad.
  Future<FilterExpr?> _localFilterExpr(int filterId) async {
    final row = await ref.read(projectsDaoProvider).getById(filterId);
    if (row == null) return null;
    final filterString = _filterStringFromViews(row.viewsJson);
    if (filterString == null || filterString.trim().isEmpty) return null;
    try {
      return FilterParser.parse(filterString);
    } on UnsupportedFilterException {
      return null;
    }
  }

  /// Extrahiert den Filterstring aus dem gespeicherten Views-JSON: Der erste
  /// View mit nicht-leerem `filter.filter` gewinnt.
  String? _filterStringFromViews(String viewsJson) {
    final decoded = jsonDecode(viewsJson);
    if (decoded is! List) return null;
    for (final view in decoded) {
      if (view is Map && view['filter'] is Map) {
        final f = (view['filter'] as Map)['filter'];
        if (f is String && f.trim().isNotEmpty) return f;
      }
    }
    return null;
  }

  /// Gespeicherter Filter, lokal ausgewertet: offene Tasks aus der DB, gegen
  /// den Evaluator gefiltert, sortiert wie die Standardübersicht (dueDate, id).
  Future<TaskPageModel> _watchFiltered(FilterExpr expr) async {
    final onlyDue = await ref
        .read(settingsRepositoryProvider)
        .getLandingPageOnlyDueDateTasks();

    final dao = ref.read(tasksDaoProvider);
    final completer = Completer<TaskPageModel>();

    final sub = dao.watchOverviewTasks().listen((rows) async {
      final tasks = rows
          .map(taskFromRow)
          .where((t) => matches(t, expr))
          .toList();
      final model = await _createPageModel(
        tasks,
        onlyDue,
        isInitial: !completer.isCompleted,
      );
      if (!completer.isCompleted) {
        completer.complete(model);
      } else {
        state = AsyncData(model);
      }
    });
    ref.onDispose(sub.cancel);

    return completer.future;
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
  /// Online-Filterpfad ab). `userInitiated: true`, damit der globale Banner
  /// während des sichtbaren RefreshIndicators nicht zusätzlich
  /// "Synchronisiere …" zeigt. Der Pull wird awaited, damit der
  /// RefreshIndicator bis zum Sync-Ende sichtbar bleibt.
  Future<void> reload() async {
    await ref.read(syncServiceProvider).syncNow(userInitiated: true);
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

  /// Schreibpfade laufen über den [OfflineWriter]: lokal anwenden + online
  /// versuchen; bei Netzwerkfehler landet die Op in der Outbox (optimistisch).
  /// Rückgabe `true`, sofern der Server die Änderung nicht abgelehnt hat.
  Future<bool> addTask(int projectId, Task task) async {
    final result = await ref
        .read(offlineWriterProvider)
        .addTask(projectId, task);
    return result.ok;
  }

  Future<bool> deleteTask(int id) async {
    final result = await ref.read(offlineWriterProvider).deleteTask(id);
    return result.ok;
  }

  Future<bool> updateTask(Task task) async {
    final result = await ref.read(offlineWriterProvider).updateTask(task);
    return result.ok;
  }

  Future<bool> markAsDone(Task task) async {
    task.done = true;
    final result = await ref.read(offlineWriterProvider).updateTask(task);
    return result.ok;
  }
}
