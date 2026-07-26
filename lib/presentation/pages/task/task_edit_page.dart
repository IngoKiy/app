import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:vikunja_app/core/di/network_provider.dart';
import 'package:vikunja_app/core/di/offline_provider.dart';
import 'package:vikunja_app/core/offline/offline_writer.dart';
import 'package:vikunja_app/core/di/repository_provider.dart';
import 'package:vikunja_app/core/theming/color_utils.dart';
import 'package:vikunja_app/core/utils/priority.dart';
import 'package:vikunja_app/core/utils/repeat_after_parse.dart';
import 'package:vikunja_app/core/utils/repeat_after_unit.dart';
import 'package:vikunja_app/domain/entities/label.dart';
import 'package:vikunja_app/domain/entities/task.dart';
import 'package:vikunja_app/domain/entities/task_reminder.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/manager/task_page_controller.dart';
import 'package:vikunja_app/presentation/pages/task/edit_description.dart';
import 'package:vikunja_app/presentation/pages/task/task_comments_page.dart';
import 'package:vikunja_app/presentation/widgets/date_time_field.dart';
import 'package:vikunja_app/presentation/widgets/label_widget.dart';
import 'package:vikunja_app/presentation/widgets/project/project_picker.dart';
import 'package:vikunja_app/presentation/widgets/task_assignees_section.dart';
import 'package:vikunja_app/presentation/widgets/task_attachments_section.dart';
import 'package:vikunja_app/presentation/widgets/ui/constrained_page.dart';
import 'package:vikunja_app/presentation/widgets/task/color_picker_dialog.dart';
import 'package:vikunja_app/presentation/widgets/task/task_delete_dialog.dart';

/// Zustand der Autosave-Anzeige in der AppBar.
enum _SaveState { idle, saving, saved, error }

class TaskEditPage extends ConsumerStatefulWidget {
  final Task task;

  TaskEditPage({required this.task}) : super(key: Key(task.toString()));

  @override
  TaskEditPageState createState() => TaskEditPageState();
}

class TaskEditPageState extends ConsumerState<TaskEditPage> {
  final _formKey = GlobalKey<FormState>();

  String? _title, _description;
  DateTime? _dueDate, _startDate, _endDate;
  int _repeatAfterValue = 0;
  RepeatAfterUnit _repeatAfterUnit = RepeatAfterUnit.days;
  int? _priority;
  int? _projectId;
  List<TaskReminder>? _reminderDates;
  List<Label>? _labels;
  Color? _color;

  // we use this to find the label object after a user taps on the suggestion, because the typeahead only uses strings, not full objects.
  List<Label>? _suggestedLabels;
  final _labelTypeAheadController = TextEditingController();

  Timer? _debounce;
  Completer<Iterable<String>>? _lastCompleter;

  // Autosave: Änderungen werden ohne Speichern-Button persistiert — diskrete
  // Felder sofort, Textfelder mit Tipppausen-Debounce. Der lokale Write ist
  // durch die Offline-First-Architektur immer schnell (DB + Outbox).
  static const _autosaveDebounce = Duration(milliseconds: 1500);
  Timer? _autosaveTimer;
  bool _dirty = false;
  bool _saving = false;
  _SaveState _saveState = _SaveState.idle;

  /// Labels-Stand des letzten erfolgreichen Saves — setLabels läuft nur bei
  /// tatsächlicher Änderung (eigener Endpoint, nicht Teil von updateTask).
  List<Label> _savedLabels = const [];

  /// Beim Schedulen gecapturte Abhängigkeiten (siehe [_scheduleAutosave]).
  OfflineWriter? _offlineWriter;
  TaskPageController? _taskPageController;

  @override
  void initState() {
    _reminderDates = List.of(widget.task.reminderDates);
    _labels = List.of(widget.task.labels);
    _savedLabels = List.of(widget.task.labels);

    _priority = widget.task.priority;
    _projectId = widget.task.projectId;
    _description = widget.task.description;
    _color = widget.task.color;

    _dueDate = widget.task.dueDate;
    _startDate = widget.task.startDate;
    _endDate = widget.task.endDate;

    _repeatAfterValue = getRepeatAfterValueFromDuration(
      widget.task.repeatAfter,
    );
    _repeatAfterUnit = getRepeatAfterTypeFromDuration(widget.task.repeatAfter);

    super.initState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _autosaveTimer?.cancel();
    // Noch nicht weggeschriebene Änderung beim Verlassen flushen. _autosave
    // greift nur auf die in _scheduleAutosave gecapturten Abhängigkeiten zu
    // (nie auf ref), daher ist der Aufruf hier sicher; der Write läuft im
    // Hintergrund weiter.
    if (_dirty) {
      _autosave();
    }
    _labelTypeAheadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: ConstrainedPage(child: _buildForm(context)),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(AppLocalizations.of(context).editTaskTitle),
      actions: [
        _buildSaveIndicator(),
        IconButton(
          icon: Icon(Icons.comment_outlined),
          tooltip: AppLocalizations.of(context).comments,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskCommentsPage(
                  taskId: widget.task.id,
                  taskTitle: _title ?? widget.task.title,
                ),
              ),
            );
          },
        ),
        IconButton(icon: Icon(Icons.delete), onPressed: showDeleteConfirmDialog),
      ],
    );
  }

  Widget _buildSaveIndicator() {
    final localizations = AppLocalizations.of(context);
    switch (_saveState) {
      case _SaveState.idle:
        return const SizedBox.shrink();
      case _SaveState.saving:
        return Tooltip(
          message: localizations.autosaveSaving,
          child: const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        );
      case _SaveState.saved:
        return Tooltip(
          message: localizations.autosaveSaved,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Center(child: Icon(Icons.cloud_done_outlined)),
          ),
        );
      case _SaveState.error:
        return Tooltip(
          message: localizations.autosaveError,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Center(
              child: Icon(
                Icons.cloud_off_outlined,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        );
    }
  }

  void showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TaskDeleteDialog(
          widget.task.id,
          onConfirm: () async {
            var success = await ref
                .read(taskPageControllerProvider.notifier)
                .deleteTask(widget.task.id);

            if (context.mounted) {
              if (success) {
                Navigator.of(context).pop();
                Navigator.of(context).pop(widget.task);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context).taskDeleteError),
                  ),
                );
              }
            }
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Form _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 50),
        children: <Widget>[
          _buildTitle(),
          _buildDescription(context),
          _buildProject(),
          _buildDueDate(),
          _buildStartDate(),
          _buildEndDate(),
          _buildRepeatAfter(),
          _buildReminderList(),
          _buildAddReminderButton(context),
          _buildPriority(),
          _buildAddLabel(context),
          _buildLabelList(),
          _buildColor(),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: TaskAssigneesSection(task: widget.task),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: TaskAttachmentsSection(task: widget.task),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        maxLines: null,
        keyboardType: TextInputType.multiline,
        initialValue: widget.task.title,
        onChanged: (title) {
          _title = title;
          _scheduleAutosave();
        },
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context).title,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () async {
          var description = await Navigator.push<String>(
            context,
            MaterialPageRoute(
              builder: (buildContext) =>
                  EditDescription(initialText: _description),
            ),
          );
          setState(() {
            if (description != null) {
              _description = description;
              _scheduleAutosave(immediate: true);
            }
          });
        },
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(Icons.description_outlined),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context).description,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).hintColor,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    HtmlWidget(
                      _description != null && _description?.isNotEmpty == true
                          ? _description!
                          : AppLocalizations.of(context).noDescription,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Projektauswahl: bei Änderung wird über updateTask die project_id
  // mitgesendet (= Verschieben in ein anderes Projekt).
  Widget _buildProject() {
    return ProjectPickerField(
      selectedProjectId: _projectId,
      onChanged: (projectId) {
        setState(() {
          _projectId = projectId;
          _scheduleAutosave(immediate: true);
        });
      },
    );
  }

  Widget _buildDueDate() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: VikunjaDateTimeField(
        icon: Icon(Icons.access_time),
        label: AppLocalizations.of(context).dueDateLabel,
        initialValue: widget.task.dueDate,
        onChanged: (duedate) {
          _dueDate = duedate;
          _scheduleAutosave(immediate: true);
        },
      ),
    );
  }

  Widget _buildStartDate() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: VikunjaDateTimeField(
        label: AppLocalizations.of(context).startDateLabel,
        initialValue: widget.task.startDate,
        onChanged: (startDate) {
          _startDate = startDate;
          _scheduleAutosave(immediate: true);
        },
      ),
    );
  }

  Widget _buildEndDate() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: VikunjaDateTimeField(
        label: AppLocalizations.of(context).endDateLabel,
        initialValue: widget.task.endDate,
        onChanged: (endDate) {
          _endDate = endDate;
          _scheduleAutosave(immediate: true);
        },
      ),
    );
  }

  Widget _buildRepeatAfter() {
    var localizations = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Flexible(
            flex: 65,
            child: TextFormField(
              keyboardType: TextInputType.number,
              initialValue: getRepeatAfterValueFromDuration(
                widget.task.repeatAfter,
              ).toString(),
              onChanged: (newValue) {
                _repeatAfterValue = int.tryParse(newValue) ?? 0;
                _scheduleAutosave();
              },
              decoration: InputDecoration(
                labelText: localizations.repeatAfter,
                border: InputBorder.none,
                icon: Icon(Icons.repeat),
                contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              ),
            ),
          ),
          Spacer(),
          Flexible(
            flex: 30,
            child: DropdownButtonFormField<RepeatAfterUnit>(
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              ),
              isExpanded: true,
              initialValue: _repeatAfterUnit,
              onChanged: (RepeatAfterUnit? newType) {
                if (newType != null) {
                  _repeatAfterUnit = newType;
                }
                _scheduleAutosave(immediate: true);
              },
              items: RepeatAfterUnit.values
                  .map<DropdownMenuItem<RepeatAfterUnit>>((
                    RepeatAfterUnit value,
                  ) {
                    return DropdownMenuItem<RepeatAfterUnit>(
                      value: value,
                      child: Text(value.toLocalizedString(context)),
                    );
                  })
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderList() {
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Column(
        children:
            _reminderDates?.map((e) {
              return VikunjaDateTimeField(
                label: AppLocalizations.of(context).reminder,
                initialValue: e.reminder,
                onChanged: (date) {
                  if (date != null) {
                    e.reminder = date;
                  } else {
                    _reminderDates?.remove(e);
                  }
                  _scheduleAutosave(immediate: true);
                },
              );
            }).toList() ??
            [],
      ),
    );
  }

  Widget _buildAddReminderButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(
                Icons.alarm_add,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              AppLocalizations.of(context).addReminder,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 16,
              ),
            ),
          ],
        ),
        onTap: () => _addNewReminder(context),
      ),
    );
  }

  Widget _buildPriority() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        icon: const Icon(Icons.flag),
        labelText: AppLocalizations.of(context).priority,
        border: InputBorder.none,
      ),
      initialValue: priorityToString(AppLocalizations.of(context), _priority),
      isExpanded: true,
      onChanged: (String? newValue) {
        _priority = priorityFromString(AppLocalizations.of(context), newValue);
        _scheduleAutosave(immediate: true);
      },
      items:
          [
            AppLocalizations.of(context).priorityUnset,
            AppLocalizations.of(context).priorityLow,
            AppLocalizations.of(context).priorityMedium,
            AppLocalizations.of(context).priorityHigh,
            AppLocalizations.of(context).priorityUrgent,
            AppLocalizations.of(context).priorityDoNow,
          ].map((String value) {
            return DropdownMenuItem(value: value, child: Text(value));
          }).toList(),
    );
  }

  Widget _buildAddLabel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 15, left: 2),
            child: Icon(
              Icons.label,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(
            width:
                MediaQuery.of(context).size.width -
                80 -
                ((IconTheme.of(context).size ?? 0) * 2),
            child: Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<String>.empty();
                }

                if (_debounce?.isActive ?? false) {
                  _debounce!.cancel();
                  _lastCompleter?.complete(const Iterable<String>.empty());
                }

                final completer = Completer<Iterable<String>>();
                _lastCompleter = completer;

                _debounce = Timer(const Duration(milliseconds: 500), () async {
                  var labels = await _searchLabel(textEditingValue.text);
                  if (!completer.isCompleted) {
                    completer.complete(labels);
                  }
                });

                return completer.future;
              },
              focusNode: FocusNode(),
              textEditingController: _labelTypeAheadController,
              onSelected: (String selection) {
                _addLabel(selection);
              },
            ),
          ),
          IconButton(
            onPressed: () => _createAndAddLabel(_labelTypeAheadController.text),
            icon: Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildColor() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 15, left: 2),
            child: Icon(
              Icons.palette,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          ElevatedButton(
            style: (_color == null || _color == Colors.black)
                ? null
                : ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith(
                      (_) => _color,
                    ),
                  ),
            onPressed: _onColorEdit,
            child: Text(
              AppLocalizations.of(context).setColor,
              style: (_color == null || _color == Colors.black)
                  ? null
                  : TextStyle(color: contrastingTextColor(_color!)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: () {
              Color? color = (_color == null || _color == Colors.black)
                  ? null
                  : _color;

              return Text(
                color != null
                    ? "#${color.toHexString()}"
                    : AppLocalizations.of(context).none,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              );
            }(),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelList() {
    return Wrap(
      spacing: 10,
      children:
          _labels?.map((label) {
            return LabelWidget(
              label: label,
              onDelete: () => _removeLabel(label),
            );
          }).toList() ??
          [],
    );
  }

  Future<List<String>> _searchLabel(String query) async {
    var labelsResponse = await ref
        .read(labelRepositoryProvider)
        .getAll(query: query);

    if (labelsResponse.isSuccessful) {
      var labels = labelsResponse.toSuccess().body;

      labels.removeWhere(
        (labelToRemove) => _labels?.contains(labelToRemove) == true,
      );
      _suggestedLabels = labels;

      return labels.map((e) => e.title).toList();
    }
    return [];
  }

  void _addLabel(String labelTitle) {
    var label = _suggestedLabels?.firstWhereOrNull(
      (e) => e.title == labelTitle,
    );

    if (label != null) {
      setState(() {
        _labels?.add(label);
        _labelTypeAheadController.clear();
      });
      _scheduleAutosave(immediate: true);
    }
  }

  void _removeLabel(Label label) {
    setState(() {
      _labels?.removeWhere((l) => l.id == label.id);
    });
    _scheduleAutosave(immediate: true);
  }

  void _createAndAddLabel(String labelTitle) async {
    // Only add a label if there are none to add
    if (labelTitle.isEmpty ||
        _suggestedLabels?.firstWhereOrNull(
              (label) => label.title == labelTitle,
            ) !=
            null) {
      return;
    }

    final currentUser = ref.read(currentUserProvider);

    if (currentUser != null) {
      final newLabel = Label(title: labelTitle, createdBy: currentUser);

      // Optimistisch über den OfflineWriter: online anlegen oder (offline) eine
      // Temp-ID vergeben; das gelieferte Label landet direkt in der Auswahl.
      final created = await ref
          .read(offlineWriterProvider)
          .createLabel(newLabel);
      if (created != null && mounted) {
        setState(() {
          _labels?.add(created);
          _labelTypeAheadController.clear();
        });
        _scheduleAutosave(immediate: true);
      }
    }
  }

  Future<void> _addNewReminder(BuildContext context) async {
    var selectedDate = await showDialog<DateTime>(
      context: context,
      builder: (_) => DatePickerDialog(
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
        initialCalendarMode: DatePickerMode.day,
      ),
    );

    if (selectedDate != null && context.mounted) {
      var selectedTime = await showDialog<TimeOfDay>(
        context: context,
        builder: (_) =>
            TimePickerDialog(initialTime: TimeOfDay.fromDateTime(selectedDate)),
      );

      if (selectedTime != null) {
        setState(() {
          _reminderDates?.add(
            TaskReminder(
              selectedDate.copyWith(
                hour: selectedTime.hour,
                minute: selectedTime.minute,
              ),
            ),
          );
        });
        _scheduleAutosave(immediate: true);
      }
    }
  }

  void _onColorEdit() {
    var pickerColor = _color ?? Colors.black;
    showDialog(
      context: context,
      builder: (context) => ColorPickerDialog(
        pickerColor,
        (color) {
          if (color != Colors.black) {
            setState(() {
              _color = color;
            });
          } else {
            setState(() {
              _color = null;
            });
          }
          Navigator.of(context).pop();

          _scheduleAutosave(immediate: true);
        },
        () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  /// Merkt eine Änderung vor und stößt das Speichern an — diskrete Felder
  /// sofort ([immediate]), Textfelder nach [_autosaveDebounce] Tipppause.
  ///
  /// Die Provider werden hier (immer mounted) gecaptured, damit _autosave als
  /// Dispose-Flush oder Nachzügler-Re-Run nie mehr auf [ref] zugreifen muss.
  void _scheduleAutosave({bool immediate = false}) {
    _offlineWriter = ref.read(offlineWriterProvider);
    _taskPageController = ref.read(taskPageControllerProvider.notifier);
    _dirty = true;
    _autosaveTimer?.cancel();
    if (immediate) {
      _autosave();
    } else {
      _autosaveTimer = Timer(_autosaveDebounce, _autosave);
    }
  }

  bool _sameLabels(List<Label> a, List<Label> b) =>
      a.length == b.length &&
      a.map((l) => l.id).toSet().containsAll(b.map((l) => l.id));

  Future<void> _autosave() async {
    _autosaveTimer?.cancel();
    if (!_dirty || _saving) return;
    // Leeren Titel nicht persistieren — es wird gespeichert, sobald wieder
    // ein Titel dasteht (der nächste onChanged triggert erneut).
    if (_title != null && _title!.trim().isEmpty) return;

    final offlineWriter = _offlineWriter;
    final taskPageController = _taskPageController;
    if (offlineWriter == null || taskPageController == null) return;

    _saving = true;
    _dirty = false;
    if (mounted) setState(() => _saveState = _SaveState.saving);

    var success = true;
    try {
      // Removes all reminders with no value set.
      _reminderDates?.removeWhere((d) => d.reminder == DateTime(0));

      final updatedTask =
          widget.task.copyWith(
              title: _title,
              description: _description,
              reminderDates: _reminderDates,
              priority: _priority,
              projectId: _projectId,
              labels: _labels,
              repeatAfter: _repeatAfterUnit.getDuration(_repeatAfterValue),
            )
            //Need to be here as they can be null
            ..dueDate = _dueDate
            ..startDate = _startDate
            ..endDate = _endDate
            ..color = _color;

      // Labels nur bei tatsächlicher Änderung (eigener Endpoint).
      final labels = _labels;
      if (labels != null && !_sameLabels(labels, _savedLabels)) {
        final labelResult = await offlineWriter.setLabels(
          updatedTask.id,
          labels,
        );
        success = labelResult.ok;
        if (success) {
          _savedLabels = List.of(labels);
        }
      }

      if (success) {
        success = await taskPageController.updateTask(updatedTask);
      }
    } catch (_) {
      success = false;
    } finally {
      _saving = false;
      final newState = success ? _SaveState.saved : _SaveState.error;
      if (mounted) {
        setState(() => _saveState = newState);
        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).taskSaveError)),
          );
        }
      } else {
        _saveState = newState;
      }
      // Während des Speicherns eingegangene Änderungen direkt nachziehen.
      if (_dirty) {
        _autosave();
      }
    }
  }
}
