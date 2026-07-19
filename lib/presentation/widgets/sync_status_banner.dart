import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vikunja_app/core/sync/sync_state.dart';
import 'package:vikunja_app/core/sync/sync_state_provider.dart';
import 'package:vikunja_app/core/theming/dimensions.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/widgets/sync_status_sheet.dart';

/// Global, narrow banner surfacing the app's sync/offline status.
///
/// Hidden entirely while the sync engine is idle with nothing pending; only
/// appears for [SyncPhase.offline]/[SyncPhase.syncing]/[SyncPhase.error], or
/// when there are outstanding pending operations while online. Mounted once
/// in [MaterialApp.builder] (see `lib/main.dart`) so it is visible above
/// every screen.
///
/// A user-triggered sync (pull-to-refresh, "sync now" in the sync sheet) is
/// treated like [SyncPhase.idle] here: the widget that triggered it
/// (RefreshIndicator, sheet button) already shows its own progress, so the
/// banner would otherwise duplicate it.
class SyncStatusBanner extends ConsumerWidget {
  const SyncStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rawState = ref.watch(syncStateNotifierProvider);
    final syncState =
        rawState.phase == SyncPhase.syncing && rawState.userInitiated
        ? rawState.copyWith(phase: SyncPhase.idle)
        : rawState;
    final visible =
        syncState.phase != SyncPhase.idle || syncState.pendingOps > 0;

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: visible
            ? _SyncBannerContent(
                key: ValueKey('sync-banner-${_variantKey(syncState)}'),
                state: syncState,
              )
            : const SizedBox(
                width: double.infinity,
                key: ValueKey('sync-banner-hidden'),
              ),
      ),
    );
  }

  static String _variantKey(SyncState state) {
    switch (state.phase) {
      case SyncPhase.offline:
        return 'offline';
      case SyncPhase.syncing:
        return 'syncing';
      case SyncPhase.error:
        return 'error';
      case SyncPhase.idle:
        return 'pending';
    }
  }
}

class _SyncBannerContent extends StatelessWidget {
  final SyncState state;

  const _SyncBannerContent({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);

    final Color background;
    final Color foreground;
    final String message;

    switch (state.phase) {
      case SyncPhase.offline:
        background = colorScheme.tertiaryContainer;
        foreground = colorScheme.onTertiaryContainer;
        message = loc.offlineBanner;
        break;
      case SyncPhase.syncing:
        background = colorScheme.secondaryContainer;
        foreground = colorScheme.onSecondaryContainer;
        message = loc.syncingBanner;
        break;
      case SyncPhase.error:
        background = colorScheme.errorContainer;
        foreground = colorScheme.onErrorContainer;
        message = loc.syncErrorBanner(state.errorMessage ?? '');
        break;
      case SyncPhase.idle:
        background = colorScheme.secondaryContainer;
        foreground = colorScheme.onSecondaryContainer;
        message = loc.pendingChangesBanner(state.pendingOps);
        break;
    }

    return Semantics(
      liveRegion: true,
      container: true,
      button: true,
      child: Material(
        color: background,
        child: InkWell(
          onTap: () => SyncStatusSheet.show(context),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.md,
                vertical: AppDimensions.xs,
              ),
              child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(color: foreground),
                  textAlign: TextAlign.center,
                ),
                if (state.phase == SyncPhase.syncing) ...[
                  const SizedBox(height: AppDimensions.xxs),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.xxs),
                    child: SizedBox(
                      height: 3,
                      child: LinearProgressIndicator(
                        minHeight: 3,
                        backgroundColor: foreground.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(foreground),
                      ),
                    ),
                  ),
                ],
              ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
