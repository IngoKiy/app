import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vikunja_app/core/di/network_provider.dart';
import 'package:vikunja_app/core/di/database_provider.dart';
import 'package:vikunja_app/core/di/offline_provider.dart';
import 'package:vikunja_app/presentation/manager/projects_controller.dart';
import 'package:vikunja_app/presentation/manager/todo_prefs.dart';
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

  /// Öffnet nach dem Aufbau sofort den Umbenennen-Dialog — für den
  /// „+ Neue Liste"-Flow wie in To Do (anlegen, dann direkt benennen).
  final bool autoRename;

  const ProjectDetailPage({
    super.key,
    required this.project,
    this.autoRename = false,
  });

  @override
  ProjectPageState createState() => ProjectPageState();
}

class ProjectPageState extends ConsumerState<ProjectDetailPage> {
  int _viewIndex = 0;
  NotificationHandler? _notificationHandler;

  /// Beim Scrollen erscheint der Listentitel in der Navbar (To-Do-Kollaps).
  bool _titleInBar = false;

  @override
  void initState() {
    _notificationHandler = ref.read(notificationProvider);
    _notificationHandler?.addListener(onNotificationDone);
    if (widget.autoRename) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _renameList(widget.project);
      });
    }
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
        final bgAssetEarly = isListView
            ? ref
                  .watch(listBackgroundProvider('project/${data.project.id}'))
                  .value
            : null;
        final scrollBody = NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels ==
                scrollInfo.metrics.maxScrollExtent) {
              ref
                  .read(projectControllerProvider(widget.project).notifier)
                  .loadNextPage();
            }
            if (scrollInfo.depth == 0 &&
                scrollInfo.metrics.axis == Axis.vertical) {
              final collapsed = scrollInfo.metrics.pixels > 56;
              if (collapsed != _titleInBar) {
                setState(() => _titleInBar = collapsed);
              }
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
            child: getBody(data.project, overPhoto: bgAssetEarly != null),
          ),
        );

        // Wie Microsoft To Do: unten die „Aufgabe hinzufügen"-Leiste statt
        // FAB; der Ansichts-Wechsel (Kanban etc.) liegt im AppBar-Menü statt
        // in einer Bottom-Navigation.
        final showAddBar = isListView && data.project.id > 0;
        // Foto-Hintergrund der Liste (Design-Sheet, Tab Foto) — liegt wie in
        // To Do vollflächig hinter den Aufgaben-Karten.
        final bgAsset = bgAssetEarly;
        // Foto liegt hinter der GESAMTEN Seite (auch hinter Navbar und
        // Statusleiste, wie in To Do): Container trägt das Bild, Scaffold
        // und AppBar werden transparent.
        final page = Scaffold(
          backgroundColor: bgAsset != null ? Colors.transparent : accentColor,
          appBar: _buildAppBar(
            context,
            data.project,
            data.displayDoneTask,
            accentColor,
            transparentBar: bgAsset != null,
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
                  overPhoto: bgAsset != null,
                  onTap: () => _addITaskDialog(context, data.project),
                )
              : null,
        );
        if (bgAsset == null) return page;
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(bgAsset),
              fit: BoxFit.cover,
            ),
          ),
          child: page,
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

  Widget getBody(Project project, {bool overPhoto = false}) {
    if (project.views.isEmpty) {
      return Text(AppLocalizations.of(context).noViews);
    }

    switch (project.views[_viewIndex].viewKind) {
      case ViewKind.list:
        return ProjectTaskList(project, overPhoto: overPhoto);
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
    Color? accentColor, {
    bool transparentBar = false,
  }) {
    // Wie Microsoft To Do: ein einzelnes „…" öffnet das Listenoptionen-Sheet
    // (Umbenennen, Sortieren, Design ändern, Mitglieder, Ansicht, Bearbeiten).
    final actions = <Widget>[
      // Freigabe-Symbol wie in To Do (öffnet die Mitglieder-Verwaltung).
      if (project.id > 0)
        IconButton(
          icon: const Icon(Icons.person_add_alt),
          tooltip: AppLocalizations.of(context).projectMembers,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProjectMembersPage(projectId: project.id),
            ),
          ),
        ),
      IconButton(
        icon: const Icon(Icons.more_horiz),
        tooltip: AppLocalizations.of(context).listOptionsTitle,
        onPressed: () => _showListOptions(project, displayDoneTask),
      ),
    ];

    // Listen-Ansicht: Akzentfarbe + Zurück-Button „Listen" (wie To Do); die
    // Kanban-Ansicht behält die normale AppBar.
    if (accentColor != null) {
      return AccentAppBar(
        accentColor: accentColor,
        barColor: transparentBar ? Colors.transparent : null,
        actions: actions,
        title: project.title,
        showTitle: _titleInBar,
      );
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
          icon: Icons.drive_file_move_outline,
          label: l10n.moveListTo,
          chevron: true,
          value: 'move',
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
          icon: Icons.copy_outlined,
          label: l10n.duplicateList,
          value: 'duplicate',
        ),
        PresetOption(
          icon: Icons.ios_share,
          label: l10n.sendCopy,
          value: 'send',
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
      case 'move':
        await _showMoveToGroupSheet(project);
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
      case 'duplicate':
        await _duplicateList(project);
      case 'send':
        await _sendListCopy(project);
      case 'delete':
        await _confirmAndDeleteList(project);
    }
  }

  /// Dupliziert die Liste wie in To Do: neue Liste `<Titel> (Kopie)` mit
  /// denselben offenen Aufgaben (Titel + Fälligkeit + Beschreibung).
  Future<void> _duplicateList(Project project) async {
    final l10n = AppLocalizations.of(context);
    final currentUser = ref.read(currentUserProvider);
    final tasks =
        ref.read(projectControllerProvider(widget.project)).value?.tasks ??
        const <Task>[];
    final copyTitle = '${project.title} (${l10n.copySuffix})';

    final result = await ref
        .read(projectsControllerProvider.notifier)
        .create(
          Project(title: copyTitle, owner: currentUser, color: project.color),
        );
    if (!result.ok || !mounted) return;

    // Neue Projekt-ID aus dem Stream auflösen, dann Aufgaben kopieren.
    for (var attempt = 0; attempt < 10; attempt++) {
      final created = ref
          .read(projectsControllerProvider)
          .value
          ?.projects
          .where((p) => p.title == copyTitle)
          .toList();
      if (created != null && created.isNotEmpty) {
        final newId = created.first.id;
        for (final task in tasks.where((t) => !t.done)) {
          await ref
              .read(offlineWriterProvider)
              .addTask(
                newId,
                Task(
                  title: task.title,
                  description: task.description,
                  dueDate: task.dueDate,
                  createdBy: currentUser,
                  projectId: newId,
                  isFavorite: task.isFavorite,
                ),
              );
        }
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  /// „Kopie senden": Liste als Text über das System-Share-Sheet teilen
  /// (deckt auch Drucken über die Teilen-Ziele ab).
  Future<void> _sendListCopy(Project project) async {
    final tasks =
        ref.read(projectControllerProvider(widget.project)).value?.tasks ??
        const <Task>[];
    final buffer = StringBuffer()..writeln(project.title);
    for (final task in tasks) {
      buffer.writeln('${task.done ? '☑' : '☐'} ${task.title}');
    }
    await SharePlus.instance.share(ShareParams(text: buffer.toString()));
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

  /// „Liste verschieben in…": ordnet die Liste einer Gruppe (Elternprojekt)
  /// zu bzw. löst sie mit „Keine Gruppe" wieder heraus.
  Future<void> _showMoveToGroupSheet(Project project) async {
    final l10n = AppLocalizations.of(context);
    final candidates =
        ref
            .read(projectsControllerProvider)
            .value
            ?.projects
            .where((p) => !p.isSavedFilter && p.id > 0 && p.id != project.id)
            .toList() ??
        const <Project>[];
    final choice = await showPresetSheet<int>(
      context,
      title: l10n.moveListTo,
      options: [
        PresetOption(
          icon: Icons.folder_off_outlined,
          label: l10n.noGroup,
          value: 0,
        ),
        for (final p in candidates)
          PresetOption(
            icon: Icons.folder_outlined,
            label: p.title,
            value: p.id,
          ),
      ],
    );
    if (choice == null || !mounted) return;
    final updated = project.copyWith(parentProjectId: choice)
      ..parentProjectId = choice;
    await ref
        .read(projectControllerProvider(widget.project).notifier)
        .updateProject(updated);
    ref.invalidate(projectsControllerProvider);
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
    // Auswahl: Farbe (Color), Foto-Hintergrund (String-Asset) oder
    // 'clear' zum Entfernen des Fotos.
    final selected = await showModalBottomSheet<Object>(
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
            const SizedBox(height: 16),
            // „Foto"-Hintergründe wie in To Do (gebündelte Verläufe).
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  InkWell(
                    onTap: () => Navigator.of(sheetContext).pop('clear'),
                    child: Container(
                      width: 56,
                      height: 84,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(
                            sheetContext,
                          ).colorScheme.outlineVariant,
                        ),
                      ),
                      child: const Icon(Icons.block),
                    ),
                  ),
                  for (final asset in listBackgroundAssets)
                    InkWell(
                      onTap: () => Navigator.of(sheetContext).pop(asset),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          asset,
                          width: 56,
                          height: 84,
                          fit: BoxFit.cover,
                        ),
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
    final kv = ref.read(keyValueDaoProvider);
    if (selected is Color) {
      final updated = project.copyWith()..color = selected;
      await ref
          .read(projectControllerProvider(widget.project).notifier)
          .updateProject(updated);
    } else if (selected == 'clear') {
      await setListBackground(kv, 'project/${project.id}', null);
    } else if (selected is String) {
      await setListBackground(kv, 'project/${project.id}', selected);
    }
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
      onAddTask:
          (title, dueDate, _, {reminder, description, addToMyDay = false}) =>
              _addItem(
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
