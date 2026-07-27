import 'package:flutter/material.dart';
import 'package:vikunja_app/core/theming/color_utils.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';

/// Untere „+ Aufgabe hinzufügen"-Leiste im Stil von Microsoft To Do —
/// Ersatz für den schwebenden Button auf Aufgabenlisten-Seiten.
///
/// Mit [accentColor] tönt sich die Leiste wie im Vorbild als leicht
/// abgedunkelte Fläche der Listen-Akzentfarbe ein (Ausnahme laut
/// UI-Guidelines: Kontrast auf benutzergewählten Farben); ohne Akzent
/// bleibt sie auf `primaryContainer`.
class AddTaskBar extends StatelessWidget {
  final VoidCallback onTap;
  final Color? accentColor;

  const AddTaskBar({super.key, required this.onTap, this.accentColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = accentColor;
    final barColor = accent != null
        ? Color.alphaBlend(Colors.black.withValues(alpha: 0.15), accent)
        : theme.colorScheme.primaryContainer;
    final fg = accent != null
        ? contrastingTextColor(barColor)
        : theme.colorScheme.onPrimaryContainer;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
        child: Material(
          color: barColor,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(Icons.add, color: fg),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context).addTaskBar,
                    style: theme.textTheme.bodyLarge?.copyWith(color: fg),
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
