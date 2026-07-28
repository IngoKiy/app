import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vikunja_app/domain/entities/smart_list.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/manager/smart_list_providers.dart';
import 'package:vikunja_app/presentation/manager/todo_prefs.dart';
import 'package:vikunja_app/presentation/pages/task/smart_list_page.dart';

/// Anzeige-Eigenschaften einer Smart-List im Stil von Microsoft To Do.
///
/// [color] ist die Icon-Farbe in der Übersicht, [pageColor] der vollflächige
/// Seiten-Hintergrund und [pageAccent] die Akzentfarbe für Titel, Chip und
/// Sterne AUF der Seite. Bei dunklen Flächen sind pageColor/pageAccent gleich
/// [color]; „Geplant" nutzt wie das Vorbild eine helle Mint-Fläche mit
/// dunklem Teal als Akzent.
({String title, IconData icon, Color color, Color pageColor, Color pageAccent})
smartListLook(BuildContext context, SmartList list) {
  final l10n = AppLocalizations.of(context);
  switch (list) {
    case SmartList.today:
      final c = Colors.amber.shade700;
      return (
        title: l10n.smartListMyDay,
        icon: Icons.wb_sunny_outlined,
        color: c,
        pageColor: c,
        pageAccent: c,
      );
    case SmartList.important:
      final c = Colors.pink.shade400;
      return (
        title: l10n.smartListImportant,
        icon: Icons.star_border,
        color: c,
        pageColor: c,
        pageAccent: c,
      );
    case SmartList.planned:
      // Helle Akzent-Variante wie in To Do (Mint-Fläche, dunkles Teal).
      return (
        title: l10n.smartListPlanned,
        icon: Icons.calendar_today_outlined,
        color: Colors.teal.shade600,
        pageColor: const Color(0xFFD4F1EF),
        pageAccent: const Color(0xFF166F6B),
      );
    case SmartList.assignedToMe:
      final c = Colors.deepOrange.shade400;
      return (
        title: l10n.smartListAssigned,
        icon: Icons.person_outline,
        color: c,
        pageColor: c,
        pageAccent: c,
      );
    case SmartList.all:
      final c = Colors.indigo.shade400;
      return (
        title: l10n.smartListAll,
        icon: Icons.all_inclusive,
        color: c,
        pageColor: c,
        pageAccent: c,
      );
    case SmartList.completed:
      final c = Colors.red.shade400;
      return (
        title: l10n.smartListCompleted,
        icon: Icons.check_circle_outline,
        color: c,
        pageColor: c,
        pageAccent: c,
      );
  }
}

/// Smart-List-Block für die Listen-Übersicht: eine Zeile je Liste mit Icon,
/// Titel und Live-Zähler; Tipp öffnet die jeweilige Aufgabenliste.
class SmartListSection extends ConsumerWidget {
  const SmartListSection({super.key});

  /// Anzeige-Reihenfolge wie in Microsoft To Do: Mein Tag, Wichtig, Geplant,
  /// Alle, Abgeschlossen, Mir zugewiesen.
  static const _displayOrder = [
    SmartList.today,
    SmartList.important,
    SmartList.planned,
    SmartList.all,
    SmartList.completed,
    SmartList.assignedToMe,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final list in _displayOrder) _SmartListTile(list: list),
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

    // In den Einstellungen abgeschaltete bzw. (optional) leere Smart-Lists
    // werden wie in To Do ausgeblendet.
    final enabled =
        ref.watch(smartListEnabledProvider(list.name)).value ?? true;
    final hideEmpty = ref.watch(hideEmptySmartListsProvider).value ?? false;
    if (!enabled) return const SizedBox.shrink();
    if (hideEmpty && list != SmartList.completed && (count ?? 0) == 0) {
      return const SizedBox.shrink();
    }

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
