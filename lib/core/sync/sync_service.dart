import 'dart:convert';

import 'package:vikunja_app/core/network/response.dart';
import 'package:vikunja_app/core/sync/dto_companion_mapper.dart';
import 'package:vikunja_app/core/sync/sync_state_provider.dart';
import 'package:vikunja_app/data/data_sources/bucket_data_source.dart';
import 'package:vikunja_app/data/data_sources/label_data_source.dart';
import 'package:vikunja_app/data/data_sources/project_data_source.dart';
import 'package:vikunja_app/data/data_sources/server_data_source.dart';
import 'package:vikunja_app/data/data_sources/task_comment_data_source.dart';
import 'package:vikunja_app/data/data_sources/task_data_source.dart';
import 'package:vikunja_app/data/data_sources/user_data_source.dart';
import 'package:vikunja_app/data/local/dao/buckets_dao.dart';
import 'package:vikunja_app/data/local/dao/key_value_dao.dart';
import 'package:vikunja_app/data/local/dao/labels_dao.dart';
import 'package:vikunja_app/data/local/dao/projects_dao.dart';
import 'package:vikunja_app/data/local/dao/task_assignees_dao.dart';
import 'package:vikunja_app/data/local/dao/task_comments_dao.dart';
import 'package:vikunja_app/data/local/dao/task_labels_dao.dart';
import 'package:vikunja_app/data/local/dao/tasks_dao.dart';
import 'package:vikunja_app/data/local/dao/users_dao.dart';
import 'package:vikunja_app/data/models/project_dto.dart';
import 'package:vikunja_app/data/models/task_dto.dart';

/// Schlüssel im KeyValue-Store.
const String kvServerInfo = 'server_info';
const String kvCurrentUser = 'current_user';
const String kvLastFullSync = 'last_full_sync';

/// Zähler über einen Pull-Durchlauf (für Log + Tests).
class SyncStats {
  int projectsUpserted = 0;
  int projectsDeleted = 0;
  int tasksUpserted = 0;
  int tasksDeleted = 0;
  int bucketsUpserted = 0;
  int bucketsDeleted = 0;
  int labelsUpserted = 0;
  int labelsDeleted = 0;
  int usersUpserted = 0;

  @override
  String toString() =>
      'SyncStats(projects: +$projectsUpserted/-$projectsDeleted, '
      'tasks: +$tasksUpserted/-$tasksDeleted, '
      'buckets: +$bucketsUpserted/-$bucketsDeleted, '
      'labels: +$labelsUpserted/-$labelsDeleted, users: +$usersUpserted)';
}

/// Ergebnis eines [SyncService.pullAll]-Durchlaufs.
class SyncResult {
  /// Voller Abgleich erfolgreich abgeschlossen.
  final bool success;

  /// Abbruch, weil das Gerät/der Server nicht erreichbar war (kein Fehler).
  final bool offline;

  /// Fehlermeldung bei einem echten Serverfehler (4xx/5xx).
  final String? errorMessage;

  final Duration duration;
  final SyncStats stats;

  const SyncResult({
    required this.success,
    required this.offline,
    required this.duration,
    required this.stats,
    this.errorMessage,
  });
}

/// Interne Steuer-Exceptions, um den Pull sauber abzubrechen.
class _OfflineAbort implements Exception {}

class _ServerAbort implements Exception {
  final String message;
  _ServerAbort(this.message);
}

/// Pull-Vollabgleich (Vikunja hat keine Delta-API). Merge-Regeln stecken in
/// den DAOs (`upsertFromServer` respektiert lokale dirty-Datensätze,
/// `deleteMissingClean*` löscht nur clean+synchronisierte Datensätze). Siehe
/// docs/offline.md.
class SyncService {
  SyncService({
    required ServerDataSource serverDataSource,
    required UserDataSource userDataSource,
    required LabelDataSource labelDataSource,
    required ProjectDataSource projectDataSource,
    required TaskDataSource taskDataSource,
    required BucketDataSource bucketDataSource,
    required TaskCommentDataSource taskCommentDataSource,
    required ProjectsDao projectsDao,
    required TasksDao tasksDao,
    required BucketsDao bucketsDao,
    required LabelsDao labelsDao,
    required UsersDao usersDao,
    required TaskLabelsDao taskLabelsDao,
    required TaskAssigneesDao taskAssigneesDao,
    required TaskCommentsDao taskCommentsDao,
    required KeyValueDao keyValueDao,
    required SyncStateNotifier syncState,
    DtoCompanionMapper mapper = const DtoCompanionMapper(),
    Future<void> Function()? pushBeforePull,
    Future<void> Function()? onPullCompleted,
  }) : _serverDataSource = serverDataSource,
       _pushBeforePull = pushBeforePull,
       _onPullCompleted = onPullCompleted,
       _userDataSource = userDataSource,
       _labelDataSource = labelDataSource,
       _projectDataSource = projectDataSource,
       _taskDataSource = taskDataSource,
       _bucketDataSource = bucketDataSource,
       _taskCommentDataSource = taskCommentDataSource,
       _projectsDao = projectsDao,
       _tasksDao = tasksDao,
       _bucketsDao = bucketsDao,
       _labelsDao = labelsDao,
       _usersDao = usersDao,
       _taskLabelsDao = taskLabelsDao,
       _taskAssigneesDao = taskAssigneesDao,
       _taskCommentsDao = taskCommentsDao,
       _keyValueDao = keyValueDao,
       _syncState = syncState,
       _mapper = mapper;

  final ServerDataSource _serverDataSource;
  final UserDataSource _userDataSource;
  final LabelDataSource _labelDataSource;
  final ProjectDataSource _projectDataSource;
  final TaskDataSource _taskDataSource;
  final BucketDataSource _bucketDataSource;
  final TaskCommentDataSource _taskCommentDataSource;

  final ProjectsDao _projectsDao;
  final TasksDao _tasksDao;
  final BucketsDao _bucketsDao;
  final LabelsDao _labelsDao;
  final UsersDao _usersDao;
  final TaskLabelsDao _taskLabelsDao;
  final TaskAssigneesDao _taskAssigneesDao;
  final TaskCommentsDao _taskCommentsDao;
  final KeyValueDao _keyValueDao;

  final SyncStateNotifier _syncState;
  final DtoCompanionMapper _mapper;

  /// Optionaler Push-Schritt vor dem Pull (Outbox abarbeiten). Wird über den
  /// Provider mit [PushProcessor.pushAll] verkabelt; in Tests, die nur den Pull
  /// prüfen, bleibt er null.
  final Future<void> Function()? _pushBeforePull;

  /// Optionaler Nachlauf nach einem erfolgreichen Pull (pullAll/pullTaskDetails).
  /// Über den Provider mit dem [AttachmentPrefetcher] verkabelt (Anhänge
  /// on-device laden). Fehler bleiben ohne Folgen für das Sync-Ergebnis.
  final Future<void> Function()? _onPullCompleted;

  /// Laufender Pull; Single-Flight — ein zweiter Aufruf wartet auf denselben
  /// Future statt einen weiteren Durchlauf zu starten.
  Future<SyncResult>? _pullInFlight;

  /// Manueller Auslöser (Pull-to-Refresh / "jetzt synchronisieren"): erst
  /// Push (Outbox), dann voller Pull.
  ///
  /// [userInitiated] wird an [SyncStateNotifier.setSyncing] durchgereicht,
  /// damit der globale Banner während nutzerausgelöster Syncs still bleibt
  /// (der auslösende RefreshIndicator/Sheet-Button zeigt den Fortschritt).
  Future<SyncResult> syncNow({bool userInitiated = false}) async {
    if (_pushBeforePull != null) {
      await _pushBeforePull();
    }
    return pullAll(userInitiated: userInitiated);
  }

  Future<SyncResult> pullAll({bool userInitiated = false}) {
    return _pullInFlight ??= _pullAll(userInitiated: userInitiated).whenComplete(() {
      _pullInFlight = null;
    });
  }

  Future<SyncResult> _pullAll({bool userInitiated = false}) async {
    final stopwatch = Stopwatch()..start();
    final stats = SyncStats();
    final now = DateTime.now();
    _syncState.setSyncing(userInitiated: userInitiated);

    try {
      // 1. Server-Info + aktueller Nutzer.
      final info = _unwrap(await _serverDataSource.getInfo());
      await _keyValueDao.set(kvServerInfo, jsonEncode(info.toJSON()));

      final currentUser = _unwrap(await _userDataSource.getCurrentUser());
      await _keyValueDao.set(kvCurrentUser, jsonEncode(currentUser.toJSON()));
      await _usersDao.upsertFromServer(_mapper.user(currentUser, now));
      stats.usersUpserted++;

      // 2. Labels (global, nicht paginiert).
      final labels = _unwrap(await _labelDataSource.getAll());
      for (final label in labels) {
        await _labelsDao.upsertFromServer(_mapper.label(label, now));
        stats.labelsUpserted++;
      }
      stats.labelsDeleted += await _labelsDao.deleteMissingClean(
        labels.map((l) => l.id),
      );

      // 3. Projekte (page-weise) inkl. Views.
      final projects = await _fetchAllPages<ProjectDto>(
        (page) => _projectDataSource.getAll(page: page),
      );
      for (final project in projects) {
        await _projectsDao.upsertFromServer(_mapper.project(project, now));
        stats.projectsUpserted++;
      }
      stats.projectsDeleted += await _projectsDao.deleteMissingClean(
        projects.map((p) => p.id),
      );

      // 4. Pro Projekt: Tasks (Liste-View) + Buckets (Kanban-View).
      for (final project in projects) {
        await _syncProjectContent(project, now, stats);
      }

      // Erfolg.
      await _keyValueDao.set(kvLastFullSync, _iso(now));
      _syncState.setIdle(lastSyncAt: now);
      await _runPullCompleted();
      return SyncResult(
        success: true,
        offline: false,
        duration: stopwatch.elapsed,
        stats: stats,
      );
    } on _OfflineAbort {
      // Offline ist kein Fehler: nicht auf error setzen, bereits gemergte
      // Teile bleiben, last_full_sync wird NICHT aktualisiert. Der
      // Offline-Zustand wird über die Connectivity-Schicht angezeigt.
      _syncState.setIdle();
      return SyncResult(
        success: false,
        offline: true,
        duration: stopwatch.elapsed,
        stats: stats,
      );
    } on _ServerAbort catch (e) {
      _syncState.setError(e.message);
      return SyncResult(
        success: false,
        offline: false,
        duration: stopwatch.elapsed,
        stats: stats,
        errorMessage: e.message,
      );
    } catch (e) {
      _syncState.setError(e.toString());
      return SyncResult(
        success: false,
        offline: false,
        duration: stopwatch.elapsed,
        stats: stats,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _syncProjectContent(
    ProjectDto project,
    DateTime now,
    SyncStats stats,
  ) async {
    // Tasks: bevorzugt über die Liste-View (wie project_controller), sonst
    // Fallback auf den projektweiten Endpunkt. So ist der Lösch-Scope immer
    // vollständig befüllt.
    final listView = _firstViewOfKind(project, 'list');
    final tasks = listView != null
        ? await _fetchAllPages<TaskDto>(
            (page) => _taskDataSource.getAllByProjectView(
              project.id,
              listView.id,
              _pageParam(page),
            ),
          )
        : await _fetchAllPages<TaskDto>(
            (page) =>
                _taskDataSource.getAllByProject(project.id, _pageParam(page)),
          );

    for (final task in tasks) {
      await _upsertTaskWithJunctions(task, project.id, now, stats);
    }
    stats.tasksDeleted += await _tasksDao.deleteMissingCleanForProject(
      project.id,
      tasks.map((t) => t.id),
    );

    // Buckets: nur bei vorhandener Kanban-View (einmaliger Abruf; die
    // Pagination des Endpunkts blättert Tasks, nicht Buckets).
    final kanbanView = _firstViewOfKind(project, 'kanban');
    if (kanbanView != null) {
      final buckets = _unwrap(
        await _bucketDataSource.getAllByList(project.id, kanbanView.id),
      );
      for (final bucket in buckets) {
        await _bucketsDao.upsertFromServer(
          _mapper.bucket(
            bucket,
            now,
            projectId: project.id,
            viewId: kanbanView.id,
            isDoneBucket: bucket.id == kanbanView.doneBucketId,
          ),
        );
        stats.bucketsUpserted++;
      }
      stats.bucketsDeleted += await _bucketsDao.deleteMissingCleanForProject(
        project.id,
        buckets.map((b) => b.id),
      );
    }
  }

  /// Task upserten und die n:m-Relationen (Labels/Assignees) auf den
  /// Server-Stand bringen. Lokale dirty-Tasks bleiben unangetastet.
  Future<void> _upsertTaskWithJunctions(
    TaskDto dto,
    int projectId,
    DateTime now,
    SyncStats stats,
  ) async {
    final existing = await _tasksDao.getById(dto.id);
    if (existing != null && existing.isDirty) return;

    await _tasksDao.upsertFromServer(
      _mapper.task(dto, now, projectId: projectId),
    );
    stats.tasksUpserted++;

    final labelIds = _mapper.taskLabelIds(dto);
    for (final labelId in labelIds) {
      await _taskLabelsDao.upsertFromServer(dto.id, labelId);
    }
    await _taskLabelsDao.deleteMissingCleanForTask(dto.id, labelIds);

    final assigneeIds = _mapper.taskAssigneeIds(dto);
    for (final userId in assigneeIds) {
      await _taskAssigneesDao.upsertFromServer(dto.id, userId);
    }
    await _taskAssigneesDao.deleteMissingCleanForTask(dto.id, assigneeIds);
  }

  /// Lazy-Load beim Öffnen eines Tasks: Detail (getTask) + Kommentare.
  /// Netzfehler werden still verworfen (die lokale Kopie bleibt gültig).
  Future<void> pullTaskDetails(int remoteTaskId) async {
    final now = DateTime.now();
    final taskResp = await _taskDataSource.getTask(remoteTaskId);
    if (!taskResp.isSuccessful) return;
    final dto = taskResp.toSuccess().body;
    await _upsertTaskWithJunctions(
      dto,
      dto.projectId ?? 0,
      now,
      SyncStats(),
    );

    final commentsResp = await _taskCommentDataSource.getAll(remoteTaskId);
    if (!commentsResp.isSuccessful) return;
    final comments = commentsResp.toSuccess().body;
    for (final comment in comments) {
      await _taskCommentsDao.upsertFromServer(
        _mapper.taskComment(comment, now, taskId: remoteTaskId),
      );
    }
    await _taskCommentsDao.deleteMissingCleanForTask(
      remoteTaskId,
      comments.map((c) => c.id),
    );

    await _runPullCompleted();
  }

  /// Ruft den optionalen Pull-Nachlauf ([_onPullCompleted]) auf. Fehler werden
  /// geschluckt — der Prefetcher darf ein erfolgreiches Sync nicht kippen.
  Future<void> _runPullCompleted() async {
    try {
      await _onPullCompleted?.call();
    } catch (_) {}
  }

  /// Nutzer eines Projekts in die users-Tabelle spiegeln (Assignee-Picker
  /// offline). Kein Löschen — die users-Tabelle ist projektübergreifend.
  Future<void> pullProjectUsers(int remoteProjectId) async {
    final now = DateTime.now();
    final resp = await _taskDataSource.getAssignableUsers(remoteProjectId);
    if (!resp.isSuccessful) return;
    for (final user in resp.toSuccess().body) {
      await _usersDao.upsertFromServer(_mapper.user(user, now));
    }
  }

  // --- Helfer ---------------------------------------------------------------

  String _iso(DateTime dt) => dt.toUtc().toIso8601String();

  Map<String, List<String>> _pageParam(int page) => {
    'page': ['$page'],
  };

  _ViewRef? _firstViewOfKind(ProjectDto project, String viewKind) {
    for (final view in project.views) {
      if (view.viewKind == viewKind) {
        return _ViewRef(view.id, view.doneBucketId);
      }
    }
    return null;
  }

  /// Blättert einen paginierten Endpunkt bis eine Seite leer ist bzw. kleiner
  /// als die erste (volle) Seite. Wirft [_OfflineAbort]/[_ServerAbort] bei
  /// Netz-/Serverfehlern.
  Future<List<T>> _fetchAllPages<T>(
    Future<Response<List<T>>> Function(int page) fetch,
  ) async {
    const maxPages = 10000; // Sicherheitsnetz gegen fehlerhafte Server.
    final all = <T>[];
    var page = 1;
    int? pageSize;
    while (page <= maxPages) {
      final batch = _unwrap(await fetch(page));
      if (batch.isEmpty) break;
      all.addAll(batch);
      pageSize ??= batch.length;
      if (batch.length < pageSize) break;
      page++;
    }
    return all;
  }

  /// Packt eine [Response] aus oder bricht typgerecht ab.
  T _unwrap<T>(Response<T> response) {
    switch (response) {
      case SuccessResponse<T>():
        return response.body;
      case ExceptionResponse<T>():
        throw _OfflineAbort();
      case ErrorResponse<T>():
        throw _ServerAbort(
          'HTTP ${response.statusCode}: ${response.error}',
        );
    }
  }
}

/// Leichtgewichtige Referenz auf eine View (id + done-Bucket) ohne die
/// Domain-Entität zu laden.
class _ViewRef {
  final int id;
  final int doneBucketId;
  const _ViewRef(this.id, this.doneBucketId);
}
