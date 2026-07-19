import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/core/sync/sync_state.dart';
import 'package:vikunja_app/core/sync/sync_state_provider.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/widgets/sync_status_banner.dart';

class _FakeSyncStateNotifier extends SyncStateNotifier {
  final SyncState _state;
  _FakeSyncStateNotifier(this._state);

  @override
  SyncState build() => _state;
}

Future<void> _pumpBanner(WidgetTester tester, SyncState state) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        syncStateNotifierProvider.overrideWith(
          () => _FakeSyncStateNotifier(state),
        ),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('en'),
        home: Scaffold(body: SyncStatusBanner()),
      ),
    ),
  );
  // Not pumpAndSettle(): the syncing state renders an indeterminate
  // LinearProgressIndicator, whose animation never settles. A single pump
  // past the banner's 200ms enter transition is enough.
  await tester.pump(const Duration(milliseconds: 250));
}

void main() {
  testWidgets('hides when idle with no pending ops', (tester) async {
    await _pumpBanner(tester, const SyncState());

    expect(find.byType(SyncStatusBanner), findsOneWidget);
    expect(find.text('Syncing…'), findsNothing);
    expect(find.textContaining('Offline'), findsNothing);
  });

  testWidgets('shows offline message when offline', (tester) async {
    await _pumpBanner(tester, const SyncState(phase: SyncPhase.offline));

    expect(
      find.text("Offline — changes will sync once you're back online"),
      findsOneWidget,
    );
  });

  testWidgets('shows syncing message and progress indicator', (tester) async {
    await _pumpBanner(tester, const SyncState(phase: SyncPhase.syncing));

    expect(find.text('Syncing…'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('shows error message', (tester) async {
    await _pumpBanner(
      tester,
      const SyncState(phase: SyncPhase.error, errorMessage: 'network down'),
    );

    expect(find.text('Sync failed: network down'), findsOneWidget);
  });

  testWidgets('shows pending changes count while online', (tester) async {
    await _pumpBanner(tester, const SyncState(pendingOps: 4));

    expect(find.text('4 changes pending'), findsOneWidget);
  });
}
