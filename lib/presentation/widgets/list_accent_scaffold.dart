import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  /// Vordergrund-Übersteuerung für helle Akzentflächen (z. B. dunkles Teal
  /// auf Mint bei „Geplant"); Standard ist die Kontrastfarbe.
  final Color? foregroundColor;

  /// Listentitel, der beim Scrollen zentriert in der Navbar erscheint
  /// (wie in To Do, wo der Großtitel in die Kopfzeile kollabiert).
  final String? title;

  /// Steuert die Einblendung von [title].
  final bool showTitle;

  /// Übersteuert die Balkenfarbe (z. B. transparent über Foto-Hintergrund);
  /// [accentColor] bestimmt weiterhin die Kontrastfarben.
  final Color? barColor;

  const AccentAppBar({
    super.key,
    required this.accentColor,
    this.actions,
    this.foregroundColor,
    this.title,
    this.showTitle = false,
    this.barColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final onAccent = foregroundColor ?? contrastingTextColor(accentColor);
    final canPop = Navigator.of(context).canPop();
    final l10n = AppLocalizations.of(context);

    return AppBar(
      backgroundColor: barColor ?? accentColor,
      foregroundColor: onAccent,
      elevation: 0,
      scrolledUnderElevation: 0,
      // Statusleisten-Kontrast explizit aus der Vordergrundfarbe ableiten:
      // weiße Inhalte auf dunkler Fläche → helle Statusleiste, sonst dunkle.
      systemOverlayStyle: onAccent.computeLuminance() > 0.5
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      centerTitle: true,
      title: title != null
          ? AnimatedOpacity(
              opacity: showTitle ? 1 : 0,
              duration: const Duration(milliseconds: 150),
              child: Text(
                title!,
                style: TextStyle(
                  color: onAccent,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
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
  Color? foregroundColor,
  String? subtitle,
}) {
  final onAccent = foregroundColor ?? contrastingTextColor(accentColor);
  final textStyle = Theme.of(context).textTheme.headlineLarge?.copyWith(
    color: onAccent,
    fontWeight: FontWeight.bold,
  );
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: onAccent, size: 28),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                title,
                style: textStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        // Untertitel (z. B. das Datum unter „Mein Tag" wie in To Do).
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              subtitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: onAccent.withValues(alpha: 0.9),
              ),
            ),
          ),
      ],
    ),
  );
}

/// Leerer Zustand einer Listen-Seite im Stil von Microsoft To Do: dezente
/// horizontale Linien (Notizzeilen-Optik) statt Illustration.
class NotebookLinesEmptyState extends StatelessWidget {
  final Color accentColor;

  /// Vordergrund-Übersteuerung (helle Flächen); Standard: Kontrastfarbe.
  final Color? foregroundColor;

  const NotebookLinesEmptyState({
    super.key,
    required this.accentColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final line = (foregroundColor ?? contrastingTextColor(accentColor))
        .withValues(alpha: 0.15);
    return CustomPaint(
      painter: _NotebookLinesPainter(line),
      child: const SizedBox.expand(),
    );
  }
}

class _NotebookLinesPainter extends CustomPainter {
  final Color color;

  _NotebookLinesPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const spacing = 56.0;
    for (var y = spacing; y < size.height; y += spacing) {
      canvas.drawLine(Offset(16, y), Offset(size.width - 16, y), paint);
    }
  }

  @override
  bool shouldRepaint(_NotebookLinesPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Hebt Aufgaben-Karten (die intern `surfaceContainerLow` nutzen) explizit
/// auf die reguläre `surface`-Fläche, damit sie auf der akzentfarbenen Seite
/// in beiden Theme-Modi klar vom Hintergrund abgesetzt bleiben.
///
/// Mit [accent] färben sich zusätzlich Akzent-Elemente auf den Karten
/// (gefüllter Wichtig-Stern, Erledigt-Kreis) in der Listenfarbe — wie in
/// Microsoft To Do, wo der Stern immer die Akzentfarbe der Liste trägt.
Widget withCardSurface({
  required BuildContext context,
  required Widget child,
  Color? accent,
}) {
  final theme = Theme.of(context);
  return Theme(
    data: theme.copyWith(
      colorScheme: theme.colorScheme.copyWith(
        surfaceContainerLow: theme.colorScheme.surface,
        primary: accent ?? theme.colorScheme.primary,
      ),
    ),
    child: child,
  );
}
