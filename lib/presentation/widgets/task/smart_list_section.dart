import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vikunja_app/domain/entities/smart_list.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/manager/smart_list_providers.dart';
import 'package:vikunja_app/presentation/pages/task/smart_list_page.dart';

/// Anzeige-Eigenschaften einer Smart-List (Titel, Icon, Akzentfarbe) im Stil
/// von Microsoft To Do.
({String title, IconData icon, Color color}) smartListLook(
  BuildContext context,
  SmartList list,
) {
  final l10n = AppLocalizations.of(context);
  switch (list) {
    case SmartList.today:
      return (
        title: l10n.smartListMyDay,
        icon: Icons.wb_sunny_outlined,
        color: Colors.amber.shade700,
      );
    case SmartList.important:
      return (
        title: l10n.smartListImportant,
        icon: Icons.star_border,
        color: Colors.pink.shade400,
      );
    case SmartList.planned:
      return (
        title: l10n.smartListPlanned,
        icon: Icons.calendar_today_outlined,
        color: Colors.teal.shade600,
      );
    case SmartList.all:
      return (
        title: l10n.smartListAll,
        icon: Icons.all_inclusive,
        color: Colors.indigo.shade400,
      );
    case SmartList.completed:
      return (
        title: l10n.smartListCompleted,
        icon: Icons.check_circle_outline,
        color: Colors.red.shade400,
      );
  }
}

/// Smart-List-Block für die Listen-Übersicht: eine Zeile je Liste mit Icon,
/// Titel und Live-Zähler; Tipp öffnet die jeweilige Aufgabenliste.
class SmartListSection extends ConsumerWidget {
  const SmartListSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final list in SmartList.values) _SmartListTile(list: list),
        const Divider(),
      ],
    );
  }
}

class _SmartListTile extends ConsumerWidget {
  final SmartList list;

  const _SmartListTile({required this.list});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final look = smartListLook(context, list);
    // "Erledigt" bekommt wie im Vorbild keinen Zähler.
    final count = list == SmartList.completed
        ? null
        : ref.watch(smartListCountProvider(list)).value;

    return ListTile(
      leading: Icon(look.icon, color: look.color),
      title: Text(look.title),
      trailing: (count != null && count > 0)
          ? Text(
              '$count',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SmartListPage(list: list)),
        );
      },
    );
  }
}
