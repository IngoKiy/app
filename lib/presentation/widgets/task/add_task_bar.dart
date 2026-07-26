import 'package:flutter/material.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';

/// Untere „+ Aufgabe hinzufügen"-Leiste im Stil von Microsoft To Do —
/// Ersatz für den schwebenden Button auf Aufgabenlisten-Seiten.
class AddTaskBar extends StatelessWidget {
  final VoidCallback onTap;

  const AddTaskBar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
        child: Material(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              child: Row(
                children: [
                  Icon(Icons.add, color: theme.colorScheme.onPrimaryContainer),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context).addTaskBar,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
