import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vikunja_app/core/utils/due_date_format.dart';
import 'package:vikunja_app/core/di/network_provider.dart';
import 'package:vikunja_app/core/di/sync_provider.dart';
import 'package:vikunja_app/domain/entities/smart_list.dart';
import 'package:vikunja_app/domain/entities/task.dart';
import 'package:vikunja_app/domain/entities/task_reminder.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/manager/smart_list_providers.dart';
import 'package:vikunja_app/presentation/manager/task_page_controller.dart';
import 'package:vikunja_app/presentation/pages/error_widget.dart';
import 'package:vikunja_app/presentation/pages/loading_widget.dart';
import 'package:vikunja_app/presentation/pages/task/task_edit_page.dart';
import 'package:vikunja_app/presentation/widgets/list_accent_scaffold.dart';
import 'package:vikunja_app/presentation/widgets/sort_chip.dart';
import 'package:vikunja_app/presentation/widgets/ui/adaptive.dart';
import 'package:vikunja_app/presentation/widgets/ui/constrained_page.dart';
import 'package:vikunja_app/presentation/widgets/task/add_task_bar.dart';
import 'package:vikunja_app/presentation/widgets/task/add_task_sheet.dart';
import 'package:vikunja_app/presentation/widgets/task/smart_list_section.dart';
import 'package:vikunja_app/presentation/widgets/task/task_list_item.dart';
import 'package:vikunja_app/presentation/widgets/task_bottom_sheet.dart';

/// Aufgabenliste einer [SmartList] (MS-To-Do-Stil): reaktiv aus der lokalen
/// DB, Tipp öffnet die Bearbeiten-Seite, Long-Press die Schnellvorschau,
/// unten die „Aufgabe hinzufügen"-Leiste (außer bei „Erledigt").
class SmartListPage extends ConsumerWidget {
  final SmartList list;

  const SmartListPage({super.key, required this.list});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final look = smartListLook(context, list);
    final tasks = ref.watch(smartListTasksProvider(list));
    final accent = look.pageColor;
    final fg = look.pageAccent == look.pageColor ? null : look.pageAccent;

    // „Mein Tag" trägt wie in To Do das heutige Datum als Untertitel —
    // und (anders als die übrigen Listen) kein Icon neben dem Titel.
    final l10n = AppLocalizations.of(context);
    final myDaySubtitle = list == SmartList.today
        ? DateFormat.MMMMEEEEd(l10n.localeName).format(DateTime.now())
        : null;

    return Scaffold(
      backgroundColor: accent,
      appBar: AccentAppBar(accentColor: accent, foregroundColor: fg),
      body: Column(
        children: [
          accentListTitle(
            context,
            look.title,
            accent,
            icon: list == SmartList.today ? null : look.icon,
            foregroundColor: fg,
            subtitle: myDaySubtitle,
          ),
          // "Erledigt" bleibt ohne Sortier-Chip (sie hat eine feste
          // Reihenfolge, siehe smartListTasksProvider).
          if (list != SmartList.completed)
            SortChip(listKey: 'smart/${list.name}', accentColor: accent),
          Expanded(
            child: withCardSurface(
              context: context,
              accent: look.pageAccent,
              child: tasks.when(
                data: (tasks) => ConstrainedPage(
                  child: RefreshIndicator(
                    onRefresh: () => ref
                        .read(syncServiceProvider)
                        .syncNow(userInitiated: true),
                    child: tasks.isEmpty
                        ? _buildEmptyState(context, look)
                        : _buildList(ref, context, tasks),
                  ),
                ),
                error: (err, _) => VikunjaErrorWidget(
                  error: err,
                  onRetry: () => ref.invalidate(smartListTasksProvider(list)),
                ),
                loading: () => const LoadingWidget(),
              ),
            ),
          ),
        ],
      ),
      // Kein Hinzufügen in "Erledigt" und "Mir zugewiesen" (dort würde eine
      // neue, noch niemandem zugewiesene Aufgabe sofort wieder verschwinden).
      bottomNavigationBar:
          (list == SmartList.completed || list == SmartList.assignedToMe)
          ? null
          : AddTaskBar(
              accentColor: accent,
              onTap: () => _addItemDialog(ref, context),
            ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ({
      String title,
      IconData icon,
      Color color,
      Color pageColor,
      Color pageAccent,
    })
    look,
  ) {
    // In ein ListView gehüllt, damit Pull-to-Refresh auch leer funktioniert;
    // Optik wie To Do: dezente Notizzeilen statt Illustration.
    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: constraints.maxHeight,
            child: NotebookLinesEmptyState(
              accentColor: look.pageColor,
              foregroundColor: look.pageAccent == look.pageColor
                  ? null
                  : look.pageAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(WidgetRef ref, BuildContext context, List<Task> tasks) {
    // „Geplant" gruppiert wie To Do nach Fälligkeits-Kalendertag mit
    // Datums-Chips als Gruppenköpfen.
    final entries = list == SmartList.planned
        ? _plannedEntries(context, tasks)
        : [for (final t in tasks) _ListEntry.task(t)];
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final header = entry.header;
        if (header != null) {
          return _DateGroupChip(label: header);
        }
        final task = entry.taskValue!;
        return TaskListItem(
          key: Key(task.id.toString()),
          task: task,
          onTap: () => _onEdit(context, task),
          onShowDetails: () => _showTaskBottomSheet(context, task),
          onEdit: () => _onEdit(context, task),
          onFavoriteToggle: () {
            task.isFavorite = !task.isFavorite;
            // Optimistisch; bei Server-Ablehnung rollt der OfflineWriter die
            // Zeile zurück und der Stream korrigiert die Anzeige.
            ref.read(taskPageControllerProvider.notifier).updateTask(task);
          },
          onCheckedChanged: (value) async {
            task.done = value;
            final success = await ref
                .read(taskPageControllerProvider.notifier)
                .updateTask(task);
            if (!success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context).taskMarkDoneError),
                ),
              );
            }
          },
        );
      },
    );
  }

  /// Aufgabenliste der „Geplant"-Seite mit Datums-Gruppenköpfen (ein Chip je
  /// Fälligkeits-Kalendertag, in der Reihenfolge der sortierten Aufgaben).
  List<_ListEntry> _plannedEntries(BuildContext context, List<Task> tasks) {
    final l10n = AppLocalizations.of(context);
    final entries = <_ListEntry>[];
    String? lastLabel;
    for (final task in tasks) {
      final due = task.dueDate;
      final label = (due != null && due.year > 1)
          ? formatDueDate(l10n, l10n.localeName, due)
          : null;
      if (label != null && label != lastLabel) {
        entries.add(_ListEntry.header(label));
        lastLabel = label;
      }
      entries.add(_ListEntry.task(task));
    }
    return entries;
  }

  void _addItemDialog(WidgetRef ref, BuildContext context) {
    final defaultProjectId =
        ref.read(currentUserProvider)?.settings?.defaultProjectId ?? 0;
    showAddTaskSheet(
      context,
      onAddTask: (title, dueDate, projectId, {reminder, description}) =>
          _addTask(
            ref,
            title,
            dueDate,
            projectId,
            reminder: reminder,
            description: description,
          ),
      defaultProjectId: defaultProjectId,
      selectableProject: true,
    );
  }

  Future<void> _addTask(
    WidgetRef ref,
    String title,
    DateTime? dueDate,
    int projectId, {
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
      projectId: projectId,
      // In „Wichtig" angelegte Aufgaben starten als Favorit.
      isFavorite: list == SmartList.important,
    );

    final success = await ref
        .read(taskPageControllerProvider.notifier)
        .addTask(projectId, task);

    if (ref.context.mounted && !success) {
      ScaffoldMessenger.of(ref.context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(ref.context).taskAddError)),
      );
    }
  }

  void _showTaskBottomSheet(BuildContext context, Task task) {
    showModalBottomSheet<void>(
      context: context,
      constraints: context.isCompact
          ? null
          : const BoxConstraints(maxWidth: 640),
      builder: (BuildContext context) {
        return TaskBottomSheet(
          task: task,
          onEdit: () => _onEdit(context, task),
        );
      },
    );
  }

  void _onEdit(BuildContext context, Task task) {
    Navigator.push<Task?>(
      context,
      MaterialPageRoute(builder: (buildContext) => TaskEditPage(task: task)),
    );
  }
}

/// Listeneintrag der Smart-List-Seite: entweder ein Datums-Gruppenkopf
/// (nur „Geplant") oder eine Aufgabe.
class _ListEntry {
  final String? header;
  final Task? taskValue;

  const _ListEntry.header(this.header) : taskValue = null;
  const _ListEntry.task(this.taskValue) : header = null;
}

/// Datums-Gruppenkopf der „Geplant"-Seite im Stil von To Do: kleiner Chip
/// („Mi. 31. Dez.") mit leicht abgedunkelter Fläche auf dem Akzent.
class _DateGroupChip extends StatelessWidget {
  final String label;

  const _DateGroupChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
