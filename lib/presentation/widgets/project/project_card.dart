import 'package:flutter/material.dart';
import 'package:vikunja_app/core/theming/color_utils.dart';
import 'package:vikunja_app/core/theming/dimensions.dart';
import 'package:vikunja_app/domain/entities/project.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/widgets/ui/app_card.dart';

/// Projekt als Ordner-Karte: farbiges Ordner-Icon (Projektfarbe), Titel,
/// optionaler Untertitel mit der Anzahl offener Aufgaben, Favoriten-Stern und
/// eine „öffnen"-Affordanz (Chevron). Gespeicherte Filter werden über
/// [Project.isSavedFilter] als solche gekennzeichnet (Trichter-Icon).
///
/// Rein präsentational: Aufklappen/Einrücken von Subprojekten liegt beim
/// Aufrufer ([leading] nimmt z.B. einen Expand-Button auf).
class ProjectCard extends StatelessWidget {
  final Project project;

  /// Anzahl offener Aufgaben; `null` blendet den Untertitel aus.
  final int? openTaskCount;

  /// Master-Detail-Auswahl hervorheben.
  final bool selected;

  /// Führendes Widget vor dem Ordner-Icon (z.B. Expand-Button bei Subprojekten).
  final Widget? leading;

  final VoidCallback? onTap;

  const ProjectCard({
    super.key,
    required this.project,
    this.openTaskCount,
    this.selected = false,
    this.leading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isFilter = project.isSavedFilter;
    final accent = project.color ?? theme.colorScheme.primary;

    final subtitle = isFilter
        ? l10n.savedFilterLabel
        : (openTaskCount != null && openTaskCount! > 0
              ? l10n.openTasksCount(openTaskCount!)
              : null);

    return AppCard(
      color: selected ? theme.colorScheme.secondaryContainer : null,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: AppDimensions.xs,
      ),
      onTap: onTap,
      child: Row(
        children: [
          ?leading,
          _iconBadge(accent, isFilter),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  project.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          if (project.isFavourite)
            Padding(
              padding: const EdgeInsets.only(left: AppDimensions.xxs),
              child: Icon(Icons.star, size: 18, color: accent),
            ),
          const SizedBox(width: AppDimensions.xxs),
          Icon(
            Icons.chevron_right,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  /// Farbiges, abgerundetes Quadrat mit Ordner- bzw. Filter-Icon. Die
  /// Icon-Farbe wird gegen die Projektfarbe auf Lesbarkeit gewählt.
  Widget _iconBadge(Color accent, bool isFilter) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Icon(
        isFilter ? Icons.filter_alt_outlined : Icons.folder_rounded,
        size: 22,
        color: contrastingTextColor(accent),
      ),
    );
  }
}
