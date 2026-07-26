import 'package:flutter/material.dart';
import 'package:vikunja_app/core/theming/dimensions.dart';
import 'package:vikunja_app/domain/entities/project.dart';
import 'package:vikunja_app/domain/entities/task.dart';
import 'package:vikunja_app/domain/entities/user.dart';
import 'package:vikunja_app/presentation/widgets/due_date_card.dart';
import 'package:vikunja_app/presentation/widgets/project/kanban/priority_batch.dart';
import 'package:vikunja_app/presentation/widgets/task/round_checkbox.dart';
import 'package:vikunja_app/presentation/widgets/user_avatar.dart';

/// Aufgabenzeile im Stil von Microsoft To Do: Karte mit runder Checkbox,
/// Titel + Metazeile (Projekt, Fälligkeit, Priorität) und Stern-Toggle für
/// Favoriten ("Wichtig"). Eine eigene Aufgabenfarbe erscheint als schmaler
/// Balken am linken Kartenrand.
class TaskListItem extends StatefulWidget {
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
  TaskListItemState createState() => TaskListItemState();
}

class TaskListItemState extends State<TaskListItem> {
  TaskListItemState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final task = widget.task;

    return Padding(
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
                        Expanded(child: _buildContent(task, theme)),
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
    );
  }

  Widget _buildContent(Task task, ThemeData theme) {
    final subtitle = _buildTaskSubtitle(task, context);
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

  Widget? _buildTaskSubtitle(Task task, BuildContext context) {
    final chips = <Widget>[];

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
