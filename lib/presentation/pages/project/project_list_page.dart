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
import 'package:vikunja_app/presentation/pages/settings_page.dart';
import 'package:vikunja_app/presentation/pages/task/search_page.dart';
import 'package:vikunja_app/presentation/widgets/project/add_project_dialog.dart';
import 'package:vikunja_app/presentation/widgets/project/project_card.dart';
import 'package:vikunja_app/presentation/widgets/task/smart_list_section.dart';
import 'package:vikunja_app/presentation/widgets/user_avatar.dart';

class ProjectListPage extends ConsumerWidget {
  /// When set, tapping a project reports it to the parent (master-detail
  /// layout) instead of pushing a detail route.
  final ValueChanged<Project>? onProjectTap;
  final int? selectedProjectId;

  /// Listen-Übersicht im MS-To-Do-Stil: Smart-Lists über den Projekten und
  /// „Listen" als Titel (Home-Tab). Ohne Flag die klassische Projektliste.
  final bool showSmartLists;

  const ProjectListPage({
    super.key,
    this.onProjectTap,
    this.selectedProjectId,
    this.showSmartLists = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(projectsControllerProvider);
    // Offene-Aufgaben-Zähler best-effort; blockt die Liste nicht.
    final counts = ref.watch(openTaskCountsProvider).value ?? const {};

    return controller.when(
      data: (model) {
        // Echte Projekte und gespeicherte Filter (Pseudo-Projekte) trennen,
        // damit Filter einen eigenen Abschnitt bekommen.
        final projects = model.projects.where((p) => !p.isSavedFilter).toList();
        final filters = model.projects.where((p) => p.isSavedFilter).toList();

        final items = <Widget>[
          if (showSmartLists) const SmartListSection(),
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

        final content = NotificationListener<ScrollNotification>(
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
        );

        // Home-Tab (Listen-Übersicht) im MS-To-Do-Stil: eigener Kopf statt
        // AppBar (Avatar + Name + Suche) und unten fixiert "+ Neue Liste"
        // statt Plus-Button.
        if (showSmartLists) {
          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  const _HomeHeader(),
                  Expanded(child: content),
                ],
              ),
            ),
            bottomNavigationBar: _NewListBar(
              onTap: () => _createListInline(ref),
              onNewGroup: () => _addProjectDialog(ref),
            ),
          );
        }

        return Scaffold(
          body: content,
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

  /// „+ Neue Liste" wie in Microsoft To Do: sofort eine Liste
  /// „Unbenannte Liste [n]" anlegen und öffnen — benennen ist Umbenennen
  /// (Listenoptionen), kein vorgeschalteter Dialog.
  Future<void> _createListInline(WidgetRef ref) async {
    final l10n = AppLocalizations.of(ref.context);
    final messenger = ScaffoldMessenger.of(ref.context);
    final currentUser = ref.read(currentUserProvider);
    final model = ref.read(projectsControllerProvider).value;

    // Eindeutigen Namen bestimmen: „Unbenannte Liste", „… 1", „… 2", …
    final existing = <String>{
      if (model != null)
        for (final p in model.projects) p.title,
    };
    var name = l10n.untitledList;
    var i = 1;
    while (existing.contains(name)) {
      name = '${l10n.untitledList} $i';
      i++;
    }

    final result = await ref
        .read(projectsControllerProvider.notifier)
        .create(Project(title: name, owner: currentUser));
    if (!result.ok) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.projectCreateError)));
      return;
    }

    // Die neue Liste öffnen, sobald sie im Stream angekommen ist.
    for (var attempt = 0; attempt < 10; attempt++) {
      final projects = ref.read(projectsControllerProvider).value?.projects;
      final created = projects?.where((p) => p.title == name).toList();
      if (created != null && created.isNotEmpty) {
        if (!ref.context.mounted) return;
        _navigateToProject(ref, created.first);
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
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

/// Kopfzeile der Listen-Übersicht (Home-Tab) im MS-To-Do-Stil: Avatar +
/// Benutzername links, Such-Symbol rechts (öffnet die globale Suche).
class _HomeHeader extends ConsumerWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.md,
        AppDimensions.xs,
        AppDimensions.sm,
        AppDimensions.xs,
      ),
      child: Row(
        children: [
          if (user != null) ...[
            // Avatar + Name öffnen die Einstellungen (wie in To Do, wo das
            // Konto-/Einstellungs-Sheet hinter dem Profilkopf liegt).
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (_) => const SettingsPage(),
                  ),
                ),
                child: Row(
                  children: [
                    UserAvatar(user: user, radius: 18),
                    const SizedBox(width: AppDimensions.sm),
                    Expanded(
                      child: Text(
                        user.name.isNotEmpty ? user.name : user.username,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else
            const Spacer(),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: AppLocalizations.of(context).searchHint,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchPage()),
            ),
          ),
        ],
      ),
    );
  }
}

/// Unten fixierte Fußzeile der Listen-Übersicht im Stil von Microsoft To Do:
/// links „+ Neue Liste" als dezenter Textlink in Akzentfarbe, rechts das
/// Symbol für eine neue Gruppe.
class _NewListBar extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback? onNewGroup;

  const _NewListBar({required this.onTap, this.onNewGroup});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.add, color: accent),
                      const SizedBox(width: 12),
                      Text(
                        AppLocalizations.of(context).newListButton,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (onNewGroup != null)
              IconButton(
                tooltip: AppLocalizations.of(context).newListButton,
                icon: Icon(Icons.create_new_folder_outlined, color: accent),
                onPressed: onNewGroup,
              ),
          ],
        ),
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
        ProjectCard(
          project: project,
          openTaskCount: widget.counts[project.id],
          selected: project.id == widget.selectedProjectId,
          onTap: () => widget.onOpen(project),
          expandable: hasChildren,
          expanded: _expanded,
          onToggleExpand: () => setState(() => _expanded = !_expanded),
        ),
        // Kindlisten eingerückt mit vertikaler Führungslinie (wie To Do).
        if (hasChildren && _expanded)
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    width: 2,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
              padding: const EdgeInsets.only(left: AppDimensions.xs),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final child in project.subprojects)
                    _ProjectTreeTile(
                      project: child,
                      counts: widget.counts,
                      selectedProjectId: widget.selectedProjectId,
                      onOpen: widget.onOpen,
                      depth: widget.depth + 1,
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
