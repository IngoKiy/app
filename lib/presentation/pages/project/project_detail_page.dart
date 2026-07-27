import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vikunja_app/core/di/network_provider.dart';
import 'package:vikunja_app/core/di/database_provider.dart';
import 'package:vikunja_app/core/di/offline_provider.dart';
import 'package:vikunja_app/presentation/manager/projects_controller.dart';
import 'package:vikunja_app/core/theming/color_utils.dart';
import 'package:vikunja_app/core/theming/todo_colors.dart';
import 'package:vikunja_app/domain/entities/task_sort.dart';
import 'package:vikunja_app/presentation/manager/smart_list_providers.dart';
import 'package:vikunja_app/presentation/widgets/ui/preset_sheet.dart';

import 'package:vikunja_app/core/di/notification_provider.dart';
import 'package:vikunja_app/domain/entities/project.dart';
import 'package:vikunja_app/domain/entities/task.dart';
import 'package:vikunja_app/domain/entities/task_reminder.dart';
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
    // Wie Microsoft To Do: ein einzelnes „…" öffnet das Listenoptionen-Sheet
    // (Umbenennen, Sortieren, Design ändern, Mitglieder, Ansicht, Bearbeiten).
    final actions = <Widget>[
      IconButton(
        icon: const Icon(Icons.more_horiz),
        tooltip: AppLocalizations.of(context).listOptionsTitle,
        onPressed: () => _showListOptions(project, displayDoneTask),
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

  // --- Listenoptionen-Sheet (To-Do-Stil) -----------------------------------

  Future<void> _showListOptions(Project project, bool displayDoneTask) async {
    final l10n = AppLocalizations.of(context);
    final choice = await showPresetSheet<String>(
      context,
      title: l10n.listOptionsTitle,
      options: [
        PresetOption(
          icon: Icons.drive_file_rename_outline,
          label: l10n.renameList,
          value: 'rename',
        ),
        PresetOption(
          icon: Icons.swap_vert,
          label: l10n.sortByLabel,
          chevron: true,
          value: 'sort',
        ),
        PresetOption(
          icon: Icons.palette_outlined,
          label: l10n.changeDesign,
          chevron: true,
          value: 'design',
        ),
        PresetOption(
          icon: Icons.people_alt_outlined,
          label: l10n.projectMembers,
          value: 'members',
        ),
        if (project.views.length >= 2)
          PresetOption(
            icon: Icons.grid_view_outlined,
            label: l10n.changeView,
            chevron: true,
            value: 'view',
          ),
        PresetOption(
          icon: Icons.edit_outlined,
          label: l10n.edit,
          value: 'edit',
        ),
        if (project.id > 0)
          PresetOption(
            icon: Icons.delete_outline,
            label: l10n.deleteList,
            destructive: true,
            value: 'delete',
          ),
      ],
    );
    if (choice == null || !mounted) return;

    switch (choice) {
      case 'rename':
        await _renameList(project);
      case 'sort':
        await _showSortSheet(project);
      case 'design':
        await _showDesignSheet(project);
      case 'members':
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectMembersPage(projectId: project.id),
          ),
        );
      case 'view':
        await _showViewSheet(project);
      case 'edit':
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectEditPage(
              project: project,
              displayDoneTask: displayDoneTask,
            ),
          ),
        );
      case 'delete':
        await _confirmAndDeleteList(project);
    }
  }

  /// Löschen mit Bestätigung wie in To Do: „»…« wird endgültig gelöscht."
  /// [Abbrechen | Liste löschen (rot)]; danach zurück zur Übersicht.
  Future<void> _confirmAndDeleteList(Project project) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(l10n.deleteListMessage(project.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.deleteList,
              style: TextStyle(
                color: Theme.of(dialogContext).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final result = await ref
        .read(offlineWriterProvider)
        .deleteProject(project.id);
    if (!mounted) return;
    if (result.ok) {
      ref.invalidate(projectsControllerProvider);
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.listDeleteError)));
    }
  }

  Future<void> _renameList(Project project) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: project.title);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.renameList),
        content: TextField(
          controller: controller,
          autofocus: true,
          onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    final title = newTitle?.trim();
    if (title == null || title.isEmpty || title == project.title) return;
    await ref
        .read(projectControllerProvider(widget.project).notifier)
        .updateProject(project.copyWith(title: title));
  }

  Future<void> _showSortSheet(Project project) async {
    final l10n = AppLocalizations.of(context);
    final choice = await showPresetSheet<String>(
      context,
      title: l10n.sortByLabel,
      options: [
        PresetOption(
          icon: Icons.star_border,
          label: l10n.sortImportance,
          value: TaskSortMode.importance.name,
        ),
        PresetOption(
          icon: Icons.sort_by_alpha,
          label: l10n.sortAlphabetical,
          value: TaskSortMode.alphabetical.name,
        ),
        PresetOption(
          icon: Icons.calendar_today_outlined,
          label: l10n.sortDueDate,
          value: TaskSortMode.dueDate.name,
        ),
        PresetOption(
          icon: Icons.more_time,
          label: l10n.sortCreated,
          value: TaskSortMode.created.name,
        ),
        PresetOption(
          icon: Icons.drag_handle,
          label: l10n.sortManual,
          value: 'manual',
        ),
      ],
    );
    if (choice == null || !mounted) return;
    final kv = ref.read(keyValueDaoProvider);
    final key = 'project/${project.id}';
    if (choice == 'manual') {
      await clearListSortMode(kv, key);
    } else {
      await setListSortMode(kv, key, TaskSortMode.values.byName(choice));
    }
  }

  Future<void> _showDesignSheet(Project project) async {
    final l10n = AppLocalizations.of(context);
    final selected = await showModalBottomSheet<Color>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.changeDesign,
              style: Theme.of(
                sheetContext,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final color in TodoColors.listPalette)
                    InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.of(sheetContext).pop(color),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(
                              sheetContext,
                            ).colorScheme.outlineVariant,
                          ),
                        ),
                        child: project.color == color
                            ? Icon(
                                Icons.check,
                                color: contrastingTextColor(color),
                              )
                            : null,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
    if (selected == null || !mounted) return;
    final updated = project.copyWith()..color = selected;
    await ref
        .read(projectControllerProvider(widget.project).notifier)
        .updateProject(updated);
  }

  Future<void> _showViewSheet(Project project) async {
    final l10n = AppLocalizations.of(context);
    final choice = await showPresetSheet<int>(
      context,
      title: l10n.changeView,
      options: [
        for (var i = 0; i < project.views.length; i++)
          PresetOption(
            icon: i == _viewIndex
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            label: project.views[i].title,
            value: i,
          ),
      ],
    );
    if (choice != null) _onViewTapped(choice);
  }

  Future<void> _addITaskDialog(BuildContext context, Project project) {
    return showAddTaskSheet(
      context,
      onAddTask: (title, dueDate, _, {reminder, description}) => _addItem(
        context,
        project,
        title,
        dueDate,
        reminder: reminder,
        description: description,
      ),
      defaultProjectId: project.id,
    );
  }

  Future<void> _addItem(
    BuildContext context,
    Project project,
    String title,
    DateTime? dueDate, {
    DateTime? reminder,
    String? description,
  }) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      return;
    }

    final task = Task(
      title: title,
      dueDate: dueDate,
      description: description ?? '',
      reminderDates: reminder != null ? [TaskReminder(reminder)] : [],
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
