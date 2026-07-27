import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vikunja_app/core/di/database_provider.dart';
import 'package:vikunja_app/core/theming/color_utils.dart';
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

/// Sortier-Chip im Stil von Microsoft To Do: linksbündige, leicht
/// abgedunkelte Pille auf der Akzentfläche („Sortiert nach X" + Chevron),
/// daneben ein separates ×, das die gespeicherte Sortierung entfernt.
/// [listKey] ist der KeyValue-Schlüssel der Liste (`smart/<name>` bzw.
/// `project/<id>`).
///
/// Ist [allowManualOrder] gesetzt, kehrt × zur manuellen
/// Positionsreihenfolge zurück (Projektlisten); Smart-Lists fallen auf ihre
/// Standard-Sortierung (Fälligkeit) zurück.
class SortChip extends ConsumerWidget {
  final String listKey;
  final bool allowManualOrder;

  /// Akzentfarbe der Listen-Seite; bestimmt Pillen-Hintergrund und
  /// Kontrastfarbe. Ohne Akzent werden neutrale Theme-Flächen genutzt.
  final Color? accentColor;

  const SortChip({
    super.key,
    required this.listKey,
    this.allowManualOrder = false,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
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

    final accent = accentColor;
    // Auf benutzergewählten Akzentflächen: Pille = leicht abgedunkelte
    // Akzentfarbe, Text in Kontrastfarbe (Ausnahme laut UI-Guidelines).
    final pillColor = accent != null
        ? Color.alphaBlend(Colors.black.withValues(alpha: 0.10), accent)
        : theme.colorScheme.surfaceContainerHigh;
    final fg = accent != null
        ? contrastingTextColor(accent)
        : theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          PopupMenuButton<TaskSortMode?>(
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
            child: _Pill(
              color: pillColor,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.keyboard_arrow_down, size: 18, color: fg),
                ],
              ),
            ),
          ),
          if (storedMode != null) ...[
            const SizedBox(width: 8),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () =>
                  clearListSortMode(ref.read(keyValueDaoProvider), listKey),
              child: _Pill(
                color: pillColor,
                child: Icon(Icons.close, size: 16, color: fg),
              ),
            ),
          ],
          const Spacer(),
        ],
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

class _Pill extends StatelessWidget {
  final Color color;
  final Widget child;

  const _Pill({required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}
