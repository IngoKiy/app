import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vikunja_app/core/di/sync_provider.dart';
import 'package:vikunja_app/core/sync/sync_state.dart';
import 'package:vikunja_app/core/sync/sync_state_provider.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/widgets/sync_status_sheet.dart';

/// Einzige dauerhafte Sync-Anzeige der App: ein kleines Symbol in der
/// Kopfzeile, das **Zustände** meldet — offline, wartende Änderungen,
/// Fehler, Drosselung. Es rotiert bewusst nicht: den laufenden Vorgang
/// zeigt der Pull-to-Refresh-Kreisel, und zwar an genau einer Stelle für
/// alle Auslöser (siehe [syncSpinnerActive]).
///
/// Ist alles synchron und ruhig, verschwindet das Symbol ganz. Antippen
/// öffnet die Detailansicht mit „Jetzt synchronisieren".
class SyncStatusIcon extends ConsumerWidget {
  /// Farbe auf akzentfarbenen Kopfzeilen; sonst Theme-Farben.
  final Color? foregroundColor;

  const SyncStatusIcon({super.key, this.foregroundColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(syncStateNotifierProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final IconData icon;
    final Color color;
    final String tooltip;

    if (state.phase == SyncPhase.error) {
      final raw = state.errorMessage ?? '';
      if (raw.startsWith('rate_limited')) {
        final seconds = int.tryParse(raw.split(':').last) ?? 60;
        icon = Icons.hourglass_top;
        color = theme.colorScheme.error;
        tooltip = l10n.syncRateLimited(seconds);
      } else {
        icon = Icons.cloud_off_outlined;
        color = theme.colorScheme.error;
        tooltip = l10n.syncErrorBanner(raw);
      }
    } else if (state.phase == SyncPhase.offline) {
      icon = Icons.cloud_off_outlined;
      color = foregroundColor ?? theme.colorScheme.onSurfaceVariant;
      tooltip = l10n.offlineBanner;
    } else if (state.pendingOps > 0) {
      icon = Icons.cloud_upload_outlined;
      color = foregroundColor ?? theme.colorScheme.onSurfaceVariant;
      tooltip = l10n.pendingChangesBanner(state.pendingOps);
    } else {
      // Alles synchron: keine Anzeige.
      return const SizedBox.shrink();
    }

    return IconButton(
      tooltip: tooltip,
      onPressed: () => SyncStatusSheet.show(context),
      icon: Badge(
        isLabelVisible: state.pendingOps > 0,
        label: Text('${state.pendingOps}'),
        child: Icon(icon, color: color),
      ),
    );
  }
}

/// Einheitlicher Pull-to-Refresh für alle Listen-Seiten: stößt Push+Pull an
/// und lässt den Kreisel laufen, bis der Sync-Zustand wieder ruhig ist.
///
/// Dadurch zeigt der Kreisel den tatsächlichen Vorgang — auch wenn gerade
/// ein Hintergrund-Sync läuft, in den sich die Geste einklinkt (Single-
/// Flight). Fehler und Drosselung bleiben danach im [SyncStatusIcon] sichtbar.
Future<void> refreshWithSync(WidgetRef ref) async {
  await ref.read(syncServiceProvider).syncNow(userInitiated: true);

  // Falls ein paralleler Durchlauf noch nachläuft: warten, bis der Zustand
  // nicht mehr „syncing" meldet (mit Deckel, damit die Geste nie hängt).
  final deadline = DateTime.now().add(const Duration(seconds: 20));
  while (ref.read(syncStateNotifierProvider).phase == SyncPhase.syncing &&
      DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(const Duration(milliseconds: 120));
  }
}
