import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:vikunja_app/core/utils/date_extensions.dart';
import 'package:vikunja_app/core/utils/priority.dart';
import 'package:vikunja_app/core/utils/task_steps.dart';
import 'package:vikunja_app/domain/entities/label.dart';
import 'package:vikunja_app/domain/entities/task.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/widgets/label_widget.dart';
import 'package:vikunja_app/presentation/widgets/task/task_actions.dart';
import 'package:vikunja_app/presentation/widgets/task_assignees_section.dart';
import 'package:vikunja_app/presentation/widgets/task_attachments_section.dart';

/// Schnellvorschau einer Aufgabe (Long-Press) im Stil der Microsoft-To-Do-
/// Detailansicht: Titelzeile mit Erledigt-Kreis und Stern, Schritte,
/// aufgeräumte Icon-Zeilen (nur gesetzte Werte), Notiz, Footer mit
/// Erstelldatum. Bearbeitet wird auf der Edit-Seite ([onEdit]).
class TaskBottomSheet extends StatefulWidget {
  final Task task;
  final bool showInfo;
  final bool loading;
  final Function onEdit;

  const TaskBottomSheet({
    super.key,
    required this.task,
    required this.onEdit,
    this.loading = false,
    this.showInfo = false,
  });

  @override
  TaskBottomSheetState createState() => TaskBottomSheetState();
}

class TaskBottomSheetState extends State<TaskBottomSheet> {
  static const double _rowGap = 14.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final task = widget.task;
    final steps = parseSteps(task.description);
    final note = stripSteps(task.description);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.9,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 12, 20),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Titelzeile wie in To Do: Erledigt-Kreis, Titel, Stern.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Icon(
                      task.done
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: task.done
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      task.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        decoration: task.done
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                  Icon(
                    task.isFavorite ? Icons.star : Icons.star_border,
                    color: task.isFavorite
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  TaskActions(
                    task: task,
                    onEdit: () => widget.onEdit(),
                    variant: TaskActionsVariant.icons,
                    onBeforeAction: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: _rowGap),
              // Schritte (read-only) mit Fortschritt.
              if (steps.isNotEmpty) ...[
                Text(
                  l10n.stepsProgress(
                    steps.where((s) => s.done).length,
                    steps.length,
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                for (final step in steps)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Icon(
                          step.done
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 18,
                          color: step.done
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            step.text,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              decoration: step.done
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: step.done
                                  ? theme.colorScheme.onSurfaceVariant
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: _rowGap),
              ],
              if (task.labels.isNotEmpty) ...[
                Wrap(
                  spacing: 10,
                  children: task.labels
                      .map((Label label) => LabelWidget(label: label))
                      .toList(),
                ),
                const SizedBox(height: _rowGap),
              ],
              // Nur gesetzte Werte zeigen (To-Do-Stil).
              if (task.hasDueDate)
                _iconRow(
                  Icons.calendar_today_outlined,
                  task.dueDate!.toLocal().formatShort(),
                ),
              for (final reminder in task.reminderDates)
                _iconRow(
                  Icons.notifications_none,
                  reminder.reminder.toLocal().formatShort(),
                ),
              if (task.hasStartDate)
                _iconRow(
                  Icons.play_arrow_rounded,
                  task.startDate!.toLocal().formatShort(),
                ),
              if (task.hasEndDate)
                _iconRow(
                  Icons.stop_rounded,
                  task.endDate!.toLocal().formatShort(),
                ),
              if (task.priority != null && task.priority != 0)
                _iconRow(
                  Icons.flag_outlined,
                  priorityToString(l10n, task.priority),
                ),
              if (task.percentDone != null && task.percentDone! > 0)
                _iconRow(
                  Icons.percent,
                  '${(task.percentDone! * 100).toInt()}%',
                ),
              // Notiz (Beschreibung ohne Schritte).
              if (note.isNotEmpty) ...[
                const SizedBox(height: _rowGap),
                Padding(
                  padding: const EdgeInsets.only(left: 2.0),
                  child: HtmlWidget(note),
                ),
              ],
              const SizedBox(height: _rowGap),
              TaskAssigneesSection(task: task),
              const SizedBox(height: _rowGap),
              TaskAttachmentsSection(task: task),
              const SizedBox(height: _rowGap),
              Center(
                child: Text(
                  l10n.taskCreatedOn(task.created.toLocal().formatShort()),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconRow(IconData icon, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 14),
          Text(text, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
