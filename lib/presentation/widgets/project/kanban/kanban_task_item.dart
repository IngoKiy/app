import 'package:flutter/material.dart';
import 'package:vikunja_app/core/theming/app_colors.dart';
import 'package:vikunja_app/core/theming/color_utils.dart';
import 'package:vikunja_app/domain/entities/task.dart';
import 'package:vikunja_app/presentation/widgets/due_date_card.dart';
import 'package:vikunja_app/presentation/widgets/label_widget.dart';
import 'package:vikunja_app/presentation/widgets/project/kanban/priority_batch.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';

class TaskTile extends StatelessWidget {
  final Task task;

  const TaskTile({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final textColor = task.hasCustomColor
        ? contrastingTextColor(task.color!)
        : Theme.of(context).colorScheme.onSurface;

    return Card(
      color: task.hasCustomColor ? task.color : null,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.identifier,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: textColor),
                  ),
                ),
                if (task.done)
                  Badge(
                    label: Text(AppLocalizations.of(context).badgeDone),
                    backgroundColor: context.appColors.success,
                    textColor: context.appColors.onSuccess,
                  ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: textColor),
                  ),
                ),
                if (task.hasDueDate) DueDateCard(task.dueDate!),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (task.priority != null && task.priority! > 1)
                    PriorityBatch(task.priority!),
                ],
              ),
            ),
            if (task.labels.isNotEmpty)
              Wrap(
                spacing: 4,
                children: task.labels
                    .map((e) => LabelWidget(label: e))
                    .toList(),
              ),
            if (task.description.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.notes),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
