import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/core/sync/sync_state.dart';
import 'package:vikunja_app/core/sync/sync_state_provider.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/widgets/sync_status_icon.dart';

/// Setzt einen festen Sync-Zustand für den Test.
class _StubSyncState extends SyncStateNotifier {
  _StubSyncState(this._initial);
  final SyncState _initial;

  @override
  SyncState build() => _initial;
}

Future<void> _pump(WidgetTester tester, SyncState state) => tester.pumpWidget(
  ProviderScope(
    overrides: [
      syncStateNotifierProvider.overrideWith(() => _StubSyncState(state)),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: const Scaffold(body: SyncStatusIcon()),
    ),
  ),
);

void main() {
  testWidgets('synchron und ruhig → keine Anzeige', (tester) async {
    await _pump(tester, const SyncState());
    expect(find.byType(IconButton), findsNothing);
  });

  testWidgets('laufender Sync erzeugt KEIN zweites Zustandssymbol', (
    tester,
  ) async {
    // Den Vorgang zeigt allein der Pull-to-Refresh-Kreisel.
    await _pump(tester, const SyncState(phase: SyncPhase.syncing));
    expect(find.byType(IconButton), findsNothing);
  });

  testWidgets('wartende Änderungen zeigen Wolke mit Anzahl', (tester) async {
    await _pump(tester, const SyncState(pendingOps: 3));
    expect(find.byIcon(Icons.cloud_upload_outlined), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('offline zeigt durchgestrichene Wolke', (tester) async {
    await _pump(tester, const SyncState(phase: SyncPhase.offline));
    expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
  });

  testWidgets('Drosselung zeigt Sanduhr', (tester) async {
    await _pump(
      tester,
      const SyncState(phase: SyncPhase.error, errorMessage: 'rate_limited:45'),
    );
    expect(find.byIcon(Icons.hourglass_top), findsOneWidget);
  });
}
