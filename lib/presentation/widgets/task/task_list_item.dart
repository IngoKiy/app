import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vikunja_app/core/di/database_provider.dart';
import 'package:vikunja_app/core/theming/dimensions.dart';
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
/// Wischen nach rechts hakt die Aufgabe ab (bzw. öffnet sie wieder), Wischen
/// nach links öffnet ein kleines Aktions-Sheet ("Mein Tag" / Löschen). Beide
/// Gesten schließen die Zeile nie endgültig — die Liste aktualisiert sich
/// über die DB-Streams von selbst.
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
    final inMyDay =
        ref.watch(taskInMyDayProvider(task.id)).value ?? false;

    return Dismissible(
      key: ValueKey('task-list-item-dismissible-${task.id}'),
      // Beide Richtungen führen eine Aktion aus, entfernen die Zeile aber nie
      // selbst — false lässt Dismissible in die Ausgangslage zurückfedern.
      confirmDismiss: (direction) => _confirmDismiss(direction, inMyDay),
      background: _buildCheckBackground(theme, task),
      secondaryBackground: _buildSwipeActionsBackground(theme, inMyDay),
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
                            onChanged: (newValue) =>
                                widget.onCheckedChanged(newValue),
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

  Future<bool> _confirmDismiss(
    DismissDirection direction,
    bool inMyDay,
  ) async {
    switch (direction) {
      case DismissDirection.startToEnd:
        // Rechts wischen: abhaken bzw. (bei bereits erledigten Aufgaben)
        // wieder öffnen.
        widget.onCheckedChanged(!widget.task.done);
        return false;
      case DismissDirection.endToStart:
        // Links wischen: kleines Aktions-Sheet ("Mein Tag" / Löschen).
        await _showSwipeActionsSheet(inMyDay);
        return false;
      default:
        return false;
    }
  }

  Widget _buildCheckBackground(ThemeData theme, Task task) {
    return Container(
      color: Colors.green,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(
        task.done ? Icons.replay : Icons.check_circle,
        color: Colors.white,
      ),
    );
  }

  Widget _buildSwipeActionsBackground(ThemeData theme, bool inMyDay) {
    return Row(
      children: [
        const Spacer(),
        Container(
          width: 72,
          color: theme.colorScheme.tertiaryContainer,
          alignment: Alignment.center,
          child: Icon(
            inMyDay ? Icons.wb_sunny : Icons.wb_sunny_outlined,
            color: theme.colorScheme.onTertiaryContainer,
          ),
        ),
        Container(
          width: 72,
          color: theme.colorScheme.errorContainer,
          alignment: Alignment.center,
          child: Icon(
            Icons.delete_outline,
            color: theme.colorScheme.onErrorContainer,
          ),
        ),
      ],
    );
  }

  /// Aktions-Sheet für die Links-Wisch-Geste: "Mein Tag" hinzufügen/entfernen
  /// und Löschen (mit Bestätigungs-Dialog).
  Future<void> _showSwipeActionsSheet(bool inMyDay) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  inMyDay ? Icons.wb_sunny : Icons.wb_sunny_outlined,
                ),
                title: Text(inMyDay ? l10n.myDayRemove : l10n.myDayAdd),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _toggleMyDay(inMyDay);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                title: Text(
                  l10n.delete,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _confirmAndDelete();
                },
              ),
            ],
          ),
        );
      },
    );
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.taskDeleteError)),
              );
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
      chips.add(_MyDayBadge(label: AppLocalizations.of(context).smartListMyDay));
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
