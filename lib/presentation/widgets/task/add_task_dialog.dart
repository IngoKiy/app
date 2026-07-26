import 'package:flutter/material.dart';
import 'package:vikunja_app/core/utils/date_extensions.dart';
import 'package:vikunja_app/domain/entities/new_task_due.dart';
import 'package:vikunja_app/presentation/widgets/date_time_field.dart';
import 'package:vikunja_app/presentation/widgets/project/project_picker.dart';
import 'package:vikunja_app/presentation/widgets/ui/app_button.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';

class AddTaskDialog extends StatefulWidget {
  final void Function(String title, DateTime? dueDate, int projectId) onAddTask;
  final String? title;

  /// Vorbelegtes Zielprojekt (0 = keins). Bei [selectableProject] änderbar.
  final int defaultProjectId;

  /// Zeigt einen Projekt-Picker (Schnell-Add ohne festes Projekt). In
  /// projektgebundenen Kontexten (Projektdetail/Kanban) `false` lassen.
  final bool selectableProject;

  const AddTaskDialog({
    super.key,
    required this.onAddTask,
    this.title,
    this.defaultProjectId = 0,
    this.selectableProject = false,
  });

  @override
  State<StatefulWidget> createState() => AddTaskDialogState();
}

class AddTaskDialogState extends State<AddTaskDialog> {
  NewTaskDue newTaskDue = NewTaskDue.none;
  DateTime? dueDate;
  int _projectId = 0;
  var textController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _projectId = widget.defaultProjectId;

    var title = widget.title;
    if (title != null) {
      textController.text = title;
    }
  }

  @override
  Widget build(BuildContext context) {
    var dateTime = DateTime.now();

    return AlertDialog(
      scrollable: true,
      contentPadding: const EdgeInsets.all(16.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            keyboardType: TextInputType.multiline,
            maxLines: null,
            autofocus: true,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).newTaskName,
              hintText: AppLocalizations.of(context).newTaskExample,
            ),
            controller: textController,
          ),
          if (widget.selectableProject)
            ProjectPickerField(
              selectedProjectId: _projectId == 0 ? null : _projectId,
              onChanged: (projectId) => setState(() => _projectId = projectId),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: Text(AppLocalizations.of(context).dueDate),
          ),
          Wrap(
            spacing: 8,
            children: [
              taskDueList(
                AppLocalizations.of(context).dueOptionNone,
                NewTaskDue.none,
              ),
              if (dateTime.hour < 21)
                taskDueList(
                  AppLocalizations.of(context).dueOptionToday,
                  NewTaskDue.today,
                ),
              taskDueList(
                AppLocalizations.of(context).dueOptionTomorrow,
                NewTaskDue.tomorrow,
              ),
              taskDueList(
                AppLocalizations.of(context).dueOptionNextMonday,
                NewTaskDue.nextMonday,
              ),
              if (dateTime.weekday != DateTime.sunday || dateTime.hour < 21)
                taskDueList(
                  AppLocalizations.of(context).dueOptionThisWeekend,
                  NewTaskDue.weekend,
                ),
              taskDueList(
                AppLocalizations.of(context).dueOptionLaterThisWeek,
                NewTaskDue.laterThisWeek,
              ),
              taskDueList(
                AppLocalizations.of(context).dueInOneWeek,
                NewTaskDue.nextWeek,
              ),
              taskDueList(
                AppLocalizations.of(context).dueOptionCustom,
                NewTaskDue.custom,
              ),
            ],
          ),
          if (newTaskDue == NewTaskDue.custom)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: VikunjaDateTimeField(
                label: AppLocalizations.of(context).enterExactTime,
                onChanged: (value) {
                  setState(() => newTaskDue = NewTaskDue.custom);
                  dueDate = value;
                },
              ),
            ),
          if (newTaskDue != NewTaskDue.custom && dueDate != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 16,
              ),
              child: Row(
                children: [
                  Icon(Icons.date_range),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      dueDate!.formatShort(),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      actions: <Widget>[
        AppButton(
          label: AppLocalizations.of(context).cancel,
          variant: AppButtonVariant.text,
          onPressed: () => Navigator.pop(context),
        ),
        AppButton(
          label: AppLocalizations.of(context).add,
          // Ohne gültiges Zielprojekt (0) kann nicht angelegt werden.
          onPressed: _projectId == 0
              ? null
              : () {
                  if (textController.text.isNotEmpty) {
                    widget.onAddTask(textController.text, dueDate, _projectId);
                  }
                  Navigator.pop(context);
                },
        ),
      ],
    );
  }

  Widget taskDueList(String name, NewTaskDue thisNewTaskDue) {
    return ChoiceChip(
      label: Text(name),
      selected: newTaskDue == thisNewTaskDue,
      onSelected: (value) {
        newTaskDue = thisNewTaskDue;
        setState(() {
          if (newTaskDue == NewTaskDue.custom ||
              newTaskDue == NewTaskDue.none) {
            dueDate = null;
          } else {
            dueDate = newTaskDue.calculateDate(DateTime.now());
          }
        });
      },
    );
  }
}
