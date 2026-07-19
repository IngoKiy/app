import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:home_widget/home_widget.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:vikunja_app/core/network/client.dart';
import 'package:vikunja_app/core/sync/dto_companion_mapper.dart';
import 'package:vikunja_app/data/data_sources/settings_data_source.dart';
import 'package:vikunja_app/data/data_sources/task_data_source.dart';
import 'package:vikunja_app/data/local/dao/tasks_dao.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/data/local/row_mappers.dart';
import 'package:vikunja_app/data/models/task_dto.dart';
import 'package:vikunja_app/data/repositories/task_repository_impl.dart';
import 'package:vikunja_app/domain/entities/task.dart';
import 'package:vikunja_app/domain/entities/widget_task.dart';
import 'package:vikunja_app/domain/repositories/task_repository.dart';

const _dtoMapper = DtoCompanionMapper();

Future<void> completeTask(String taskID) async {
  if (taskID == "null") {
    developer.log("Tried to complete an empty task");
  }

  var datasource = SettingsDatasource(FlutterSecureStorage());
  var base = await datasource.getServer();
  var refreshToken = await datasource.getRefreshToken();

  if (refreshToken != null && base != null) {
    Client client = Client(base: base);
    tz.initializeTimeZones();

    var ignoreCertificates = await datasource.getIgnoreCertificates();
    client.setIgnoreCerts(ignoreCertificates);

    TaskRepository taskService = TaskRepositoryImpl(TaskDataSource(client));
    var taskResponse = await taskService.getTask(int.parse(taskID));
    var task = taskResponse.toSuccess().body;
    var updateResponse = await taskService.update(task.copyWith(done: true));
    if (updateResponse.isSuccessful) {
      // Server hat den neuen Stand bestätigt -> lokale DB spiegeln, damit
      // updateWidget() (liest jetzt aus der DB) sofort konsistent ist.
      await _mirrorTaskToLocalDb(updateResponse.toSuccess().body);
    }
    await updateWidget();
  } else {
    developer.log("There was an error initialising the client");
  }
}

/// Spiegelt einen per Direkt-Request (nicht über die Outbox) aktualisierten
/// Task in die lokale DB. Kein Pending-Op nötig — der Server hat den Stand
/// bereits bestätigt. Öffnet bei Bedarf eine eigene kurzlebige DB-Verbindung
/// (Aufrufer laufen typischerweise im Headless-Isolate ohne DI-Container).
Future<void> _mirrorTaskToLocalDb(Task task) async {
  final db = AppDatabase();
  try {
    await db.tasksDao.upsertFromServer(
      _dtoMapper.task(
        TaskDto.fromDomain(task),
        DateTime.now(),
        projectId: task.projectId,
      ),
    );
  } finally {
    await db.close();
  }
}

WidgetTask convertTask(Task task) {
  // Check if task is for today
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  bool wgToday = task.dueDate!.day == today.day ? true : false;

  WidgetTask wgTask = WidgetTask(
    id: task.id.toString(),
    title: task.title,
    dueDate: task.dueDate,
    today: wgToday,
  );
  return wgTask;
}

List<Task> filterForDueTasks(List<Task> tasks) {
  var todayTasks = <Task>[];

  for (var task in tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (task.dueDate!.day == today.day) {
      todayTasks.add(task);
    }
  }
  return todayTasks;
}

/// Baut die Home-Widget-Daten aus der lokalen DB (Meilenstein M3/F2, siehe
/// docs/offline.md) — ein einmaliger Read statt der bisherigen Live-Anfrage
/// an den Server. [tasksDao] kann von Aufrufern injiziert werden, die
/// bereits eine (Riverpod-)Instanz halten (z.B. task_page_controller,
/// background_work.dart); ohne Angabe wird eine kurzlebige eigene
/// DB-Verbindung geöffnet und danach wieder geschlossen (z.B. Aufruf aus
/// notifications.dart/completeTask im Headless-Isolate).
Future<void> updateWidget({TasksDao? tasksDao}) async {
  AppDatabase? ownDb;
  try {
    final dao = tasksDao ?? (ownDb = AppDatabase()).tasksDao;
    final rows = await dao.getOpenTasks();
    final tasks = rows.map(taskFromRow).toList();
    await updateWidgetTasks(_dueOrOverdueTasks(tasks));
  } catch (e, s) {
    developer.log("Update widget error:", error: e, stackTrace: s);
  } finally {
    await ownDb?.close();
  }
}

/// Tasks mit Fälligkeit bis (exklusiv) morgen 00:00 Uhr lokaler Zeit —
/// entspricht dem bisherigen Server-Filter `due_date < now/d+1d`.
List<Task> _dueOrOverdueTasks(List<Task> tasks) {
  final now = DateTime.now();
  final tomorrow = DateTime(now.year, now.month, now.day + 1);
  return tasks
      .where((task) => task.hasDueDate && task.dueDate!.isBefore(tomorrow))
      .toList();
}

Future<void> updateWidgetTasks(List<Task> tasklist) async {
  var data = jsonEncode(tasklist.map((e) => convertTask(e).toJSON()).toList());
  await HomeWidget.saveWidgetData("WidgetTasks", data);
  await reRenderWidget();
}

Future<void> reRenderWidget() async {
  await HomeWidget.updateWidget(
    name: 'AppWidget',
    qualifiedAndroidName: 'io.vikunja.app.widget.AppWidgetReciever',
  );
}
