import 'package:flutter/material.dart';
import 'package:vikunja_app/core/utils/project_display_title.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vikunja_app/core/di/database_provider.dart';
import 'package:vikunja_app/core/utils/due_date_format.dart';
import 'package:vikunja_app/domain/entities/smart_list.dart';
import 'package:vikunja_app/domain/entities/task.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/manager/smart_list_providers.dart';

/// „Vorschläge"-Sheet von „Mein Tag" im Stil von Microsoft To Do
/// (Glühbirne): Abschnitte „Später" (heute/kommend fällig) und „Früher"
/// (überfällig); das blaue „+" fügt die Aufgabe dem heutigen Mein Tag hinzu.
Future<void> showSuggestionsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => const _SuggestionsSheet(),
  );
}

class _SuggestionsSheet extends ConsumerStatefulWidget {
  const _SuggestionsSheet();

  @override
  ConsumerState<_SuggestionsSheet> createState() => _SuggestionsSheetState();
}

class _SuggestionsSheetState extends ConsumerState<_SuggestionsSheet> {
  /// Bereits per „+" übernommene Aufgaben (verschwinden aus der Liste).
  final _added = <int>{};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final planned = ref.watch(smartListTasksProvider(SmartList.planned));

    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.3,
        builder: (context, scrollController) {
          final tasks = (planned.value ?? const <Task>[])
              .where((t) => !t.done && !_added.contains(t.id))
              .toList();
          final today = DateTime.now();
          final startOfToday = DateTime(today.year, today.month, today.day);
          bool isEarlier(Task t) {
            final due = t.dueDate;
            return due != null &&
                due.year > 1 &&
                DateTime(due.year, due.month, due.day).isBefore(startOfToday);
          }

          final earlier = tasks.where(isEarlier).take(25).toList();
          final later = tasks.where((t) => !isEarlier(t)).take(25).toList();

          return ListView(
            controller: scrollController,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Text(
                      l10n.suggestionsTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.done),
                    ),
                  ),
                ],
              ),
              if (later.isNotEmpty) ...[
                _SectionLabel(l10n.suggestionsLater),
                for (final task in later) _buildRow(task),
              ],
              if (earlier.isNotEmpty) ...[
                _SectionLabel(l10n.suggestionsEarlier),
                for (final task in earlier) _buildRow(task),
              ],
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRow(Task task) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final due = task.dueDate;
    final hasDue = due != null && due.year > 1;
    final overdue = hasDue && isOverdue(due);

    return ListTile(
      dense: true,
      leading: Icon(
        Icons.radio_button_unchecked,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(task.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (task.project != null)
            Flexible(
              child: Text(
                projectDisplayTitle(
                  AppLocalizations.of(context),
                  task.project!,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          if (task.project != null && hasDue) const Text(' • '),
          if (hasDue)
            Text(
              formatDueDate(l10n, l10n.localeName, due),
              style: theme.textTheme.bodySmall?.copyWith(
                color: overdue
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
      trailing: IconButton(
        icon: Icon(Icons.add, color: theme.colorScheme.primary),
        tooltip: l10n.myDayAdd,
        onPressed: () async {
          final dao = ref.read(tasksDaoProvider);
          await dao.addToMyDay(task.id, localDayKey(DateTime.now()));
          if (mounted) setState(() => _added.add(task.id));
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
