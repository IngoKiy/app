import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:vikunja_app/core/di/network_provider.dart';
import 'package:vikunja_app/core/theming/dimensions.dart';
import 'package:vikunja_app/domain/entities/project.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/manager/projects_controller.dart';
import 'package:vikunja_app/presentation/pages/error_widget.dart';
import 'package:vikunja_app/presentation/pages/loading_widget.dart';
import 'package:vikunja_app/presentation/pages/project/project_detail_page.dart';
import 'package:vikunja_app/presentation/widgets/project/add_project_dialog.dart';
import 'package:vikunja_app/presentation/widgets/project/project_card.dart';

class ProjectListPage extends ConsumerWidget {
  /// When set, tapping a project reports it to the parent (master-detail
  /// layout) instead of pushing a detail route.
  final ValueChanged<Project>? onProjectTap;
  final int? selectedProjectId;

  const ProjectListPage({super.key, this.onProjectTap, this.selectedProjectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(projectsControllerProvider);
    // Offene-Aufgaben-Zähler best-effort; blockt die Liste nicht.
    final counts = ref.watch(openTaskCountsProvider).value ?? const {};

    return controller.when(
      data: (model) {
        // Echte Projekte und gespeicherte Filter (Pseudo-Projekte) trennen,
        // damit Filter einen eigenen Abschnitt bekommen.
        final projects = model.projects
            .where((p) => !p.isSavedFilter)
            .toList();
        final filters = model.projects.where((p) => p.isSavedFilter).toList();

        final items = <Widget>[
          for (final p in projects)
            _ProjectTreeTile(
              project: p,
              counts: counts,
              selectedProjectId: selectedProjectId,
              onOpen: (project) => _navigateToProject(ref, project),
            ),
          if (filters.isNotEmpty) ...[
            _SectionHeader(AppLocalizations.of(context).savedFiltersSection),
            for (final f in filters)
              _ProjectTreeTile(
                project: f,
                counts: counts,
                selectedProjectId: selectedProjectId,
                onOpen: (project) => _navigateToProject(ref, project),
              ),
          ],
          if (model.isLoadingNextPage)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
              child: Center(
                child: SpinKitThreeBounce(
                  color: Theme.of(context).primaryColor,
                  size: 16,
                ),
              ),
            ),
        ];

        return Scaffold(
          body: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels ==
                  scrollInfo.metrics.maxScrollExtent) {
                ref.read(projectsControllerProvider.notifier).loadNextPage();
              }
              return false;
            },
            child: RefreshIndicator(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.xs,
                  vertical: AppDimensions.xs,
                ),
                children: items,
              ),
              onRefresh: () =>
                  ref.read(projectsControllerProvider.notifier).reload(),
            ),
          ),
          appBar: AppBar(
            title: Text(AppLocalizations.of(context).projectsTitle),
            actions: [
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => _addProjectDialog(ref),
              ),
            ],
          ),
        );
      },
      error: (err, _) => VikunjaErrorWidget(
        error: err,
        onRetry: () => ref.invalidate(projectsControllerProvider),
      ),
      loading: () => const LoadingWidget(),
    );
  }

  void _addProjectDialog(WidgetRef ref) {
    showDialog(
      context: ref.context,
      builder: (_) => AddProjectDialog(onAdd: (name) => _addProject(name, ref)),
    );
  }

  Future<void> _addProject(String name, WidgetRef ref) async {
    final currentUser = ref.read(currentUserProvider);
    final messenger = ScaffoldMessenger.of(ref.context);
    final l10n = AppLocalizations.of(ref.context);

    final result = await ref
        .read(projectsControllerProvider.notifier)
        .create(Project(title: name, owner: currentUser));

    // Server-Ablehnung (Rollback der optimistischen Zeile) sichtbar melden.
    if (!result.ok) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.projectCreateError)));
    }
  }

  void _navigateToProject(WidgetRef ref, Project project) async {
    if (onProjectTap != null) {
      onProjectTap!(project);
      return;
    }
    Navigator.push(
      ref.context,
      MaterialPageRoute(
        builder: (context) {
          return ProjectDetailPage(
            key: Key(project.id.toString()),
            project: project,
          );
        },
      ),
    );
  }
}

/// Abschnitts-Überschrift (z.B. „Filter") zwischen den Karten-Gruppen.
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.sm,
        AppDimensions.md,
        AppDimensions.sm,
        AppDimensions.xs,
      ),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Ordner-Karte eines Projekts samt (optional aufklappbaren) Subprojekten. Die
/// Verschachtelung wird durch Einrückung und einen Expand-Button sichtbar.
class _ProjectTreeTile extends StatefulWidget {
  final Project project;
  final Map<int, int> counts;
  final int? selectedProjectId;
  final ValueChanged<Project> onOpen;
  final int depth;

  const _ProjectTreeTile({
    required this.project,
    required this.counts,
    required this.selectedProjectId,
    required this.onOpen,
    this.depth = 0,
  });

  @override
  State<_ProjectTreeTile> createState() => _ProjectTreeTileState();
}

class _ProjectTreeTileState extends State<_ProjectTreeTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    final hasChildren = project.subprojects.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: widget.depth * AppDimensions.md,
            top: AppDimensions.xxs,
            bottom: AppDimensions.xxs,
          ),
          child: ProjectCard(
            project: project,
            openTaskCount: widget.counts[project.id],
            selected: project.id == widget.selectedProjectId,
            onTap: () => widget.onOpen(project),
            leading: hasChildren
                ? IconButton(
                    tooltip: _expanded
                        ? AppLocalizations.of(context).collapseSubprojects
                        : AppLocalizations.of(context).expandSubprojects,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    icon: Icon(
                      _expanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_right,
                    ),
                    onPressed: () => setState(() => _expanded = !_expanded),
                  )
                : null,
          ),
        ),
        if (hasChildren && _expanded)
          for (final child in project.subprojects)
            _ProjectTreeTile(
              project: child,
              counts: widget.counts,
              selectedProjectId: widget.selectedProjectId,
              onOpen: widget.onOpen,
              depth: widget.depth + 1,
            ),
      ],
    );
  }
}
