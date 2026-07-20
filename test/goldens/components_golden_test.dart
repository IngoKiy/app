import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:vikunja_app/core/theming/app_colors.dart';
import 'package:vikunja_app/core/theming/app_theme.dart';
import 'package:vikunja_app/core/theming/theme.dart';
import 'package:vikunja_app/domain/entities/label.dart';
import 'package:vikunja_app/domain/entities/project.dart';
import 'package:vikunja_app/domain/entities/task.dart';
import 'package:vikunja_app/domain/entities/user.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/widgets/label_widget.dart';
import 'package:vikunja_app/presentation/widgets/project/kanban/kanban_task_item.dart';
import 'package:vikunja_app/presentation/widgets/project/kanban/priority_batch.dart';
import 'package:vikunja_app/presentation/widgets/project/project_card.dart';
import 'package:vikunja_app/presentation/widgets/ui/app_button.dart';
import 'package:vikunja_app/presentation/widgets/ui/app_card.dart';
import 'package:vikunja_app/presentation/widgets/ui/app_text_field.dart';
import 'package:vikunja_app/presentation/widgets/ui/empty_state.dart';

final _user = User(username: 'demo');

Task _task({bool done = false, Color? color, int? priority}) => Task(
  id: 1,
  identifier: '#42',
  title: 'Water the plants',
  description: 'Balcony and living room',
  done: done,
  color: color,
  priority: priority,
  labels: priority != null
      ? [
          Label(
            title: 'urgent',
            color: const Color(0xFFC62828),
            createdBy: _user,
          ),
        ]
      : const [],
  createdBy: _user,
  projectId: 1,
);

Widget _localized(Widget child) => Localizations(
  delegates: AppLocalizations.localizationsDelegates,
  locale: const Locale('en'),
  child: child,
);

GoldenTestGroup _componentScenarios() => GoldenTestGroup(
  scenarioConstraints: const BoxConstraints(maxWidth: 360),
  children: [
    GoldenTestScenario(
      name: 'buttons',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton(label: 'Filled', onPressed: () {}),
          AppButton(
            label: 'Tonal',
            variant: AppButtonVariant.tonal,
            onPressed: () {},
          ),
          AppButton(
            label: 'Outlined',
            variant: AppButtonVariant.outlined,
            onPressed: () {},
          ),
          AppButton(
            label: 'Text',
            variant: AppButtonVariant.text,
            onPressed: () {},
          ),
          AppButton(
            label: 'Danger',
            variant: AppButtonVariant.danger,
            onPressed: () {},
          ),
          const AppButton(label: 'Disabled', onPressed: null),
          AppButton(label: 'Loading', loading: true, onPressed: () {}),
        ],
      ),
    ),
    GoldenTestScenario(
      name: 'card',
      child: const AppCard(child: Text('Card content')),
    ),
    GoldenTestScenario(
      name: 'text field',
      child: const AppTextField(
        label: 'Server address',
        hint: 'https://try.vikunja.io',
        prefixIcon: Icons.dns_outlined,
      ),
    ),
    GoldenTestScenario(
      name: 'text field error',
      child: const AppTextField(
        label: 'Server address',
        errorText: 'Cannot reach server',
      ),
    ),
    GoldenTestScenario(
      name: 'empty state',
      child: const EmptyState(icon: Icons.list, title: 'No tasks yet'),
    ),
    GoldenTestScenario(
      name: 'project card',
      child: _localized(
        ProjectCard(
          project: Project(
            id: 1,
            title: 'Groceries',
            color: const Color(0xFF3F51B5),
            isFavourite: true,
          ),
          openTaskCount: 3,
        ),
      ),
    ),
    GoldenTestScenario(
      name: 'saved filter card',
      child: _localized(
        ProjectCard(project: Project(id: -2, title: 'Due soon')),
      ),
    ),
    GoldenTestScenario(
      name: 'kanban tile',
      child: _localized(TaskTile(task: _task(priority: 4))),
    ),
    GoldenTestScenario(
      name: 'kanban tile custom color',
      child: _localized(
        TaskTile(task: _task(done: true, color: const Color(0xFF7B1FA2))),
      ),
    ),
    GoldenTestScenario(
      name: 'labels and priority',
      child: _localized(
        Wrap(
          spacing: 8,
          children: [
            LabelWidget(
              label: Label(
                title: 'label',
                color: const Color(0xFF1A237E),
                createdBy: _user,
              ),
            ),
            const PriorityBatch(1),
            const PriorityBatch(2),
            const PriorityBatch(5),
          ],
        ),
      ),
    ),
  ],
);

void main() {
  goldenTest(
    'UI components (light)',
    fileName: 'components_light',
    pumpBeforeTest: pumpOnce,
    builder: _componentScenarios,
  );

  AlchemistConfig.runWithConfig(
    config: AlchemistConfig.current().merge(
      AlchemistConfig(
        theme: buildAppTheme(
          colorScheme: MaterialTheme.darkScheme(),
          appColors: AppColors.dark,
        ),
      ),
    ),
    run: () => goldenTest(
      'UI components (dark)',
      fileName: 'components_dark',
      pumpBeforeTest: pumpOnce,
      builder: _componentScenarios,
    ),
  );
}
