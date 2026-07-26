import 'package:flutter/material.dart';
import 'package:vikunja_app/domain/entities/task.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/pages/task/task_comments_page.dart';

enum TaskActionsVariant { menu, icons }

enum _TaskAction { details, comments, edit }

class TaskActions extends StatelessWidget {
  final Task task;
  final VoidCallback onEdit;
  final TaskActionsVariant variant;
  final VoidCallback? onBeforeAction;

  /// Öffnet die Schnellvorschau (Bottom-Sheet). Nur wenn gesetzt, erscheint
  /// der "Details"-Menüpunkt — im Sheet selbst bleibt er weg.
  final VoidCallback? onShowDetails;

  const TaskActions({
    super.key,
    required this.task,
    required this.onEdit,
    required this.variant,
    this.onBeforeAction,
    this.onShowDetails,
  });

  void _openComments(BuildContext context) {
    onBeforeAction?.call();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TaskCommentsPage(taskId: task.id, taskTitle: task.title),
      ),
    );
  }

  void _edit() {
    onBeforeAction?.call();
    onEdit();
  }

  void _showDetails() {
    onBeforeAction?.call();
    onShowDetails?.call();
  }

  void _handleMenuAction(BuildContext context, _TaskAction action) {
    switch (action) {
      case _TaskAction.details:
        _showDetails();
        break;
      case _TaskAction.comments:
        _openComments(context);
        break;
      case _TaskAction.edit:
        _edit();
        break;
    }
  }

  List<PopupMenuEntry<_TaskAction>> _menuItems(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return [
      if (onShowDetails != null)
        PopupMenuItem(
          value: _TaskAction.details,
          child: Text(localizations.taskDetails),
        ),
      PopupMenuItem(
        value: _TaskAction.comments,
        child: Text(localizations.comments),
      ),
      PopupMenuItem(value: _TaskAction.edit, child: Text(localizations.edit)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case TaskActionsVariant.menu:
        return PopupMenuButton<_TaskAction>(
          icon: const Icon(Icons.more_vert),
          onSelected: (action) => _handleMenuAction(context, action),
          itemBuilder: _menuItems,
        );
      case TaskActionsVariant.icons:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _openComments(context),
              icon: const Icon(Icons.comment),
              tooltip: AppLocalizations.of(context).comments,
            ),
            IconButton(onPressed: _edit, icon: const Icon(Icons.edit)),
          ],
        );
    }
  }
}
