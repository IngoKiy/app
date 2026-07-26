import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vikunja_app/core/di/database_provider.dart';
import 'package:vikunja_app/domain/entities/task_sort.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/manager/smart_list_providers.dart';

/// Menschlich lesbares Label eines [TaskSortMode].
String sortModeLabel(AppLocalizations l10n, TaskSortMode mode) {
  switch (mode) {
    case TaskSortMode.dueDate:
      return l10n.sortDueDate;
    case TaskSortMode.importance:
      return l10n.sortImportance;
    case TaskSortMode.alphabetical:
      return l10n.sortAlphabetical;
    case TaskSortMode.created:
      return l10n.sortCreated;
  }
}

/// Chip unter dem Listentitel: zeigt den aktiven Sortier-Modus und öffnet
/// per Tipp ein Auswahlmenü (Fälligkeit, Wichtigkeit, Alphabetisch,
/// Erstellt). [listKey] ist der KeyValue-Schlüssel der Liste (`smart/<name>`
/// bzw. `project/<id>`).
///
/// Ist [allowManualOrder] gesetzt, bietet das Menü zusätzlich einen Eintrag,
/// der die Sortierung wieder löscht (Projektlisten: zurück zur manuellen
/// Positionsreihenfolge per Drag). Ohne aktiven Modus zeigt der Chip dann nur
/// „Sortieren" ohne Modus-Namen.
class SortChip extends ConsumerWidget {
  final String listKey;
  final bool allowManualOrder;
  final Color? foregroundColor;

  const SortChip({
    super.key,
    required this.listKey,
    this.allowManualOrder = false,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final storedMode = ref.watch(listSortModeProvider(listKey)).value;
    // Smart-Lists wenden immer einen Modus an (Standard: Fälligkeit);
    // Projektlisten bleiben ohne gespeicherten Modus bei der manuellen
    // Reihenfolge.
    final effectiveMode = allowManualOrder
        ? storedMode
        : (storedMode ?? TaskSortMode.dueDate);
    final label = effectiveMode == null
        ? l10n.sortByLabel
        : l10n.sortedByLabel(sortModeLabel(l10n, effectiveMode));
    final color =
        foregroundColor ?? Theme.of(context).colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: PopupMenuButton<TaskSortMode?>(
        tooltip: l10n.sortByLabel,
        onSelected: (selected) => _onSelected(ref, selected),
        itemBuilder: (context) => [
          if (allowManualOrder)
            PopupMenuItem<TaskSortMode?>(
              value: null,
              child: Text(l10n.sortByLabel),
            ),
          for (final mode in TaskSortMode.values)
            PopupMenuItem<TaskSortMode?>(
              value: mode,
              child: Text(sortModeLabel(l10n, mode)),
            ),
        ],
        child: Chip(
          avatar: Icon(Icons.sort, size: 18, color: color),
          label: Text(label, style: TextStyle(color: color)),
          visualDensity: VisualDensity.compact,
          side: BorderSide(color: color.withValues(alpha: 0.4)),
        ),
      ),
    );
  }

  void _onSelected(WidgetRef ref, TaskSortMode? selected) {
    final kv = ref.read(keyValueDaoProvider);
    if (selected == null) {
      clearListSortMode(kv, listKey);
    } else {
      setListSortMode(kv, listKey, selected);
    }
  }
}
