import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/domain/entities/project.dart';
import 'package:vikunja_app/domain/entities/task.dart';
import 'package:vikunja_app/domain/entities/task_page_model.dart';
import 'package:vikunja_app/domain/entities/user.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/manager/task_page_controller.dart';
import 'package:vikunja_app/presentation/pages/task/task_list_page.dart';

class _MockTaskPageController extends TaskPageController {
  final TaskPageModel model;
  _MockTaskPageController(this.model);

  @override
  Future<TaskPageModel> build() async => model;
}

Widget _buildPage() {
  final user = User(username: 'demo');
  final project = Project(id: 1, title: 'Home');
  final tasks = [
    Task(
      id: 1,
      title: 'Water the plants',
      createdBy: user,
      projectId: 1,
      dueDate: DateTime(2026, 7, 24),
    ),
    Task(id: 2, title: 'Take out the trash', createdBy: user, projectId: 1),
    Task(id: 3, title: 'Buy groceries', createdBy: user, projectId: 1),
  ];
  for (final task in tasks) {
    task.project = project;
  }
  final model = TaskPageModel(tasks, false, 1, false);

  return ProviderScope(
    overrides: [
      taskPageControllerProvider.overrideWith(
        () => _MockTaskPageController(model),
      ),
    ],
    child: Localizations(
      delegates: AppLocalizations.localizationsDelegates,
      locale: const Locale('en'),
      child: const TaskListPage(),
    ),
  );
}

void main() {
  goldenTest(
    'Task list screen (compact)',
    fileName: 'task_list_compact',
    pumpBeforeTest: precacheImages,
    constraints: BoxConstraints.tight(const Size(400, 700)),
    builder: _buildPage,
  );

  goldenTest(
    'Task list screen (expanded)',
    fileName: 'task_list_expanded',
    pumpBeforeTest: precacheImages,
    constraints: BoxConstraints.tight(const Size(1200, 700)),
    builder: _buildPage,
  );
}
