import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/pages/task/comment_edit_page.dart';
import 'package:vikunja_app/presentation/widgets/task/task_comments.dart';
import 'package:vikunja_app/presentation/widgets/ui/constrained_page.dart';

/// Kommentare einer Aufgabe im Stil von Microsoft To Do: weiße Seite,
/// Aufgabentitel in der Kopfzeile, „+" legt einen Kommentar an.
class TaskCommentsPage extends StatelessWidget {
  final int taskId;
  final String taskTitle;

  const TaskCommentsPage({
    super.key,
    required this.taskId,
    required this.taskTitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: theme.brightness == Brightness.light
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.comments,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              taskTitle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n.addCommentTooltip,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CommentEditPage(taskId: taskId),
              ),
            ),
          ),
        ],
      ),
      body: ConstrainedPage(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TaskComments(taskId: taskId, showHeader: false),
        ),
      ),
    );
  }
}
