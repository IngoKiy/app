import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vikunja_app/core/di/database_provider.dart';
import 'package:vikunja_app/data/local/row_mappers.dart';
import 'package:vikunja_app/domain/entities/project.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';

/// Ein Projekt in der Auswahl, inkl. Verschachtelungstiefe für die Einrückung
/// von Unterprojekten.
class ProjectPickerItem {
  const ProjectPickerItem(this.project, this.depth);

  final Project project;
  final int depth;
}

/// Reaktive Quelle für die Projektauswahl: nur echte Projekte (id > 0), also
/// KEINE gespeicherten Filter (id < -1), nicht das Favoriten-Pseudo (-1) und
/// keine offline erzeugten Temp-Projekte (negative IDs). Unterprojekte werden
/// hierarchisch unter ihr Elternprojekt einsortiert (mit [ProjectPickerItem.depth]).
final projectPickerItemsProvider =
    StreamProvider.autoDispose<List<ProjectPickerItem>>((ref) {
      return ref.watch(projectsDaoProvider).watchProjects().map((rows) {
        final projects = rows
            .map(projectFromRow)
            .where((p) => p.id > 0)
            .toList();
        return _flatten(projects);
      });
    });

/// Bringt die Projekte in Baum-Reihenfolge (Eltern gefolgt von ihren Kindern)
/// und vergibt je Ebene eine Tiefe. Projekte, deren Elternteil nicht in der
/// echten Projektliste steckt (z.B. Elternteil ist ein Filter), landen als
/// Wurzel.
List<ProjectPickerItem> _flatten(List<Project> all) {
  final childrenByParent = <int, List<Project>>{};
  final ids = all.map((p) => p.id).toSet();
  for (final p in all) {
    final parent = ids.contains(p.parentProjectId) ? p.parentProjectId : 0;
    childrenByParent.putIfAbsent(parent, () => []).add(p);
  }

  final result = <ProjectPickerItem>[];
  void visit(int parentId, int depth) {
    for (final child in childrenByParent[parentId] ?? const <Project>[]) {
      result.add(ProjectPickerItem(child, depth));
      visit(child.id, depth + 1);
    }
  }

  visit(0, 0);
  return result;
}

/// Formularfeld, das das aktuell gewählte Projekt (Farbpunkt + Name) anzeigt und
/// bei Tippen die [ProjectPickerDialog]-Auswahl öffnet. Offline-fähig: die Liste
/// kommt reaktiv aus der lokalen DB.
class ProjectPickerField extends ConsumerWidget {
  const ProjectPickerField({
    super.key,
    required this.selectedProjectId,
    required this.onChanged,
    this.label,
  });

  /// Aktuell gewähltes Projekt (0/null = keins gewählt).
  final int? selectedProjectId;
  final ValueChanged<int> onChanged;

  /// Optionales Feld-Label; Standard ist "Projekt".
  final String? label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final itemsAsync = ref.watch(projectPickerItemsProvider);
    final items = itemsAsync.valueOrNull ?? const <ProjectPickerItem>[];

    final selected = items
        .where((i) => i.project.id == selectedProjectId)
        .map((i) => i.project)
        .firstOrNull;

    final accent = selected?.color ?? theme.colorScheme.primary;

    return InkWell(
      onTap: () async {
        final result = await showDialog<int>(
          context: context,
          builder: (_) => ProjectPickerDialog(selectedProjectId: selectedProjectId),
        );
        if (result != null) onChanged(result);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(
              Icons.folder_outlined,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label ?? l10n.project,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.hintColor,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (selected != null) ...[
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          selected?.title ?? l10n.selectProject,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

/// Auswahldialog: durchsuchbare Liste echter Projekte (Unterprojekte eingerückt).
/// Gibt die gewählte Projekt-ID via [Navigator.pop] zurück.
class ProjectPickerDialog extends ConsumerStatefulWidget {
  const ProjectPickerDialog({super.key, this.selectedProjectId});

  final int? selectedProjectId;

  @override
  ConsumerState<ProjectPickerDialog> createState() =>
      _ProjectPickerDialogState();
}

class _ProjectPickerDialogState extends ConsumerState<ProjectPickerDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final itemsAsync = ref.watch(projectPickerItemsProvider);
    final allItems = itemsAsync.valueOrNull ?? const <ProjectPickerItem>[];

    final query = _query.trim().toLowerCase();
    // Bei aktiver Suche die Einrückung fallen lassen (flache Trefferliste).
    final items = query.isEmpty
        ? allItems
        : allItems
              .where((i) => i.project.title.toLowerCase().contains(query))
              .map((i) => ProjectPickerItem(i.project, 0))
              .toList();

    return AlertDialog(
      title: Text(l10n.selectProject),
      content: SizedBox(
        width: double.maxFinite,
        height: 360,
        child: Column(
          children: [
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: l10n.selectProject,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: allItems.isEmpty
                  ? Center(child: Text(l10n.noProjectsAvailable))
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final project = item.project;
                        final accent =
                            project.color ?? theme.colorScheme.primary;
                        return ListTile(
                          contentPadding: EdgeInsets.only(
                            left: 16.0 + item.depth * 20.0,
                            right: 16.0,
                          ),
                          leading: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          title: Text(
                            project.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          selected: project.id == widget.selectedProjectId,
                          trailing: project.id == widget.selectedProjectId
                              ? const Icon(Icons.check)
                              : null,
                          onTap: () => Navigator.of(context).pop(project.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}
