import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vikunja_app/core/utils/due_date_format.dart';
import 'package:vikunja_app/core/di/database_provider.dart';
import 'package:vikunja_app/core/di/network_provider.dart';
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
import 'package:vikunja_app/presentation/widgets/sync_status_icon.dart';
import 'package:vikunja_app/presentation/widgets/ui/adaptive.dart';
import 'package:vikunja_app/presentation/widgets/ui/constrained_page.dart';
import 'package:vikunja_app/presentation/widgets/task/add_task_bar.dart';
import 'package:vikunja_app/presentation/widgets/task/add_task_sheet.dart';
import 'package:vikunja_app/presentation/widgets/task/smart_list_section.dart';
import 'package:vikunja_app/presentation/widgets/task/suggestions_sheet.dart';
import 'package:vikunja_app/presentation/widgets/task/task_list_item.dart';
import 'package:vikunja_app/presentation/widgets/task_bottom_sheet.dart';
import 'package:vikunja_app/presentation/widgets/ui/preset_sheet.dart';

/// Filter der „Geplant"-Seite (Chip „Alles geplant" wie in To Do).
enum _PlannedFilter { all, overdue, today, tomorrow, thisWeek, later }

/// Aufgabenliste einer [SmartList] (MS-To-Do-Stil): reaktiv aus der lokalen
/// DB, Tipp öffnet die Bearbeiten-Seite, Long-Press die Schnellvorschau,
/// unten die „Aufgabe hinzufügen"-Leiste (außer bei „Erledigt").
class SmartListPage extends ConsumerStatefulWidget {
  final SmartList list;

  const SmartListPage({super.key, required this.list});

  @override
  ConsumerState<SmartListPage> createState() => _SmartListPageState();
}

class _SmartListPageState extends ConsumerState<SmartListPage> {
  SmartList get list => widget.list;

  /// Beim Scrollen erscheint der Listentitel in der Navbar (To-Do-Kollaps).
  bool _titleInBar = false;

  /// Aktiver „Geplant"-Filter (Chip „Alles geplant").
  _PlannedFilter _plannedFilter = _PlannedFilter.all;

  @override
  Widget build(BuildContext context) {
    final look = smartListLook(context, list);
    final tasks = ref.watch(smartListTasksProvider(list));
    // Im Dunkelmodus wird die Fläche abgedunkelt (siehe listAccentColors),
    // damit die Karten wieder heller sind als ihr Grund.
    final colors = listAccentColors(
      context,
      look.pageColor,
      lightForeground: look.pageAccent == look.pageColor
          ? null
          : look.pageAccent,
    );
    final accent = colors.surface;
    final fg = colors.foreground;

    // „Mein Tag" trägt wie in To Do das heutige Datum als Untertitel —
    // und (anders als die übrigen Listen) kein Icon neben dem Titel.
    final l10n = AppLocalizations.of(context);
    final myDaySubtitle = list == SmartList.today
        ? DateFormat.MMMMEEEEd(l10n.localeName).format(DateTime.now())
        : null;

    return Scaffold(
      backgroundColor: accent,
      appBar: AccentAppBar(
        accentColor: accent,
        foregroundColor: fg,
        title: look.title,
        showTitle: _titleInBar,
        actions: [
          // Glühbirne auf „Mein Tag": öffnet die Vorschläge (wie To Do).
          if (list == SmartList.today)
            IconButton(
              icon: const Icon(Icons.lightbulb_outline),
              tooltip: l10n.suggestionsTitle,
              onPressed: () => showSuggestionsSheet(context),
            ),
        ],
      ),
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
            Row(
              children: [
                // „Geplant": Filter-Chip („Alles geplant" …) wie in To Do.
                if (list == SmartList.planned)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
                    child: _PlannedFilterChip(
                      accent: accent,
                      fg: fg,
                      value: _plannedFilter,
                      onTap: _showPlannedFilterSheet,
                    ),
                  ),
                Expanded(
                  child: SortChip(
                    listKey: 'smart/${list.name}',
                    accentColor: accent,
                  ),
                ),
              ],
            ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n.depth == 0 && n.metrics.axis == Axis.vertical) {
                  final collapsed = n.metrics.pixels > 24;
                  if (collapsed != _titleInBar) {
                    setState(() => _titleInBar = collapsed);
                  }
                }
                return false;
              },
              child: withCardSurface(
                context: context,
                accent: Theme.of(context).brightness == Brightness.dark
                    ? look.color
                    : look.pageAccent,
                child: tasks.when(
                  data: (tasks) => ConstrainedPage(
                    child: RefreshIndicator(
                      // Direkt unter der Kopfzeile statt mitten über den Einträgen.
                      displacement: 12,
                      onRefresh: () => refreshWithSync(ref),
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

  Future<void> _showPlannedFilterSheet() async {
    final l10n = AppLocalizations.of(context);
    final labels = _plannedFilterLabels(l10n);
    final choice = await showPresetSheet<_PlannedFilter>(
      context,
      title: labels[_PlannedFilter.all]!,
      options: [
        for (final f in _PlannedFilter.values)
          PresetOption(
            icon: f == _plannedFilter
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            label: labels[f]!,
            value: f,
          ),
      ],
    );
    if (choice != null && mounted) {
      setState(() => _plannedFilter = choice);
    }
  }

  Map<_PlannedFilter, String> _plannedFilterLabels(AppLocalizations l10n) => {
    _PlannedFilter.all: l10n.plannedFilterAll,
    _PlannedFilter.overdue: l10n.plannedFilterOverdue,
    _PlannedFilter.today: l10n.plannedFilterToday,
    _PlannedFilter.tomorrow: l10n.plannedFilterTomorrow,
    _PlannedFilter.thisWeek: l10n.plannedFilterThisWeek,
    _PlannedFilter.later: l10n.plannedFilterLater,
  };

  bool _matchesPlannedFilter(Task task) {
    if (_plannedFilter == _PlannedFilter.all) return true;
    final due = task.dueDate;
    if (due == null || due.year <= 1) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(due.year, due.month, due.day);
    final diff = day.difference(today).inDays;
    switch (_plannedFilter) {
      case _PlannedFilter.all:
        return true;
      case _PlannedFilter.overdue:
        return diff < 0;
      case _PlannedFilter.today:
        return diff == 0;
      case _PlannedFilter.tomorrow:
        return diff == 1;
      case _PlannedFilter.thisWeek:
        return diff >= 0 && diff < 8 - today.weekday;
      case _PlannedFilter.later:
        return diff >= 8 - today.weekday;
    }
  }

  /// Aufgabenliste der „Geplant"-Seite mit Datums-Gruppenköpfen (ein Chip je
  /// Fälligkeits-Kalendertag, in der Reihenfolge der sortierten Aufgaben).
  List<_ListEntry> _plannedEntries(BuildContext context, List<Task> tasks) {
    final l10n = AppLocalizations.of(context);
    final entries = <_ListEntry>[];
    String? lastLabel;
    for (final task in tasks.where(_matchesPlannedFilter)) {
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
      onAddTask:
          (
            title,
            dueDate,
            projectId, {
            reminder,
            description,
            addToMyDay = false,
          }) => _addTask(
            ref,
            title,
            dueDate,
            projectId,
            reminder: reminder,
            description: description,
            addToMyDay: addToMyDay,
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
    bool addToMyDay = false,
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

    final controller = ref.read(taskPageControllerProvider.notifier);
    final bool success;
    if (addToMyDay || list == SmartList.today) {
      // Sonne im Composer bzw. Anlegen aus „Mein Tag": direkt in den
      // heutigen Mein Tag übernehmen (lokale Temp-ID reicht dafür).
      final id = await controller.addTaskReturningId(projectId, task);
      success = id != null;
      if (id != null) {
        await ref
            .read(tasksDaoProvider)
            .addToMyDay(id, localDayKey(DateTime.now()));
      }
    } else {
      success = await controller.addTask(projectId, task);
    }

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

/// Filter-Chip der „Geplant"-Seite im Stil des Sort-Chips.
class _PlannedFilterChip extends StatelessWidget {
  final Color accent;
  final Color? fg;
  final _PlannedFilter value;
  final VoidCallback onTap;

  const _PlannedFilterChip({
    required this.accent,
    required this.fg,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = {
      _PlannedFilter.all: l10n.plannedFilterAll,
      _PlannedFilter.overdue: l10n.plannedFilterOverdue,
      _PlannedFilter.today: l10n.plannedFilterToday,
      _PlannedFilter.tomorrow: l10n.plannedFilterTomorrow,
      _PlannedFilter.thisWeek: l10n.plannedFilterThisWeek,
      _PlannedFilter.later: l10n.plannedFilterLater,
    };
    final theme = Theme.of(context);
    final color = fg ?? Colors.white;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Color.alphaBlend(Colors.black.withValues(alpha: 0.10), accent),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_list, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              labels[value]!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
