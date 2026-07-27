import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vikunja_app/domain/entities/new_task_due.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/core/utils/due_date_format.dart';
import 'package:vikunja_app/presentation/widgets/project/project_picker.dart';
import 'package:vikunja_app/presentation/widgets/ui/preset_sheet.dart';

/// Öffnet die Aufgaben-Schnelleingabe im Stil von Microsoft To Do: ein
/// tastatur-angedocktes Sheet mit randloser Eingabezeile und der Icon-Zeile
/// (Erinnerung, Fälligkeit, Notiz, ggf. Zielliste). Enter legt die Aufgabe an
/// und lässt das Sheet für die nächste Eingabe offen; Schließen per
/// Wischen/Tippen außerhalb.
Future<void> showAddTaskSheet(
  BuildContext context, {
  required void Function(
    String title,
    DateTime? dueDate,
    int projectId, {
    DateTime? reminder,
    String? description,
  })
  onAddTask,
  int defaultProjectId = 0,
  bool selectableProject = false,
  String? initialTitle,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => AddTaskSheet(
      onAddTask: onAddTask,
      defaultProjectId: defaultProjectId,
      selectableProject: selectableProject,
      initialTitle: initialTitle,
    ),
  );
}

class AddTaskSheet extends StatefulWidget {
  final void Function(
    String title,
    DateTime? dueDate,
    int projectId, {
    DateTime? reminder,
    String? description,
  })
  onAddTask;

  /// Vorbelegtes Zielprojekt (0 = keins). Bei [selectableProject] änderbar.
  final int defaultProjectId;

  /// Zeigt die Zielprojekt-Aktion (Schnell-Add ohne festes Projekt). In
  /// projektgebundenen Kontexten (Projektdetail/Kanban) `false` lassen.
  final bool selectableProject;

  /// Vorbelegter Titel (z.B. aus dem App-Shortcut).
  final String? initialTitle;

  const AddTaskSheet({
    super.key,
    required this.onAddTask,
    this.defaultProjectId = 0,
    this.selectableProject = false,
    this.initialTitle,
  });

  @override
  State<AddTaskSheet> createState() => AddTaskSheetState();
}

enum _SheetReminderPreset { laterToday, tomorrow, nextWeek, pick }

class AddTaskSheetState extends State<AddTaskSheet> {
  final _controller = TextEditingController();
  final _noteController = TextEditingController();
  final _focusNode = FocusNode();
  DateTime? _dueDate;
  DateTime? _reminder;
  bool _showNote = false;
  int _projectId = 0;
  String? _projectTitle;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _projectId = widget.defaultProjectId;
    final initialTitle = widget.initialTitle;
    if (initialTitle != null && initialTitle.isNotEmpty) {
      _controller.text = initialTitle;
      _hasText = true;
    }
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _noteController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _canSubmit => _hasText && _projectId != 0;

  void _submit() {
    final title = _controller.text.trim();
    if (title.isEmpty || _projectId == 0) return;
    final note = _noteController.text.trim();
    widget.onAddTask(
      title,
      _dueDate,
      _projectId,
      reminder: _reminder,
      description: note.isEmpty ? null : note,
    );
    // Sheet bleibt offen für die nächste Aufgabe (To-Do-Verhalten).
    _controller.clear();
    _noteController.clear();
    setState(() {
      _dueDate = null;
      _reminder = null;
      _showNote = false;
    });
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Padding(
      // Über der Tastatur andocken.
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.radio_button_unchecked,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      hintText: l10n.addTaskBar,
                      border: InputBorder.none,
                      filled: false,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _canSubmit ? _submit : null,
                  icon: Icon(
                    Icons.arrow_upward,
                    color: _canSubmit
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            if (_showNote)
              Padding(
                padding: const EdgeInsets.only(left: 36, right: 8),
                child: TextField(
                  controller: _noteController,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: l10n.noteAdd,
                    border: InputBorder.none,
                    filled: false,
                    isDense: true,
                  ),
                ),
              ),
            // Icon-Zeile wie in To Do: Erinnerung, Fälligkeit, Notiz —
            // gesetzte Werte als Chips mit ×.
            Wrap(
              spacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _reminder == null
                    ? IconButton(
                        tooltip: l10n.reminder,
                        icon: Icon(
                          Icons.notifications_outlined,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        onPressed: _pickReminder,
                      )
                    : InputChip(
                        avatar: const Icon(
                          Icons.notifications_outlined,
                          size: 16,
                        ),
                        label: Text(
                          DateFormat.E(
                            l10n.localeName,
                          ).add_Hm().format(_reminder!),
                        ),
                        onPressed: _pickReminder,
                        onDeleted: () => setState(() => _reminder = null),
                      ),
                _dueDate == null
                    ? IconButton(
                        tooltip: l10n.dueDateLabel,
                        icon: Icon(
                          Icons.calendar_today_outlined,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        onPressed: _pickDueDate,
                      )
                    : InputChip(
                        avatar: const Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                        ),
                        label: Text(
                          formatDueDate(l10n, l10n.localeName, _dueDate!),
                        ),
                        onPressed: _pickDueDate,
                        onDeleted: () => setState(() => _dueDate = null),
                      ),
                IconButton(
                  tooltip: l10n.noteAdd,
                  icon: Icon(
                    Icons.sticky_note_2_outlined,
                    color: _showNote
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () => setState(() => _showNote = !_showNote),
                ),
                if (widget.selectableProject)
                  _projectId == 0
                      ? IconButton(
                          tooltip: l10n.selectProject,
                          icon: Icon(
                            Icons.list_alt_outlined,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          onPressed: _pickProject,
                        )
                      : InputChip(
                          avatar: const Icon(Icons.list_alt_outlined, size: 16),
                          label: Text(_projectTitle ?? l10n.project),
                          onPressed: _pickProject,
                        ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  DateTime _nextMondayAt(DateTime now, int hour) {
    final daysUntilMonday = (DateTime.monday - now.weekday + 7) % 7;
    final add = daysUntilMonday == 0 ? 7 : daysUntilMonday;
    final day = DateTime(now.year, now.month, now.day).add(Duration(days: add));
    return DateTime(day.year, day.month, day.day, hour);
  }

  Future<void> _pickDueDate() async {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final dayFmt = DateFormat.E(l10n.localeName);
    final today = DateTime(now.year, now.month, now.day, 12);
    final tomorrow = today.add(const Duration(days: 1));
    final nextWeek = _nextMondayAt(now, 12);

    final choice = await showPresetSheet<NewTaskDue>(
      context,
      title: l10n.dueDateLabel,
      options: [
        PresetOption(
          icon: Icons.today_outlined,
          label: l10n.dueOptionToday,
          trailing: dayFmt.format(today),
          value: NewTaskDue.today,
        ),
        PresetOption(
          icon: Icons.event_outlined,
          label: l10n.dueOptionTomorrow,
          trailing: dayFmt.format(tomorrow),
          value: NewTaskDue.tomorrow,
        ),
        PresetOption(
          icon: Icons.calendar_month_outlined,
          label: l10n.presetNextWeek,
          trailing: dayFmt.format(nextWeek),
          value: NewTaskDue.nextMonday,
        ),
        PresetOption(
          icon: Icons.edit_calendar_outlined,
          label: l10n.pickDate,
          chevron: true,
          value: NewTaskDue.custom,
        ),
      ],
    );
    if (choice == null || !mounted) return;

    switch (choice) {
      case NewTaskDue.none:
        setState(() => _dueDate = null);
      case NewTaskDue.custom:
        final date = await showDatePicker(
          context: context,
          initialDate: _dueDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          setState(
            () => _dueDate = DateTime(date.year, date.month, date.day, 12),
          );
        }
      default:
        setState(() => _dueDate = choice.calculateDate(DateTime.now()));
    }
    _focusNode.requestFocus();
  }

  Future<void> _pickReminder() async {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final laterToday = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
    ).add(const Duration(hours: 3));
    final tomorrow = DateTime(
      now.year,
      now.month,
      now.day,
      9,
    ).add(const Duration(days: 1));
    final nextWeek = _nextMondayAt(now, 9);
    final fmt = DateFormat.E(l10n.localeName).add_Hm();

    final choice = await showPresetSheet<_SheetReminderPreset>(
      context,
      title: l10n.reminder,
      options: [
        PresetOption(
          icon: Icons.update,
          label: l10n.presetLaterToday,
          trailing: fmt.format(laterToday),
          value: _SheetReminderPreset.laterToday,
        ),
        PresetOption(
          icon: Icons.event_outlined,
          label: l10n.dueOptionTomorrow,
          trailing: fmt.format(tomorrow),
          value: _SheetReminderPreset.tomorrow,
        ),
        PresetOption(
          icon: Icons.calendar_month_outlined,
          label: l10n.presetNextWeek,
          trailing: fmt.format(nextWeek),
          value: _SheetReminderPreset.nextWeek,
        ),
        PresetOption(
          icon: Icons.edit_calendar_outlined,
          label: l10n.pickDateTime,
          chevron: true,
          value: _SheetReminderPreset.pick,
        ),
      ],
    );
    if (choice == null || !mounted) return;

    DateTime? picked;
    switch (choice) {
      case _SheetReminderPreset.laterToday:
        picked = laterToday;
      case _SheetReminderPreset.tomorrow:
        picked = tomorrow;
      case _SheetReminderPreset.nextWeek:
        picked = nextWeek;
      case _SheetReminderPreset.pick:
        final date = await showDatePicker(
          context: context,
          initialDate: now,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null && mounted) {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (time != null) {
            picked = DateTime(
              date.year,
              date.month,
              date.day,
              time.hour,
              time.minute,
            );
          }
        }
    }
    if (picked != null) setState(() => _reminder = picked);
    _focusNode.requestFocus();
  }

  Future<void> _pickProject() async {
    final projectId = await showDialog<int>(
      context: context,
      builder: (_) => ProjectPickerDialog(
        selectedProjectId: _projectId == 0 ? null : _projectId,
      ),
    );
    if (projectId != null && mounted) {
      setState(() => _projectId = projectId);
      // Titel des gewählten Projekts für den Chip nachschlagen entfällt —
      // der Dialog liefert nur die ID; der Chip zeigt bis zum nächsten
      // Aufbau den generischen Text. Einfachheit vor Perfektion.
      _projectTitle = null;
    }
    _focusNode.requestFocus();
  }
}
