import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/domain/entities/task.dart';
import 'package:vikunja_app/presentation/manager/widget_controller.dart';

import 'controller_test_helpers.dart';

/// Ab Meilenstein M3/F2 (siehe docs/offline.md) speist [updateWidget] das
/// Home-Widget aus der lokalen DB statt vom Server. Diese Tests seeden eine
/// In-Memory-DB (Muster: controller_test_helpers.dart) und prüfen, dass nur
/// offene, fällige/überfällige Tasks im Widget landen.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const homeWidgetChannel = MethodChannel('home_widget');
  late AppDatabase db;
  final calls = <MethodCall>[];

  setUp(() {
    db = createTestDatabase();
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(homeWidgetChannel, (call) async {
          calls.add(call);
          return true;
        });
  });

  tearDown(() async {
    await db.close();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(homeWidgetChannel, null);
  });

  test(
    'updateWidget speist das Home-Widget nur mit offenen, fälligen/'
    'überfälligen Tasks aus der DB',
    () async {
      final now = DateTime.now();
      final overdue = now.subtract(const Duration(days: 2));
      final dueSoon = now; // vor "morgen 00:00" -> gehört ins Widget
      final farFuture = now.add(const Duration(days: 5));

      await seedProject(db, id: 1, title: 'Projekt A');
      await seedTask(db, id: 10, projectId: 1, title: 'Überfällig', dueDate: overdue);
      await seedTask(db, id: 11, projectId: 1, title: 'Heute fällig', dueDate: dueSoon);
      await seedTask(
        db,
        id: 12,
        projectId: 1,
        title: 'Weit in der Zukunft',
        dueDate: farFuture,
      );
      await seedTask(db, id: 13, projectId: 1, title: 'Ohne Fälligkeit');
      await seedTask(
        db,
        id: 14,
        projectId: 1,
        title: 'Erledigt, aber fällig',
        dueDate: overdue,
        done: true,
      );

      await updateWidget(tasksDao: db.tasksDao);

      final saveCall = calls.singleWhere((c) => c.method == 'saveWidgetData');
      final arguments = saveCall.arguments as Map<dynamic, dynamic>;
      expect(arguments['id'], 'WidgetTasks');

      final data = jsonDecode(arguments['data'] as String) as List<dynamic>;
      final ids = data.map((t) => (t as Map)['id']).toSet();

      expect(ids, {'10', '11'});
    },
  );

  test('filterForDueTasks behält nur Tasks mit heutigem Fälligkeitsdatum', () {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 8);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));

    final tasks = [
      Task(id: 1, title: 'Heute', dueDate: today, createdBy: null, projectId: 1),
      Task(id: 2, title: 'Gestern', dueDate: yesterday, createdBy: null, projectId: 1),
      Task(id: 3, title: 'Morgen', dueDate: tomorrow, createdBy: null, projectId: 1),
    ];

    final result = filterForDueTasks(tasks);

    expect(result.map((t) => t.id), [1]);
  });
}
