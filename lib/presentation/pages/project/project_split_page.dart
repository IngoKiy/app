import 'package:flutter/material.dart';
import 'package:vikunja_app/core/theming/dimensions.dart';
import 'package:vikunja_app/domain/entities/project.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/pages/project/project_detail_page.dart';
import 'package:vikunja_app/presentation/pages/project/project_list_page.dart';
import 'package:vikunja_app/presentation/widgets/ui/adaptive.dart';
import 'package:vikunja_app/presentation/widgets/ui/empty_state.dart';

/// Projects tab: plain list with push navigation on compact/medium
/// widths, master-detail layout on expanded widths.
class ProjectSplitPage extends StatefulWidget {
  const ProjectSplitPage({super.key});

  @override
  State<ProjectSplitPage> createState() => _ProjectSplitPageState();
}

class _ProjectSplitPageState extends State<ProjectSplitPage> {
  Project? _selectedProject;

  @override
  Widget build(BuildContext context) {
    if (!context.isExpanded) {
      return const ProjectListPage();
    }

    return Row(
      children: [
        SizedBox(
          width: AppDimensions.masterPaneWidth,
          child: ProjectListPage(
            onProjectTap: (project) =>
                setState(() => _selectedProject = project),
            selectedProjectId: _selectedProject?.id,
          ),
        ),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(
          child: _selectedProject == null
              ? EmptyState(
                  icon: Icons.splitscreen_outlined,
                  title: AppLocalizations.of(context).selectProjectPlaceholder,
                )
              : ProjectDetailPage(
                  key: ValueKey(_selectedProject!.id),
                  project: _selectedProject!,
                ),
        ),
      ],
    );
  }
}
