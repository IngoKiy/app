import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vikunja_app/core/di/network_provider.dart';
import 'package:vikunja_app/core/di/notification_provider.dart';
import 'package:vikunja_app/domain/entities/project.dart';
import 'package:vikunja_app/domain/entities/task.dart';
import 'package:vikunja_app/domain/entities/view_kind.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/manager/notifications.dart';
import 'package:vikunja_app/presentation/manager/project_controller.dart';
import 'package:vikunja_app/presentation/pages/error_widget.dart';
import 'package:vikunja_app/presentation/pages/loading_widget.dart';
import 'package:vikunja_app/presentation/pages/project/project_edit.dart';
import 'package:vikunja_app/presentation/widgets/project/kanban/kanban_widget.dart';
import 'package:vikunja_app/presentation/widgets/project/project_task_list.dart';
import 'package:vikunja_app/presentation/widgets/task/add_task_dialog.dart';
import 'package:vikunja_app/presentation/widgets/ui/adaptive.dart';

class ProjectDetailPage extends ConsumerStatefulWidget {
  final Project project;

  const ProjectDetailPage({super.key, required this.project});

  @override
  ProjectPageState createState() => ProjectPageState();
}

class ProjectPageState extends ConsumerState<ProjectDetailPage> {
  int _viewIndex = 0;
  NotificationHandler? _notificationHandler;

  @override
  void initState() {
    _notificationHandler = ref.read(notificationProvider);
    _notificationHandler?.addListener(onNotificationDone);
    super.initState();
  }

  @override
  void dispose() {
    _notificationHandler?.removeListener(onNotificationDone);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var projectController = ref.watch(
      projectControllerProvider(widget.project),
    );

    return projectController.when(
      data: (data) {
        final isCompact = context.isCompact;
        final scrollBody = NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels ==
                scrollInfo.metrics.maxScrollExtent) {
              ref
                  .read(projectControllerProvider(widget.project).notifier)
                  .loadNextPage();
            }
            return false;
          },
          child: RefreshIndicator(
            onRefresh: () {
              return ref
                  .read(projectControllerProvider(widget.project).notifier)
                  .loadForView(data.project, _viewIndex);
            },
            child: getBody(data.project),
          ),
        );

        return Scaffold(
          appBar: _buildAppBar(context, data.project, data.displayDoneTask),
          body: isCompact
              ? scrollBody
              : Column(
                  children: [
                    if (data.project.views.length >= 2)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: _buildViewSwitcher(data.project),
                      ),
                    Expanded(child: scrollBody),
                  ],
                ),
          floatingActionButton: _buildFab(data.project),
          bottomNavigationBar: isCompact
              ? _buildBottomNavigation(data.project)
              : null,
        );
      },
      error: (err, _) => VikunjaErrorWidget(
        error: err,
        onRetry: () => ref
            .read(projectControllerProvider(widget.project).notifier)
            .loadForView(widget.project, _viewIndex),
      ),
      loading: () => const LoadingWidget(),
    );
  }

  Widget getBody(Project project) {
    if (project.views.isEmpty) {
      return Text(AppLocalizations.of(context).noViews);
    }

    switch (project.views[_viewIndex].viewKind) {
      case ViewKind.list:
        return ProjectTaskList(project);
      case ViewKind.kanban:
        return KanbanWidget(project: project);
      default:
        return Text(AppLocalizations.of(context).notImplemented);
    }
  }

  AppBar _buildAppBar(
    BuildContext context,
    Project project,
    bool displayDoneTask,
  ) {
    return AppBar(
      title: Text(project.title),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProjectEditPage(
                project: project,
                displayDoneTask: displayDoneTask,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Builder? _buildFab(Project project) {
    if (project.views.isEmpty ||
        project.views[_viewIndex].viewKind == ViewKind.kanban ||
        project.id < 0) {
      return null;
    }

    return Builder(
      builder: (context) => FloatingActionButton(
        onPressed: () => _addITaskDialog(context, project),
        child: Icon(Icons.add),
      ),
    );
  }

  NavigationBar? _buildBottomNavigation(Project project) {
    if (project.views.length >= 2) {
      return NavigationBar(
        destinations: project.views
            .map(
              (view) => NavigationDestination(
                icon: view.icon,
                label: view.title,
                tooltip: view.title,
              ),
            )
            .toList(),
        selectedIndex: _viewIndex,
        onDestinationSelected: _onViewTapped,
      );
    }

    return null;
  }

  Widget _buildViewSwitcher(Project project) {
    return SegmentedButton<int>(
      segments: [
        for (var i = 0; i < project.views.length; i++)
          ButtonSegment(
            value: i,
            icon: project.views[i].icon,
            label: Text(project.views[i].title),
          ),
      ],
      selected: {_viewIndex},
      onSelectionChanged: (selection) => _onViewTapped(selection.first),
    );
  }

  Future<void> _addITaskDialog(BuildContext context, Project project) {
    return showDialog(
      context: context,
      builder: (_) => AddTaskDialog(
        onAddTask: (title, dueDate) =>
            _addItem(context, project, title, dueDate),
      ),
    );
  }

  Future<void> _addItem(
    BuildContext context,
    Project project,
    String title,
    DateTime? dueDate,
  ) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      return;
    }

    final task = Task(
      title: title,
      dueDate: dueDate,
      createdBy: currentUser,
      done: false,
      projectId: project.id,
    );

    var success = await ref
        .read(projectControllerProvider(widget.project).notifier)
        .addTask(project, task);

    if (context.mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).taskAddedSuccess)),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).taskAddError)),
      );
    }
  }

  void _onViewTapped(int index) {
    setState(() {
      _viewIndex = index;

      ref
          .read(projectControllerProvider(widget.project).notifier)
          .loadForView(widget.project, _viewIndex);
    });
  }

  void onNotificationDone() {
    ref.read(projectControllerProvider(widget.project).notifier).reload();
  }
}
