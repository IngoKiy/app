import 'package:flutter/material.dart';
import 'package:vikunja_app/core/utils/date_extensions.dart';
import 'package:vikunja_app/domain/entities/new_task_due.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/widgets/date_time_field.dart';
import 'package:vikunja_app/presentation/widgets/project/project_picker.dart';

/// Öffnet die Aufgaben-Schnelleingabe im Stil von Microsoft To Do: ein
/// tastatur-angedocktes Sheet mit Eingabezeile und Schnell-Aktionen
/// (Fälligkeit, Zielprojekt). Enter legt die Aufgabe an und lässt das Sheet
/// für die nächste Eingabe offen; Schließen per Wischen/Tippen außerhalb.
Future<void> showAddTaskSheet(
  BuildContext context, {
  required void Function(String title, DateTime? dueDate, int projectId)
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
  final void Function(String title, DateTime? dueDate, int projectId)
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

class AddTaskSheetState extends State<AddTaskSheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  DateTime? _dueDate;
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
    _focusNode.dispose();
    super.dispose();
  }

  bool get _canSubmit => _hasText && _projectId != 0;

  void _submit() {
    final title = _controller.text.trim();
    if (title.isEmpty || _projectId == 0) return;
    widget.onAddTask(title, _dueDate, _projectId);
    // Sheet bleibt offen für die nächste Aufgabe (To-Do-Verhalten).
    _controller.clear();
    setState(() => _dueDate = null);
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
            // Schnell-Aktionen wie in To Do: Fälligkeit + Zielprojekt.
            Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
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
                        label: Text(_dueDate!.toLocal().formatShort()),
                        onPressed: _pickDueDate,
                        onDeleted: () => setState(() => _dueDate = null),
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

  Future<void> _pickDueDate() async {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final choice = await showModalBottomSheet<NewTaskDue>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (label, due) in [
              (l10n.dueOptionToday, NewTaskDue.today),
              (l10n.dueOptionTomorrow, NewTaskDue.tomorrow),
              (l10n.dueOptionNextMonday, NewTaskDue.nextMonday),
              (l10n.dueOptionCustom, NewTaskDue.custom),
              (l10n.dueOptionNone, NewTaskDue.none),
            ])
              ListTile(
                title: Text(label),
                onTap: () => Navigator.pop(context, due),
              ),
          ],
        ),
      ),
    );
    if (choice == null || !mounted) return;

    switch (choice) {
      case NewTaskDue.none:
        setState(() => _dueDate = null);
      case NewTaskDue.custom:
        // Exakten Zeitpunkt über den bestehenden Dialog wählen.
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            content: VikunjaDateTimeField(
              label: l10n.enterExactTime,
              onChanged: (value) => setState(() => _dueDate = value),
            ),
          ),
        );
      default:
        setState(() => _dueDate = choice.calculateDate(now));
    }
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
