import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vikunja_app/core/di/database_provider.dart';
import 'package:vikunja_app/core/di/offline_provider.dart';
import 'package:vikunja_app/core/di/repository_provider.dart';
import 'package:vikunja_app/core/di/sync_provider.dart';
import 'package:vikunja_app/core/sync/dto_companion_mapper.dart';
import 'package:vikunja_app/data/local/row_mappers.dart';
import 'package:vikunja_app/data/models/project_dto.dart';
import 'package:vikunja_app/data/models/project_view_dto.dart';
import 'package:vikunja_app/domain/entities/bucket.dart';
import 'package:vikunja_app/domain/entities/project.dart';
import 'package:vikunja_app/domain/entities/project_page_model.dart';
import 'package:vikunja_app/domain/entities/task.dart';
import 'package:vikunja_app/domain/entities/view_kind.dart';
import 'package:vikunja_app/presentation/manager/projects_controller.dart';

part 'project_controller.g.dart';

/// Liest Liste bzw. Kanban-Buckets reaktiv aus der lokalen DB (watch-Streams).
/// Schreib-Methoden gehen weiterhin über die Repositories (Online-API) und
/// upserten die Server-Antwort in die DB; die UI aktualisiert sich per Stream.
@riverpod
class ProjectController extends _$ProjectController {
  static const _mapper = DtoCompanionMapper();

  StreamSubscription<void>? _sub;
  late Project _project;
  int _viewIndex = 0;
  bool _displayDoneTask = false;

  @override
  Future<ProjectPageModel> build(Project project) {
    _project = project;
    ref.onDispose(() => _sub?.cancel());
    return _watchView(project, 0);
  }

  /// Abonniert den passenden DB-Stream (Tasks für List-, Buckets für Kanban-
  /// View) und liefert das erste Modell zurück. Folge-Emissionen patchen den
  /// State direkt.
  Future<ProjectPageModel> _watchView(Project project, int viewIndex) async {
    _project = project;
    _viewIndex = viewIndex;
    _displayDoneTask = await ref
        .read(settingsRepositoryProvider)
        .getDisplayDoneTasks(project.id);

    await _sub?.cancel();

    final view = (viewIndex >= 0 && viewIndex < project.views.length)
        ? project.views[viewIndex]
        : null;
    final completer = Completer<ProjectPageModel>();

    void emit(ProjectPageModel model) {
      if (!completer.isCompleted) {
        completer.complete(model);
      } else {
        state = AsyncData(model);
      }
    }

    if (view != null && view.viewKind == ViewKind.kanban) {
      final dao = ref.read(bucketsDaoProvider);
      _sub = dao.watchBucketsByProject(project.id).listen((rows) {
        final buckets = rows
            .where((b) => b.viewId == null || b.viewId == view.id)
            .map(bucketFromRow)
            .toList();
        emit(
          ProjectPageModel(
            project,
            viewIndex,
            const [],
            buckets,
            _displayDoneTask,
            false,
          ),
        );
      });
    } else {
      final dao = ref.read(tasksDaoProvider);
      _sub = dao.watchTasksByProject(project.id).listen((rows) {
        var tasks = rows.map(taskFromRow).toList();
        if (!_displayDoneTask) {
          tasks = tasks.where((t) => !t.done).toList();
        }
        tasks.sort(
          (a, b) => (a.position ?? 0).compareTo(b.position ?? 0),
        );
        emit(
          ProjectPageModel(
            project,
            viewIndex,
            tasks,
            const [],
            _displayDoneTask,
            false,
          ),
        );
      });
    }

    return completer.future;
  }

  Future<void> loadForView(Project project, int viewIndex) async {
    // Kein AsyncLoading: bestehende Daten bleiben sichtbar bis der Stream die
    // neue Ansicht liefert (verhindert Flackern beim View-Wechsel/Reload).
    try {
      state = AsyncData(await _watchView(project, viewIndex));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Pagination entfällt bei DB-Reads (alles lokal) — No-Op für API-Kompat.
  Future<void> loadNextPage() async {}

  /// Setzt die Ansicht auf den DB-Stand zurück (verwirft optimistische
  /// UI-Änderungen) und stößt im Hintergrund einen Voll-Pull an.
  void reload() {
    unawaited(ref.read(syncServiceProvider).syncNow());
    loadForView(_project, _viewIndex);
  }

  Future<bool> addTask(Project project, Task newTask) async {
    final result = await ref
        .read(offlineWriterProvider)
        .addTask(project.id, newTask);
    return result.ok;
  }

  Future<bool> addBucket({
    required Bucket newBucket,
    required Project project,
    required int viewId,
  }) async {
    final result = await ref
        .read(offlineWriterProvider)
        .addBucket(project.id, viewId, newBucket);
    return result.ok;
  }

  Future<bool> deleteBucket({
    required Bucket bucket,
    required Project project,
  }) async {
    final viewId = project.views[state.value!.viewIndex].id;
    final result = await ref
        .read(offlineWriterProvider)
        .deleteBucket(project.id, viewId, bucket.id);
    return result.ok;
  }

  Future<bool> updateBucket({
    required Bucket bucket,
    required Project project,
  }) async {
    final viewId = project.views[state.value!.viewIndex].id;
    final result = await ref
        .read(offlineWriterProvider)
        .updateBucket(project.id, viewId, bucket);
    return result.ok;
  }

  Future<bool> reorderTasks({
    required Project project,
    required List<Task> newOrderedTasks,
    required int movedTaskId,
    required double newPosition,
  }) async {
    final value = state.value;
    if (value == null) return false;

    // Optimistisch anzeigen; der Writer patcht die DB (liefert den Endstand).
    state = AsyncData(value.copyWith(tasks: newOrderedTasks));

    int? viewId = _getFirstListViewIdFromProject(value.project);
    if (viewId == null) {
      return true;
    }

    final result = await ref
        .read(offlineWriterProvider)
        .reorderTask(taskId: movedTaskId, viewId: viewId, position: newPosition);
    if (!result.ok) {
      reload();
      return false;
    }
    return true;
  }

  Future<bool> moveTask(
    Project project,
    Task task,
    Bucket bucket,
    double position,
  ) async {
    final viewId = project.views[state.value!.viewIndex].id;
    final result = await ref
        .read(offlineWriterProvider)
        .moveTask(
          task: task,
          bucketId: bucket.id,
          projectId: project.id,
          viewId: viewId,
          position: position,
        );
    return result.ok;
  }

  Future<bool> updateDoneBucket(
    Project project,
    int bucketId,
    isDoneColumn,
  ) async {
    final projectView = project.views[state.value!.viewIndex];
    projectView.doneBucketId = isDoneColumn ? 0 : bucketId;

    final result = await ref
        .read(offlineWriterProvider)
        .updateProjectView(
          ProjectViewDto.fromDomain(projectView),
          persistLocal: () => _persistProjectViews(project),
        );
    if (result.ok) {
      final value = state.value;
      if (value != null) {
        state = AsyncData(value.copyWith(project: project));
        return true;
      }
    }
    return false;
  }

  Future<bool> selectDefaultBucket(
    Project project,
    int bucketId,
    isDefaultColumn,
  ) async {
    final projectView = project.views[state.value!.viewIndex];
    projectView.defaultBucketId = isDefaultColumn ? 0 : bucketId;

    final result = await ref
        .read(offlineWriterProvider)
        .updateProjectView(
          ProjectViewDto.fromDomain(projectView),
          persistLocal: () => _persistProjectViews(project),
        );
    if (result.ok) {
      final value = state.value;
      if (value != null) {
        state = AsyncData(value.copyWith(project: project));
        return true;
      }
    }
    return false;
  }

  Future<bool> setDisplayDoneTasks(bool displayDoneTasks) async {
    final value = state.value;
    if (value == null) return false;

    await ref
        .read(settingsRepositoryProvider)
        .setDisplayDoneTasks(value.project.id, displayDoneTasks);

    // Neu abonnieren, damit der Filter im Stream greift.
    await loadForView(value.project, value.viewIndex);
    return true;
  }

  Future<bool> updateProject(Project project) async {
    final result = await ref.read(offlineWriterProvider).updateProject(project);
    if (result.ok) {
      ref.read(projectsControllerProvider.notifier).reload();
      final value = state.value;
      if (value != null) {
        state = AsyncData(value.copyWith(project: project));
      }
      return true;
    }
    return false;
  }

  Future<bool> markAsDone(Task task) async {
    task.done = true;
    final result = await ref.read(offlineWriterProvider).updateTask(task);
    return result.ok;
  }

  // --- Helfer ---------------------------------------------------------------

  int? _getFirstListViewIdFromProject(Project project) {
    return project.views.isNotEmpty &&
            project.views.first.viewKind == ViewKind.list
        ? project.views.first.id
        : null;
  }

  /// Persistiert geänderte View-Metadaten (done-/default-Bucket) im Projekt.
  Future<void> _persistProjectViews(Project project) {
    return ref
        .read(projectsDaoProvider)
        .upsertFromServer(
          _mapper.project(ProjectDto.fromDomain(project), DateTime.now()),
        );
  }
}
