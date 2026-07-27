import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:vikunja_app/core/di/database_provider.dart';
import 'package:vikunja_app/core/theming/dimensions.dart';
import 'package:vikunja_app/core/theming/todo_colors.dart';
import 'package:vikunja_app/presentation/manager/projects_controller.dart';
import 'package:vikunja_app/presentation/manager/todo_prefs.dart';
import 'package:vikunja_app/core/utils/task_steps.dart';
import 'package:vikunja_app/domain/entities/project.dart';
import 'package:vikunja_app/domain/entities/smart_list.dart';
import 'package:vikunja_app/domain/entities/task.dart';
import 'package:vikunja_app/domain/entities/user.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/manager/smart_list_providers.dart';
import 'package:vikunja_app/presentation/manager/task_page_controller.dart';
import 'package:vikunja_app/presentation/widgets/due_date_card.dart';
import 'package:vikunja_app/presentation/widgets/project/kanban/priority_batch.dart';
import 'package:vikunja_app/presentation/widgets/task/round_checkbox.dart';
import 'package:vikunja_app/presentation/widgets/task/task_delete_dialog.dart';
import 'package:vikunja_app/presentation/widgets/user_avatar.dart';

/// Aufgabenzeile im Stil von Microsoft To Do: Karte mit runder Checkbox,
/// Titel + Metazeile (Schritte, Mein-Tag, Projekt, Fälligkeit, Priorität) und
/// Stern-Toggle für Favoriten ("Wichtig"). Eine eigene Aufgabenfarbe erscheint
/// als schmaler Balken am linken Kartenrand.
///
/// Gesten wie im Vorbild: Wischen nach rechts legt die runden Aktionen
/// „Mein Tag" (blau) und „Verschieben" (orange) frei, Wischen nach links den
/// roten Löschen-Button. Erledigt wird ausschließlich über den Kreis —
/// kein Abhaken per Swipe.
class TaskListItem extends ConsumerStatefulWidget {
  final Task task;
  final Function onTap;
  final Function onEdit;
  final Function(bool value) onCheckedChanged;

  /// Stern-Toggle: Favorit setzen/entfernen. Ohne Callback wird kein Stern
  /// angezeigt.
  final VoidCallback? onFavoriteToggle;

  /// Öffnet die Schnellvorschau (Long-Press auf die Karte).
  final VoidCallback? onShowDetails;

  const TaskListItem({
    super.key,
    required this.task,
    required this.onTap,
    required this.onEdit,
    required this.onCheckedChanged,
    this.onFavoriteToggle,
    this.onShowDetails,
  });

  @override
  ConsumerState<TaskListItem> createState() => TaskListItemState();
}

class TaskListItemState extends ConsumerState<TaskListItem> {
  TaskListItemState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final task = widget.task;
    final inMyDay = ref.watch(taskInMyDayProvider(task.id)).value ?? false;

    return Slidable(
      key: ValueKey('task-list-item-slidable-${task.id}'),
      // Rechts wischen (leading): runde Aktionen wie in To Do — Mein Tag
      // (blau, Sonne) und Verschieben (orange).
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.42,
        children: [
          _RoundSlidableAction(
            color: TodoColors.actionBlue,
            icon: inMyDay ? Icons.wb_sunny : Icons.wb_sunny_outlined,
            onPressed: () => _toggleMyDay(inMyDay),
          ),
          _RoundSlidableAction(
            color: TodoColors.actionOrange,
            icon: Icons.playlist_play,
            onPressed: _showMoveSheet,
          ),
        ],
      ),
      // Links wischen (trailing): roter Löschen-Button.
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.24,
        children: [
          _RoundSlidableAction(
            color: TodoColors.actionRed,
            icon: Icons.delete_outline,
            onPressed: _confirmAndDelete,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
        child: Material(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => widget.onTap(),
            onLongPress: widget.onShowDetails,
            // IntrinsicHeight, damit der Farbbalken (stretch) die volle
            // Kartenhöhe bekommt, ohne feste Zeilenhöhen vorzugeben.
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (task.hasCustomColor)
                    Container(width: 4.0, color: task.color),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 10.0,
                      ),
                      child: Row(
                        children: [
                          RoundCheckbox(
                            value: task.done,
                            onChanged: (newValue) {
                              // Erledigt-Sound wie in To Do (abschaltbar).
                              if (newValue) {
                                playCompletionSound(
                                  ref.read(keyValueDaoProvider),
                                );
                              }
                              widget.onCheckedChanged(newValue);
                            },
                          ),
                          const SizedBox(width: 4),
                          Expanded(child: _buildContent(task, theme, inMyDay)),
                          if (task.assignees.isNotEmpty)
                            _buildAssigneeAvatars(task.assignees),
                          if (widget.onFavoriteToggle != null)
                            IconButton(
                              onPressed: widget.onFavoriteToggle,
                              icon: Icon(
                                task.isFavorite
                                    ? Icons.star
                                    : Icons.star_border,
                                color: task.isFavorite
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Swipe-Aktionen
  // ---------------------------------------------------------------------

  /// „Verschieben"-Aktion (oranger Swipe-Button): Sheet mit den Projekten;
  /// Auswahl verschiebt die Aufgabe (projectId + updateTask, optimistisch).
  Future<void> _showMoveSheet() async {
    final projectsModel = ref.read(projectsControllerProvider).value;
    if (projectsModel == null) return;
    final projects = projectsModel.projects
        .where((p) => !p.isSavedFilter && p.id > 0)
        .toList();
    final selected = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final p in projects)
                ListTile(
                  leading: Icon(
                    Icons.format_list_bulleted,
                    color:
                        p.color ?? Theme.of(sheetContext).colorScheme.primary,
                  ),
                  title: Text(p.title),
                  trailing: p.id == widget.task.projectId
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => Navigator.of(sheetContext).pop(p.id),
                ),
            ],
          ),
        );
      },
    );
    if (selected == null || selected == widget.task.projectId) return;
    widget.task.projectId = selected;
    final ok = await ref
        .read(taskPageControllerProvider.notifier)
        .updateTask(widget.task);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).taskMoveError)),
      );
    }
  }

  /// Mein-Tag-Toggle: rein lokal (kein Server-Sync), siehe `my_day_entries`.
  Future<void> _toggleMyDay(bool currentlyInMyDay) async {
    final dao = ref.read(tasksDaoProvider);
    final dayKey = localDayKey(DateTime.now());
    if (currentlyInMyDay) {
      await dao.removeFromMyDay(widget.task.id, dayKey);
    } else {
      await dao.addToMyDay(widget.task.id, dayKey);
    }
  }

  Future<void> _confirmAndDelete() {
    final l10n = AppLocalizations.of(context);
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return TaskDeleteDialog(
          widget.task.id,
          onConfirm: () async {
            Navigator.of(dialogContext).pop();
            final ok = await ref
                .read(taskPageControllerProvider.notifier)
                .deleteTask(widget.task.id);
            if (!ok && mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.taskDeleteError)));
            }
          },
          onCancel: () => Navigator.of(dialogContext).pop(),
        );
      },
    );
  }

  // ---------------------------------------------------------------------
  // Inhalt der Karte
  // ---------------------------------------------------------------------

  Widget _buildContent(Task task, ThemeData theme, bool inMyDay) {
    final subtitle = _buildTaskSubtitle(task, context, inMyDay);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          task.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyLarge?.copyWith(
            decoration: task.done ? TextDecoration.lineThrough : null,
            color: task.done ? theme.colorScheme.onSurfaceVariant : null,
          ),
        ),
        if (subtitle != null)
          Padding(padding: const EdgeInsets.only(top: 2.0), child: subtitle),
      ],
    );
  }

  /// Bis zu drei überlappende Mini-Avatare der zugewiesenen Personen,
  /// bei mehr Personen mit "+n"-Kreis.
  Widget _buildAssigneeAvatars(List<User> assignees) {
    const maxShown = 3;
    const radius = 11.0;
    const overlap = 15.0;
    final shown = assignees.take(maxShown).toList();
    final more = assignees.length - shown.length;
    final slots = shown.length + (more > 0 ? 1 : 0);

    return SizedBox(
      width: 2 * radius + (slots - 1) * overlap,
      height: 2 * radius,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: i * overlap,
              child: UserAvatar(user: shown[i], radius: radius),
            ),
          if (more > 0)
            Positioned(
              left: shown.length * overlap,
              child: CircleAvatar(
                radius: radius,
                child: Text('+$more', style: const TextStyle(fontSize: 9)),
              ),
            ),
        ],
      ),
    );
  }

  Widget? _buildTaskSubtitle(Task task, BuildContext context, bool inMyDay) {
    final chips = <Widget>[];

    final progress = stepProgress(task.description);
    if (progress.total > 0) {
      chips.add(
        _MetaText(
          AppLocalizations.of(
            context,
          ).stepsProgress(progress.done, progress.total),
        ),
      );
    }

    if (inMyDay) {
      chips.add(
        _MyDayBadge(label: AppLocalizations.of(context).smartListMyDay),
      );
    }

    final project = task.project;
    if (project != null) {
      chips.add(_ProjectChip(project: project));
    }
    if (task.hasDueDate) {
      chips.add(DueDateCard(task.dueDate!));
    }
    if (task.priority != null && task.priority != 0) {
      chips.add(PriorityBatch(task.priority!));
    }

    if (chips.isEmpty) {
      return null;
    }

    return Wrap(
      spacing: 8,
      runSpacing: 2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: chips,
    );
  }
}

/// Runder Swipe-Aktions-Button wie in Microsoft To Do (farbige Pille mit
/// weißem Icon, vertikal zentriert).
class _RoundSlidableAction extends StatelessWidget {
  final Color color;
  final IconData icon;
  final VoidCallback onPressed;

  const _RoundSlidableAction({
    required this.color,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CustomSlidableAction(
      onPressed: (_) => onPressed(),
      backgroundColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Center(
        child: Container(
          width: 56,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(icon, size: 20, color: Colors.white),
        ),
      ),
    );
  }
}

/// Dezenter Metadaten-Text in der Zeile (Stil wie der Projekt-Chip): z. B.
/// der Schritte-Fortschritt "x von y".
class _MetaText extends StatelessWidget {
  final String text;

  const _MetaText(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// Dezentes Mein-Tag-Kennzeichen: kleines Sonnen-Icon + Beschriftung, wenn
/// eine Aufgabe heute manuell in "Mein Tag" ist.
class _MyDayBadge extends StatelessWidget {
  final String label;

  const _MyDayBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.wb_sunny_outlined, size: 14, color: color),
        const SizedBox(width: AppDimensions.xxs),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: color)),
      ],
    );
  }
}

/// Dezente Projekt-Herkunft für projektübergreifende Listen: ein kleiner Chip
/// mit farbigem Punkt (Projektfarbe) und Projektname, damit erkennbar bleibt,
/// aus welchem Projekt eine Aufgabe stammt.
class _ProjectChip extends StatelessWidget {
  final Project project;

  const _ProjectChip({required this.project});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dotColor = project.color ?? theme.colorScheme.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppDimensions.xxs),
        Flexible(
          child: Text(
            project.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
