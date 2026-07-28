import 'package:flutter/material.dart';
import 'package:vikunja_app/core/utils/due_date_format.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';

/// Fälligkeit in der Aufgaben-Metazeile im Stil von Microsoft To Do:
/// kleines Kalender-Icon + Text („Gestern", „Heute", „Mi. 22. Juli"),
/// rot bei Überfälligkeit, sonst dezent — ohne Badge-Hintergrund.
class DueDateCard extends StatelessWidget {
  final DateTime dueDate;

  const DueDateCard(this.dueDate, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final overdue = isOverdue(dueDate);
    final color = overdue
        ? theme.colorScheme.error
        : theme.colorScheme.onSurfaceVariant;
    final label = formatDueDate(l10n, l10n.localeName, dueDate);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.calendar_today_outlined, size: 12, color: color),
        const SizedBox(width: 3),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: color)),
      ],
    );
  }
}
