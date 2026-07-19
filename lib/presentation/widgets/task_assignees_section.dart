import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vikunja_app/core/di/offline_provider.dart';
import 'package:vikunja_app/core/di/repository_provider.dart';
import 'package:vikunja_app/domain/entities/task.dart';
import 'package:vikunja_app/domain/entities/user.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/widgets/user_avatar.dart';

/// Zeigt die zugewiesenen Personen einer Aufgabe als Avatar-Chips und
/// erlaubt Zuweisen/Entfernen über die Nutzer des Projekts.
/// Änderungen werden sofort gespeichert (Bulk-Endpoint ersetzt die Liste).
class TaskAssigneesSection extends ConsumerStatefulWidget {
  final Task task;
  final bool editable;

  const TaskAssigneesSection({
    super.key,
    required this.task,
    this.editable = true,
  });

  @override
  ConsumerState<TaskAssigneesSection> createState() =>
      _TaskAssigneesSectionState();
}

class _TaskAssigneesSectionState extends ConsumerState<TaskAssigneesSection> {
  late List<User> _assignees;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _assignees = List.of(widget.task.assignees);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                AppLocalizations.of(context).assignees,
                style: theme.textTheme.titleMedium,
              ),
            ),
            if (_saving)
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            if (widget.editable)
              IconButton(
                icon: const Icon(Icons.person_add_alt),
                tooltip: AppLocalizations.of(context).addAssignee,
                onPressed: _saving ? null : _showUserPicker,
              ),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _assignees
              .map(
                (user) => Chip(
                  avatar: UserAvatar(user: user, radius: 12),
                  label: Text(user.name.isNotEmpty ? user.name : user.username),
                  onDeleted: widget.editable && !_saving
                      ? () => _setAssignees(
                          _assignees.where((u) => u.id != user.id).toList(),
                        )
                      : null,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Future<void> _showUserPicker() async {
    final projectId = widget.task.projectId;
    if (projectId == null) return;

    final selected = await showDialog<User>(
      context: context,
      builder: (dialogContext) => _UserPickerDialog(
        projectId: projectId,
        excludeUserIds: _assignees.map((u) => u.id).toSet(),
      ),
    );
    if (selected != null) {
      await _setAssignees([..._assignees, selected]);
    }
  }

  Future<void> _setAssignees(List<User> updated) async {
    setState(() => _saving = true);
    // Optimistisch über den OfflineWriter: lokal setzen + online versuchen;
    // Netzwerkfehler → Outbox. Nur eine Server-Ablehnung gilt als Fehler.
    final result = await ref
        .read(offlineWriterProvider)
        .setAssignees(widget.task.id, updated);
    if (!mounted) return;

    setState(() {
      _saving = false;
      if (result.ok) {
        _assignees = updated;
        widget.task.assignees = updated;
      }
    });
    if (!result.ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).assigneesUpdateFailed),
        ),
      );
    }
  }
}

class _UserPickerDialog extends ConsumerStatefulWidget {
  final int projectId;
  final Set<int> excludeUserIds;

  const _UserPickerDialog({
    required this.projectId,
    required this.excludeUserIds,
  });

  @override
  ConsumerState<_UserPickerDialog> createState() => _UserPickerDialogState();
}

class _UserPickerDialogState extends ConsumerState<_UserPickerDialog> {
  List<User> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _search('');
  }

  Future<void> _search(String query) async {
    setState(() => _loading = true);
    final response = await ref
        .read(taskRepositoryProvider)
        .getAssignableUsers(widget.projectId, query);
    if (!mounted) return;

    setState(() {
      _loading = false;
      _users = response.isSuccessful
          ? response
                .toSuccess()
                .body
                .where((u) => !widget.excludeUserIds.contains(u.id))
                .toList()
          : [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).addAssignee),
      content: SizedBox(
        width: double.maxFinite,
        height: 320,
        child: Column(
          children: [
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).assigneeSearchHint,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: _search,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _users.length,
                      itemBuilder: (context, index) {
                        final user = _users[index];
                        return ListTile(
                          leading: UserAvatar(user: user, radius: 16),
                          title: Text(
                            user.name.isNotEmpty ? user.name : user.username,
                          ),
                          subtitle: user.name.isNotEmpty
                              ? Text(user.username)
                              : null,
                          onTap: () => Navigator.of(context).pop(user),
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
          child: Text(AppLocalizations.of(context).cancel),
        ),
      ],
    );
  }
}
