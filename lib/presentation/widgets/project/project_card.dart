import 'package:flutter/material.dart';
import 'package:vikunja_app/core/theming/dimensions.dart';
import 'package:vikunja_app/domain/entities/project.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';

/// Projekt-Zeile in der Listen-Übersicht im Stil von Microsoft To Do: flache
/// Zeile mit kleinem Listen-Icon in der Projektfarbe, Titel und dezentem
/// Zähler rechts — keine Karte, kein Ordner-Badge. Gruppen (Projekte mit
/// Unterprojekten) zeigen ein Ordner-Icon und einen Auf-/Zuklapp-Chevron
/// rechts; gespeicherte Filter ein Trichter-Icon.
///
/// Rein präsentational: Aufklappen/Einrücken von Subprojekten liegt beim
/// Aufrufer.
class ProjectCard extends StatelessWidget {
  final Project project;

  /// Anzahl offener Aufgaben; `null` oder 0 blendet den Zähler aus.
  final int? openTaskCount;

  /// Master-Detail-Auswahl hervorheben.
  final bool selected;

  /// Liste wurde mit mir geteilt (fremder Besitzer) → Personen-Symbol.
  final bool sharedWithMe;

  /// Gruppe: zeigt Ordner-Icon und Chevron rechts.
  final bool expandable;
  final bool expanded;
  final VoidCallback? onToggleExpand;

  final VoidCallback? onTap;

  const ProjectCard({
    super.key,
    required this.project,
    this.openTaskCount,
    this.selected = false,
    this.sharedWithMe = false,
    this.expandable = false,
    this.expanded = false,
    this.onToggleExpand,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isFilter = project.isSavedFilter;
    final accent = project.color ?? theme.colorScheme.primary;

    final icon = isFilter
        ? Icons.filter_alt_outlined
        : (expandable ? Icons.folder_outlined : Icons.format_list_bulleted);

    return Material(
      color: selected
          ? theme.colorScheme.secondaryContainer
          : Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.sm,
            vertical: 12,
          ),
          child: Row(
            children: [
              Icon(icon, size: 24, color: accent),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Text(
                  project.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: expandable ? FontWeight.w600 : null,
                  ),
                ),
              ),
              // Geteilte Liste (fremder Besitzer): Personen-Symbol wie To Do.
              if (sharedWithMe)
                Padding(
                  padding: const EdgeInsets.only(left: AppDimensions.xxs),
                  child: Icon(
                    Icons.people_outline,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              if (project.isFavourite)
                Padding(
                  padding: const EdgeInsets.only(left: AppDimensions.xxs),
                  child: Icon(Icons.star, size: 18, color: accent),
                ),
              if (openTaskCount != null && openTaskCount! > 0)
                Padding(
                  padding: const EdgeInsets.only(left: AppDimensions.xs),
                  child: Text(
                    '$openTaskCount',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              if (expandable)
                IconButton(
                  tooltip: expanded
                      ? l10n.collapseSubprojects
                      : l10n.expandSubprojects,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  icon: Icon(
                    expanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_right,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: onToggleExpand,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
