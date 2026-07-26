import 'package:flutter/material.dart';
import 'package:vikunja_app/core/theming/color_utils.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';

/// Bausteine für Listen-Seiten im Stil von Microsoft To Do: jede Liste
/// (Smart-List wie Projekt) bekommt eine Akzentfarbe, die AppBar und
/// Seitenhintergrund einfärbt; der Zurück-Button trägt dabei das Label
/// „Listen" statt eines nackten Pfeils, die Aufgaben-Karten bleiben hell.

/// AppBar für eine akzentfarbene Listen-Seite. Der eigentliche, große
/// Listentitel sitzt darunter im Content (siehe [accentListTitle]), die
/// AppBar selbst trägt nur Zurück-Navigation und Aktionen.
class AccentAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color accentColor;
  final List<Widget>? actions;

  const AccentAppBar({super.key, required this.accentColor, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final onAccent = contrastingTextColor(accentColor);
    final canPop = Navigator.of(context).canPop();
    final l10n = AppLocalizations.of(context);

    return AppBar(
      backgroundColor: accentColor,
      foregroundColor: onAccent,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: onAccent),
      actionsIconTheme: IconThemeData(color: onAccent),
      leadingWidth: canPop ? 112 : null,
      leading: canPop
          ? InkWell(
              onTap: () => Navigator.of(context).maybePop(),
              child: Row(
                children: [
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_back_ios_new, size: 18, color: onAccent),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      l10n.listsTitle,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: onAccent, fontSize: 16),
                    ),
                  ),
                ],
              ),
            )
          : null,
      actions: actions,
    );
  }
}

/// Großer Listentitel unter der AppBar, in der Kontrastfarbe der
/// Akzentfarbe (weiß auf dunkel, dunkel auf hell). [icon] ist optional
/// (Smart-Lists zeigen ihr Icon davor, Projekte keins).
Widget accentListTitle(
  BuildContext context,
  String title,
  Color accentColor, {
  IconData? icon,
}) {
  final onAccent = contrastingTextColor(accentColor);
  final textStyle = Theme.of(context).textTheme.headlineLarge?.copyWith(
    color: onAccent,
    fontWeight: FontWeight.bold,
  );
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
    child: Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: onAccent, size: 28),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Text(title, style: textStyle, overflow: TextOverflow.ellipsis),
        ),
      ],
    ),
  );
}

/// Hebt Aufgaben-Karten (die intern `surfaceContainerLow` nutzen) explizit
/// auf die reguläre `surface`-Fläche, damit sie auf der akzentfarbenen Seite
/// in beiden Theme-Modi klar vom Hintergrund abgesetzt bleiben.
Widget withCardSurface({required BuildContext context, required Widget child}) {
  final theme = Theme.of(context);
  return Theme(
    data: theme.copyWith(
      colorScheme: theme.colorScheme.copyWith(
        surfaceContainerLow: theme.colorScheme.surface,
      ),
    ),
    child: child,
  );
}
