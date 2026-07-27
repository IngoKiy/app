import 'package:flutter/material.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';

/// Eintrag in einem [showPresetSheet]-Bottom-Sheet.
class PresetOption<T> {
  final IconData icon;
  final String label;

  /// Dezenter Hinweis rechts (z. B. „Mo. 09:00" bei „Nächste Woche").
  final String? trailing;

  /// Zeigt statt [trailing] ein Chevron („>") — für Untermenü-Einträge wie
  /// „Datum auswählen".
  final bool chevron;

  /// Destruktive Aktion (rot), z. B. „Liste löschen".
  final bool destructive;

  final T value;

  const PresetOption({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
    this.chevron = false,
    this.destructive = false,
  });
}

/// Preset-Sheet im Stil von Microsoft To Do: weißes Sheet mit Grabber,
/// zentriertem Titel und „Fertig" rechts, darunter Zeilen mit Icon + Label
/// (+ Hinweis rechts). Gibt den gewählten Wert zurück, `null` bei „Fertig"
/// oder Wegwischen.
Future<T?> showPresetSheet<T>(
  BuildContext context, {
  required String title,
  required List<PresetOption<T>> options,
}) {
  return showModalBottomSheet<T>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      final l10n = AppLocalizations.of(sheetContext);
      return SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        child: Text(l10n.done),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              for (final option in options)
                ListTile(
                  leading: Icon(
                    option.icon,
                    color: option.destructive ? theme.colorScheme.error : null,
                  ),
                  title: Text(
                    option.label,
                    style: option.destructive
                        ? TextStyle(color: theme.colorScheme.error)
                        : null,
                  ),
                  trailing: option.chevron
                      ? const Icon(Icons.chevron_right)
                      : (option.trailing != null
                            ? Text(
                                option.trailing!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              )
                            : null),
                  onTap: () => Navigator.of(sheetContext).pop(option.value),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  );
}
