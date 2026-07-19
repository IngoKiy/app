import 'package:flutter/material.dart';
import 'package:vikunja_app/core/theming/dimensions.dart';
import 'package:vikunja_app/domain/entities/bucket.dart';
import 'package:vikunja_app/presentation/widgets/project/kanban/kanban_widget.dart';

class BucketFeedback extends StatelessWidget {
  final Bucket bucket;

  const BucketFeedback({super.key, required this.bucket});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      elevation: 12,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Container(
        width: KanbanWidgetState.bucketWidth,
        padding: const EdgeInsets.all(AppDimensions.sm),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(bucket.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: bucket.tasks
                    .take(3)
                    .map(
                      (t) => Chip(
                        label: Text(t.title),
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
