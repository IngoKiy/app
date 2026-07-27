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
import 'package:vikunja_app/presentation/widgets/list_accent_scaffold.dart';
import 'package:vikunja_app/presentation/widgets/project/kanban/kanban_widget.dart';
import 'package:vikunja_app/presentation/widgets/project_members_section.dart';
import 'package:vikunja_app/presentation/widgets/project/project_task_list.dart';
import 'package:vikunja_app/presentation/widgets/task/add_task_bar.dart';
import 'package:vikunja_app/presentation/widgets/task/add_task_sheet.dart';
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
        // Akzent-Theming nur in der Listen-Ansicht (wie in Microsoft To Do);
        // Kanban bleibt bewusst unverändert im Standard-Theme.
        final currentView =
            (data.project.views.isNotEmpty &&
                _viewIndex < data.project.views.length)
            ? data.project.views[_viewIndex]
            : null;
        final isListView = currentView?.viewKind == ViewKind.list;
        final accentColor = isListView
            ? (data.project.color ?? Theme.of(context).colorScheme.primary)
            : null;
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
              // reload() stößt Push+Pull an (userInitiated: true) und baut
              // die aktuelle View danach neu auf; vorher rief dies nur
              // loadForView auf und triggerte gar keinen Sync.
              return ref
                  .read(projectControllerProvider(widget.project).notifier)
                  .reload();
            },
            child: getBody(data.project),
          ),
        );

        // Wie Microsoft To Do: unten die „Aufgabe hinzufügen"-Leiste statt
        // FAB; der Ansichts-Wechsel (Kanban etc.) liegt im AppBar-Menü statt
        // in einer Bottom-Navigation.
        final showAddBar = isListView && data.project.id > 0;
        return Scaffold(
          backgroundColor: accentColor,
          appBar: _buildAppBar(
            context,
            data.project,
            data.displayDoneTask,
            accentColor,
          ),
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
          floatingActionButton: (!isListView) ? _buildFab(data.project) : null,
          bottomNavigationBar: showAddBar
              ? AddTaskBar(
                  accentColor: accentColor,
                  onTap: () => _addITaskDialog(context, data.project),
                )
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

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    Project project,
    bool displayDoneTask,
    Color? accentColor,
  ) {
    final actions = <Widget>[
      // Ansichts-Wechsel (List/Kanban/…) kompakt im Menü statt als
      // Bottom-Navigation — To Do kennt keine Ansichtsleiste unten.
      if (project.views.length >= 2)
        PopupMenuButton<int>(
          tooltip: AppLocalizations.of(context).noViews,
          icon: const Icon(Icons.grid_view_outlined),
          onSelected: _onViewTapped,
          itemBuilder: (context) => [
            for (var i = 0; i < project.views.length; i++)
              PopupMenuItem<int>(
                value: i,
                child: Row(
                  children: [
                    if (i == _viewIndex)
                      const Icon(Icons.check, size: 18)
                    else
                      const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    Text(project.views[i].title),
                  ],
                ),
              ),
          ],
        ),
      IconButton(
        icon: const Icon(Icons.people_alt_outlined),
        tooltip: AppLocalizations.of(context).projectMembers,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectMembersPage(projectId: project.id),
          ),
        ),
      ),
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
    ];

    // Listen-Ansicht: Akzentfarbe + Zurück-Button „Listen" (wie To Do); die
    // Kanban-Ansicht behält die normale AppBar.
    if (accentColor != null) {
      return AccentAppBar(accentColor: accentColor, actions: actions);
    }

    return AppBar(title: Text(project.title), actions: actions);
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
    return showAddTaskSheet(
      context,
      onAddTask: (title, dueDate, _) =>
          _addItem(context, project, title, dueDate),
      defaultProjectId: project.id,
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
