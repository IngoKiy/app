import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:vikunja_app/core/utils/calculate_item_position.dart';
import 'package:vikunja_app/domain/entities/project.dart';
import 'package:vikunja_app/domain/entities/task.dart';
import 'package:vikunja_app/domain/entities/task_sort.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/manager/project_controller.dart';
import 'package:vikunja_app/presentation/manager/smart_list_providers.dart';
import 'package:vikunja_app/presentation/pages/error_widget.dart';
import 'package:vikunja_app/presentation/pages/loading_widget.dart';
import 'package:vikunja_app/presentation/pages/project/project_detail_page.dart';
import 'package:vikunja_app/presentation/pages/task/task_edit_page.dart';
import 'package:vikunja_app/presentation/widgets/list_accent_scaffold.dart';
import 'package:vikunja_app/presentation/widgets/sort_chip.dart';
import 'package:vikunja_app/presentation/widgets/ui/empty_state.dart';
import 'package:vikunja_app/presentation/manager/task_page_controller.dart';
import 'package:vikunja_app/presentation/widgets/task/task_list_item.dart';

/// Aufgabenliste eines Projekts (List-View), im Stil von Microsoft To Do:
/// Akzentfarbe des Projekts, großer Titel, Sortier-Chip, offene Aufgaben
/// oben (per Drag umsortierbar, solange kein Sortier-Modus aktiv ist),
/// Erledigte darunter in einer einklappbaren Gruppe.
class ProjectTaskList extends ConsumerStatefulWidget {
  final Project project;

  /// Liste hat einen Foto-Hintergrund → Chips transluzent statt akzentfarben.
  final bool overPhoto;

  const ProjectTaskList(this.project, {super.key, this.overPhoto = false});

  @override
  ConsumerState<ProjectTaskList> createState() => _ProjectTaskListState();
}

class _ProjectTaskListState extends ConsumerState<ProjectTaskList> {
  bool _doneExpanded = false;

  Project get project => widget.project;

  @override
  Widget build(BuildContext context) {
    var projectController = ref.watch(projectControllerProvider(project));
    final theme = Theme.of(context);
    final accentColor = project.color ?? theme.colorScheme.primary;
    final sortKey = 'project/${project.id}';
    final sortMode = ref.watch(listSortModeProvider(sortKey)).value;

    return projectController.when(
      data: (pageModel) {
        final openTasks = pageModel.tasks.where((t) => !t.done).toList();
        final doneTasks = pageModel.tasks.where((t) => t.done).toList();
        final orderedOpenTasks = sortMode == null
            ? openTasks
            : sortTasks(openTasks, sortMode);

        List<Widget> children = [
          SliverToBoxAdapter(
            child: accentListTitle(
              context,
              project.title,
              accentColor,
              foregroundColor: widget.overPhoto ? Colors.white : null,
            ),
          ),
          SliverToBoxAdapter(
            child: SortChip(
              listKey: sortKey,
              allowManualOrder: true,
              accentColor: accentColor,
              overPhoto: widget.overPhoto,
            ),
          ),
        ];

        if (project.subprojects.isNotEmpty) {
          if (openTasks.isNotEmpty || doneTasks.isNotEmpty) {
            children.add(
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  AppLocalizations.of(context).projectSection,
                ),
              ),
            );
            children.add(SliverToBoxAdapter(child: Divider()));
          }
          children.addAll(_buildProjectList(context));
        }

        if (openTasks.isNotEmpty) {
          if (project.subprojects.isNotEmpty) {
            children.add(
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  AppLocalizations.of(context).tasksSection,
                ),
              ),
            );
            children.add(SliverToBoxAdapter(child: Divider()));
          }
          // Manuelles Umsortieren ergibt bei aktiver Sortierung keinen Sinn.
          children.add(
            sortMode == null
                ? _buildReorderableTaskList(ref, orderedOpenTasks)
                : _buildPlainTaskList(ref, orderedOpenTasks),
          );
        }

        if (doneTasks.isNotEmpty) {
          children.add(
            SliverToBoxAdapter(
              child: _buildDoneHeader(context, doneTasks.length),
            ),
          );
          if (_doneExpanded) {
            children.add(_buildPlainTaskList(ref, doneTasks));
          }
        }

        if (pageModel.isLoadingNextPage) {
          children.add(
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: SpinKitThreeBounce(
                    color: Theme.of(context).primaryColor,
                    size: 16,
                  ),
                ),
              ),
            ),
          );
        }

        if (openTasks.isEmpty &&
            doneTasks.isEmpty &&
            project.subprojects.isEmpty) {
          children.add(
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.list,
                title: AppLocalizations.of(context).noTasksOrSubproject,
              ),
            ),
          );
        }

        return withCardSurface(
          context: context,
          accent: accentColor,
          child: CustomScrollView(slivers: children),
        );
      },
      error: (err, _) => VikunjaErrorWidget(error: err),
      loading: () => const LoadingWidget(),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }

  Widget _buildDoneHeader(BuildContext context, int count) {
    final l10n = AppLocalizations.of(context);
    return InkWell(
      onTap: () => setState(() => _doneExpanded = !_doneExpanded),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(_doneExpanded ? Icons.expand_more : Icons.chevron_right),
            const SizedBox(width: 4),
            Text(
              '${l10n.smartListCompleted} $count',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildProjectList(BuildContext context) {
    return [
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final subproject = project.subprojects.toList()[index];
          return ListTile(
            leading: Icon(Icons.list),
            onTap: () => _navigateToDetail(context, subproject),
            title: Text(
              subproject.title,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          );
        }, childCount: project.subprojects.length),
      ),
    ];
  }

  Widget _buildReorderableTaskList(WidgetRef ref, List<Task> tasks) {
    return SliverReorderableList(
      itemBuilder: (context, index) {
        final task = tasks[index];
        return ReorderableDelayedDragStartListener(
          key: Key('task_${task.id}'),
          index: index,
          child: Material(
            color: Colors.transparent,
            child: _buildTile(ref, task),
          ),
        );
      },
      itemCount: tasks.length,
      onReorder: (oldIndex, newIndexRaw) {
        int newIndex = newIndexRaw;
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }

        if (newIndex < -1) newIndex = -1;

        final taskList = List<Task>.from(tasks);
        final moved = taskList.removeAt(oldIndex);
        final insertIndex = newIndex == -1
            ? 0
            : newIndex.clamp(0, taskList.length);
        taskList.insert(insertIndex, moved);

        final before = insertIndex == 0
            ? null
            : taskList[insertIndex - 1].position;
        final after = insertIndex == taskList.length - 1
            ? null
            : taskList[insertIndex + 1].position;
        final newPos = calculateItemPosition(
          positionBefore: before,
          positionAfter: after,
        );

        ref
            .read(projectControllerProvider(project).notifier)
            .reorderTasks(
              project: project,
              newOrderedTasks: taskList,
              movedTaskId: moved.id,
              newPosition: newPos,
            )
            .then((success) {
              if (!success && ref.context.mounted) {
                ScaffoldMessenger.of(ref.context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(ref.context).taskMoveError,
                    ),
                  ),
                );
              }
            });
      },
    );
  }

  /// Zeile ohne Drag: für sortierte offene Aufgaben und für Erledigte, bei
  /// denen manuelles Umsortieren keinen Sinn ergibt.
  Widget _buildPlainTaskList(WidgetRef ref, List<Task> tasks) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildTile(ref, tasks[index]),
        childCount: tasks.length,
      ),
    );
  }

  Widget _buildTile(WidgetRef ref, Task task) {
    return TaskListItem(
      key: Key(task.id.toString()),
      task: task,
      // Tipp öffnet direkt die Bearbeiten-Seite. Kein Long-Press für die
      // Schnellvorschau — der startet hier das Umsortieren (Drag).
      onTap: () => _onEdit(ref, task),
      onEdit: () => _onEdit(ref, task),
      onFavoriteToggle: () {
        task.isFavorite = !task.isFavorite;
        ref.read(taskPageControllerProvider.notifier).updateTask(task);
      },
      onCheckedChanged: (value) async {
        var success = await ref
            .read(projectControllerProvider(project).notifier)
            .markAsDone(task);
        if (!success && ref.context.mounted) {
          ScaffoldMessenger.of(ref.context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(ref.context).failedToMarkDone),
            ),
          );
        }
      },
    );
  }

  void _onEdit(WidgetRef ref, Task task) {
    // Kein Reload nötig: die Liste hängt an Drift-watch-Streams und zieht
    // Autosave-Änderungen der Edit-Seite von selbst nach.
    Navigator.push<Task?>(
      ref.context,
      MaterialPageRoute(builder: (buildContext) => TaskEditPage(task: task)),
    );
  }

  void _navigateToDetail(BuildContext context, Project project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return ProjectDetailPage(
            key: Key(project.id.toString()),
            project: project,
          );
        },
      ),
    );
  }
}
