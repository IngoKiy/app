import 'package:flutter/material.dart';
import 'package:vikunja_app/core/theming/dimensions.dart';
import 'package:vikunja_app/domain/entities/label.dart';
import 'package:vikunja_app/domain/entities/task.dart';
import 'package:vikunja_app/domain/entities/user.dart';
import 'package:vikunja_app/presentation/widgets/due_date_card.dart';
import 'package:vikunja_app/presentation/widgets/label_widget.dart';
import 'package:vikunja_app/presentation/widgets/project/kanban/kanban_task_item.dart';
import 'package:vikunja_app/presentation/widgets/project/kanban/priority_batch.dart';
import 'package:vikunja_app/presentation/widgets/ui/app_button.dart';
import 'package:vikunja_app/presentation/widgets/ui/app_card.dart';
import 'package:vikunja_app/presentation/widgets/ui/app_text_field.dart';
import 'package:vikunja_app/presentation/widgets/ui/confirmation_dialog.dart';
import 'package:vikunja_app/presentation/widgets/ui/empty_state.dart';
import 'package:widgetbook/widgetbook.dart';

final _demoUser = User(username: 'demo');

Task _demoTask({
  bool done = false,
  Color? color,
  int? priority,
  List<Label> labels = const [],
  DateTime? dueDate,
}) => Task(
  id: 1,
  identifier: '#42',
  title: 'Water the plants',
  description: done ? '' : 'Balcony and living room',
  done: done,
  color: color,
  priority: priority,
  labels: labels,
  dueDate: dueDate,
  createdBy: _demoUser,
  projectId: 1,
);

Label _demoLabel(String title, Color? color) =>
    Label(title: title, color: color, createdBy: _demoUser);

Widget _pad(Widget child) => Padding(
  padding: const EdgeInsets.all(AppDimensions.md),
  child: Center(child: child),
);

final uiComponents = <WidgetbookNode>[
  WidgetbookComponent(
    name: 'AppButton',
    useCases: [
      WidgetbookUseCase(
        name: 'Variants',
        builder: (context) => _pad(
          Column(
            mainAxisSize: MainAxisSize.min,
            spacing: AppDimensions.sm,
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
            ],
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'States',
        builder: (context) => _pad(
          Column(
            mainAxisSize: MainAxisSize.min,
            spacing: AppDimensions.sm,
            children: [
              AppButton(label: 'With icon', icon: Icons.add, onPressed: () {}),
              const AppButton(label: 'Disabled', onPressed: null),
              AppButton(label: 'Loading', loading: true, onPressed: () {}),
              AppButton(label: 'Expanded', expand: true, onPressed: () {}),
            ],
          ),
        ),
      ),
    ],
  ),
  WidgetbookComponent(
    name: 'AppCard',
    useCases: [
      WidgetbookUseCase(
        name: 'Default',
        builder: (context) => _pad(const AppCard(child: Text('Card content'))),
      ),
      WidgetbookUseCase(
        name: 'Tappable',
        builder: (context) =>
            _pad(AppCard(onTap: () {}, child: const Text('Tap me'))),
      ),
    ],
  ),
  WidgetbookComponent(
    name: 'AppTextField',
    useCases: [
      WidgetbookUseCase(
        name: 'Default',
        builder: (context) => _pad(
          const AppTextField(
            label: 'Server address',
            hint: 'https://try.vikunja.io',
            prefixIcon: Icons.dns_outlined,
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Error',
        builder: (context) => _pad(
          const AppTextField(
            label: 'Server address',
            errorText: 'Cannot reach server',
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Obscured',
        builder: (context) =>
            _pad(const AppTextField(label: 'Password', obscure: true)),
      ),
    ],
  ),
  WidgetbookComponent(
    name: 'EmptyState',
    useCases: [
      WidgetbookUseCase(
        name: 'Title only',
        builder: (context) =>
            const EmptyState(icon: Icons.list, title: 'No tasks yet'),
      ),
      WidgetbookUseCase(
        name: 'With subtitle and action',
        builder: (context) => EmptyState(
          icon: Icons.splitscreen_outlined,
          title: 'Select a project',
          subtitle: 'Pick a project from the list to see its tasks.',
          action: AppButton(label: 'New project', onPressed: () {}),
        ),
      ),
    ],
  ),
  WidgetbookComponent(
    name: 'ConfirmationDialog',
    useCases: [
      WidgetbookUseCase(
        name: 'Destructive',
        builder: (context) => const ConfirmationDialog(
          title: 'Delete task',
          message: 'Are you sure you want to delete this task?',
          confirmLabel: 'Delete',
          cancelLabel: 'Cancel',
          isDestructive: true,
        ),
      ),
      WidgetbookUseCase(
        name: 'Neutral',
        builder: (context) => const ConfirmationDialog(
          title: 'Unsaved changes',
          message: 'Discard your changes?',
          confirmLabel: 'Discard',
          cancelLabel: 'Keep editing',
        ),
      ),
    ],
  ),
  WidgetbookComponent(
    name: 'Kanban TaskTile',
    useCases: [
      WidgetbookUseCase(
        name: 'Default',
        builder: (context) =>
            _pad(SizedBox(width: 300, child: TaskTile(task: _demoTask()))),
      ),
      WidgetbookUseCase(
        name: 'Done with custom color',
        builder: (context) => _pad(
          SizedBox(
            width: 300,
            child: TaskTile(
              task: _demoTask(done: true, color: const Color(0xFF7B1FA2)),
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Priority, labels and due date',
        builder: (context) => _pad(
          SizedBox(
            width: 300,
            child: TaskTile(
              task: _demoTask(
                priority: 4,
                dueDate: DateTime.now().add(const Duration(days: 2)),
                labels: [
                  _demoLabel('urgent', const Color(0xFFC62828)),
                  _demoLabel('garden', const Color(0xFF2E7D32)),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  ),
  WidgetbookComponent(
    name: 'LabelWidget',
    useCases: [
      WidgetbookUseCase(
        name: 'Colors',
        builder: (context) => _pad(
          Wrap(
            spacing: AppDimensions.xs,
            children: [
              LabelWidget(label: _demoLabel('no color', null)),
              LabelWidget(label: _demoLabel('dark', const Color(0xFF1A237E))),
              LabelWidget(label: _demoLabel('light', const Color(0xFFFFF59D))),
              LabelWidget(
                label: _demoLabel('deletable', const Color(0xFF00695C)),
                onDelete: () {},
              ),
            ],
          ),
        ),
      ),
    ],
  ),
  WidgetbookComponent(
    name: 'PriorityBatch',
    useCases: [
      WidgetbookUseCase(
        name: 'Levels',
        builder: (context) => _pad(
          const Wrap(
            spacing: AppDimensions.xs,
            children: [
              PriorityBatch(1),
              PriorityBatch(2),
              PriorityBatch(3),
              PriorityBatch(5),
            ],
          ),
        ),
      ),
    ],
  ),
  WidgetbookComponent(
    name: 'DueDateCard',
    useCases: [
      WidgetbookUseCase(
        name: 'Upcoming vs overdue',
        builder: (context) => _pad(
          Wrap(
            spacing: AppDimensions.xs,
            children: [
              DueDateCard(DateTime.now().add(const Duration(days: 3))),
              DueDateCard(DateTime.now().subtract(const Duration(days: 1))),
            ],
          ),
        ),
      ),
    ],
  ),
];
