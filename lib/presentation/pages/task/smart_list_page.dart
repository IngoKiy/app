import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vikunja_app/core/di/network_provider.dart';
import 'package:vikunja_app/core/di/sync_provider.dart';
import 'package:vikunja_app/domain/entities/smart_list.dart';
import 'package:vikunja_app/domain/entities/task.dart';
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
import 'package:vikunja_app/presentation/widgets/ui/empty_state.dart';
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
    final accent = look.color;

    return Scaffold(
      backgroundColor: accent,
      appBar: AccentAppBar(accentColor: accent),
      body: Column(
        children: [
          accentListTitle(context, look.title, accent, icon: look.icon),
          // "Erledigt" bleibt ohne Sortier-Chip (sie hat eine feste
          // Reihenfolge, siehe smartListTasksProvider).
          if (list != SmartList.completed)
            SortChip(listKey: 'smart/${list.name}', accentColor: accent),
          Expanded(
            child: withCardSurface(
              context: context,
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
          : AddTaskBar(onTap: () => _addItemDialog(ref, context)),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ({String title, IconData icon, Color color}) look,
  ) {
    // In ein ListView gehüllt, damit Pull-to-Refresh auch leer funktioniert.
    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: constraints.maxHeight,
            child: EmptyState(icon: look.icon, title: look.title),
          ),
        ],
      ),
    );
  }

  Widget _buildList(WidgetRef ref, BuildContext context, List<Task> tasks) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
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

  void _addItemDialog(WidgetRef ref, BuildContext context) {
    final defaultProjectId =
        ref.read(currentUserProvider)?.settings?.defaultProjectId ?? 0;
    showAddTaskSheet(
      context,
      onAddTask: (title, dueDate, projectId) =>
          _addTask(ref, title, dueDate, projectId),
      defaultProjectId: defaultProjectId,
      selectableProject: true,
    );
  }

  Future<void> _addTask(
    WidgetRef ref,
    String title,
    DateTime? dueDate,
    int projectId,
  ) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      return;
    }

    final task = Task(
      title: title,
      dueDate: dueDate,
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
