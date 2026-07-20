import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vikunja_app/core/di/repository_provider.dart';
import 'package:vikunja_app/core/sync/connectivity_provider.dart';
import 'package:vikunja_app/domain/entities/project_member.dart';
import 'package:vikunja_app/domain/entities/user.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/widgets/ui/confirmation_dialog.dart';
import 'package:vikunja_app/presentation/widgets/user_avatar.dart';

/// Eigenständige Seite für die Mitgliederverwaltung eines Projekts.
class ProjectMembersPage extends StatelessWidget {
  final int projectId;

  const ProjectMembersPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).projectMembers)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ProjectMembersSection(projectId: projectId),
        ),
      ),
    );
  }
}

/// Mitgliederverwaltung: listet Mitglieder mit Rolle, erlaubt Hinzufügen,
/// Rollenwechsel und Entfernen. Online-only – bei fehlender Verbindung (oder
/// einem noch nicht synchronisierten Temp-Projekt) wird nur ein Hinweis
/// gezeigt, da es keine lokale Members-Tabelle gibt.
class ProjectMembersSection extends ConsumerStatefulWidget {
  final int projectId;

  const ProjectMembersSection({super.key, required this.projectId});

  @override
  ConsumerState<ProjectMembersSection> createState() =>
      _ProjectMembersSectionState();
}

class _ProjectMembersSectionState extends ConsumerState<ProjectMembersSection> {
  List<ProjectMember> _members = [];
  bool _loading = false;
  bool _loaded = false;
  bool _busy = false;

  bool get _manageable => widget.projectId > 0;

  Future<void> _load() async {
    setState(() => _loading = true);
    final response = await ref
        .read(projectMemberRepositoryProvider)
        .getMembers(widget.projectId);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _loaded = true;
      if (response.isSuccessful) {
        _members = response.toSuccess().body;
      } else {
        _showSnack(AppLocalizations.of(context).membersLoadFailed);
      }
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isOnline = ref.watch(connectivityStatusProvider);

    if (!isOnline || !_manageable) {
      return _Hint(text: l10n.membersOnlineOnly);
    }

    // Erstes Laden anstoßen, sobald online und noch nicht geladen.
    if (!_loaded && !_loading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_loaded && !_loading) _load();
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.projectMembers,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (_busy)
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.person_add_alt),
              tooltip: l10n.addMember,
              onPressed: _busy ? null : _showAddDialog,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_loading && _members.isEmpty)
          const Center(child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ))
        else if (_members.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text(l10n.noMembers)),
          )
        else
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _members.length,
              itemBuilder: (context, index) =>
                  _buildMemberTile(l10n, _members[index]),
            ),
          ),
      ],
    );
  }

  Widget _buildMemberTile(AppLocalizations l10n, ProjectMember member) {
    final user = member.user;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: UserAvatar(user: user, radius: 18),
      title: Text(user.name.isNotEmpty ? user.name : user.username),
      subtitle: user.name.isNotEmpty ? Text(user.username) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RoleDropdown(
            right: member.right,
            enabled: !_busy,
            onChanged: (value) => _changeRight(member, value),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.removeMember,
            onPressed: _busy ? null : () => _removeMember(member),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddDialog() async {
    final result = await showDialog<_AddMemberResult>(
      context: context,
      builder: (_) => _AddMemberDialog(
        excludeUserIds: _members.map((m) => m.user.id).toSet(),
      ),
    );
    if (result == null || !mounted) return;

    setState(() => _busy = true);
    final response = await ref
        .read(projectMemberRepositoryProvider)
        .addMember(widget.projectId, result.user.username, result.right);
    if (!mounted) return;
    setState(() => _busy = false);

    if (response.isSuccessful) {
      await _load();
    } else {
      _showSnack(AppLocalizations.of(context).memberAddFailed);
    }
  }

  Future<void> _changeRight(ProjectMember member, int right) async {
    if (right == member.right) return;
    setState(() => _busy = true);
    final response = await ref
        .read(projectMemberRepositoryProvider)
        .updateMemberRight(widget.projectId, member.user.id, right);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (response.isSuccessful) {
        _members = _members
            .map((m) => m.user.id == member.user.id ? m.copyWith(right: right) : m)
            .toList();
      } else {
        _showSnack(AppLocalizations.of(context).memberUpdateFailed);
      }
    });
  }

  Future<void> _removeMember(ProjectMember member) async {
    final l10n = AppLocalizations.of(context);
    final name = member.user.name.isNotEmpty
        ? member.user.name
        : member.user.username;
    final confirmed = await showConfirmationDialog(
      context,
      title: l10n.removeMemberConfirmTitle,
      message: l10n.removeMemberConfirm(name),
      confirmLabel: l10n.removeMember,
      cancelLabel: l10n.cancel,
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;

    setState(() => _busy = true);
    final response = await ref
        .read(projectMemberRepositoryProvider)
        .removeMember(widget.projectId, member.user.id);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (response.isSuccessful) {
        _members = _members.where((m) => m.user.id != member.user.id).toList();
      } else {
        _showSnack(l10n.memberRemoveFailed);
      }
    });
  }
}

/// Rollen-Auswahl (Lesen/Schreiben/Admin) als kompaktes Dropdown.
class _RoleDropdown extends StatelessWidget {
  final int right;
  final bool enabled;
  final ValueChanged<int> onChanged;

  const _RoleDropdown({
    required this.right,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DropdownButton<int>(
      value: right,
      underline: const SizedBox.shrink(),
      onChanged: enabled ? (v) => v != null ? onChanged(v) : null : null,
      items: [
        DropdownMenuItem(value: 0, child: Text(l10n.memberRoleRead)),
        DropdownMenuItem(value: 1, child: Text(l10n.memberRoleWrite)),
        DropdownMenuItem(value: 2, child: Text(l10n.memberRoleAdmin)),
      ],
    );
  }
}

class _Hint extends StatelessWidget {
  final String text;

  const _Hint({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.people_outline, color: theme.colorScheme.outline),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ),
      ],
    );
  }
}

/// Rückgabewert des Hinzufügen-Dialogs: gewählter Nutzer + Startrolle.
class _AddMemberResult {
  final User user;
  final int right;

  const _AddMemberResult(this.user, this.right);
}

/// Suchdialog für neue Mitglieder (globale Nutzersuche) mit Rollenauswahl.
class _AddMemberDialog extends ConsumerStatefulWidget {
  final Set<int> excludeUserIds;

  const _AddMemberDialog({required this.excludeUserIds});

  @override
  ConsumerState<_AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends ConsumerState<_AddMemberDialog> {
  List<User> _users = [];
  bool _loading = true;
  int _right = 1; // Standardrolle: Schreiben

  @override
  void initState() {
    super.initState();
    _search('');
  }

  Future<void> _search(String query) async {
    setState(() => _loading = true);
    final response = await ref
        .read(projectMemberRepositoryProvider)
        .searchUsers(query);
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
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.addMember),
      content: SizedBox(
        width: double.maxFinite,
        height: 380,
        child: Column(
          children: [
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: l10n.memberSearchHint,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: _search,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(l10n.memberRole),
                const SizedBox(width: 12),
                _RoleDropdown(
                  right: _right,
                  enabled: true,
                  onChanged: (v) => setState(() => _right = v),
                ),
              ],
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
                          onTap: () => Navigator.of(
                            context,
                          ).pop(_AddMemberResult(user, _right)),
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
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}
