import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vikunja_app/core/sync/sync_state.dart';
import 'package:vikunja_app/core/sync/sync_state_provider.dart';
import 'package:vikunja_app/core/theming/app_colors.dart';
import 'package:vikunja_app/core/theming/app_theme.dart';
import 'package:vikunja_app/core/theming/theme.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/widgets/sync_status_banner.dart';

class _FixedSyncStateNotifier extends SyncStateNotifier {
  final SyncState _state;
  _FixedSyncStateNotifier(this._state);

  @override
  SyncState build() => _state;
}

Widget _banner(SyncState state) => ProviderScope(
  overrides: [
    syncStateNotifierProvider.overrideWith(
      () => _FixedSyncStateNotifier(state),
    ),
  ],
  child: Localizations(
    delegates: AppLocalizations.localizationsDelegates,
    locale: const Locale('en'),
    child: const SyncStatusBanner(),
  ),
);

GoldenTestGroup _bannerScenarios() => GoldenTestGroup(
  scenarioConstraints: const BoxConstraints(maxWidth: 360),
  children: [
    GoldenTestScenario(
      name: 'offline',
      child: _banner(const SyncState(phase: SyncPhase.offline)),
    ),
    GoldenTestScenario(
      name: 'syncing',
      child: _banner(const SyncState(phase: SyncPhase.syncing)),
    ),
    GoldenTestScenario(
      name: 'error',
      child: _banner(
        const SyncState(
          phase: SyncPhase.error,
          errorMessage: 'Connection refused',
        ),
      ),
    ),
    GoldenTestScenario(
      name: 'pending changes',
      child: _banner(const SyncState(pendingOps: 3)),
    ),
  ],
);

void main() {
  goldenTest(
    'Sync status banner (light)',
    fileName: 'sync_status_banner_light',
    pumpBeforeTest: pumpOnce,
    builder: _bannerScenarios,
  );

  AlchemistConfig.runWithConfig(
    config: AlchemistConfig.current().merge(
      AlchemistConfig(
        theme: buildAppTheme(
          colorScheme: MaterialTheme.darkScheme(),
          appColors: AppColors.dark,
        ),
      ),
    ),
    run: () => goldenTest(
      'Sync status banner (dark)',
      fileName: 'sync_status_banner_dark',
      pumpBeforeTest: pumpOnce,
      builder: _bannerScenarios,
    ),
  );
}
