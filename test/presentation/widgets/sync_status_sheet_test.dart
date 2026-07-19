import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/core/di/database_provider.dart';
import 'package:vikunja_app/core/offline/pending_op.dart';
import 'package:vikunja_app/core/sync/connectivity_provider.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/widgets/sync_status_sheet.dart';

class _StubConnectivity extends ConnectivityStatus {
  @override
  bool build() => true;
}

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<int> enqueue(PendingOp op) => db.pendingOpsDao.enqueue(op.toCompanion());

  testWidgets('Sheet zeigt ausstehende und fehlgeschlagene Ops', (tester) async {
    // Eine ausstehende + eine fehlgeschlagene Op.
    await enqueue(
      PendingOp(
        type: PendingOpType.taskCreate,
        localId: -1,
        payload: const {'title': 'Alpha'},
        createdAt: DateTime.now().toUtc().toIso8601String(),
      ),
    );
    final failedId = await enqueue(
      PendingOp(
        type: PendingOpType.taskUpdate,
        localId: 5,
        payload: const {'title': 'Beta'},
        createdAt: DateTime.now().toUtc().toIso8601String(),
      ),
    );
    await db.pendingOpsDao.markError(failedId, 'boom');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          connectivityStatusProvider.overrideWith(() => _StubConnectivity()),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SyncStatusSheet()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Sektionen sichtbar.
    expect(find.text('Pending changes'), findsOneWidget);
    expect(find.text('Failed changes'), findsOneWidget);
    // Op-Titel (Typ-Label · Payload-Titel).
    expect(find.text('New task · Alpha'), findsOneWidget);
    expect(find.text('Edit task · Beta'), findsOneWidget);
    // Fehlermeldung + Verwerfen-Aktion nur bei der failed Op.
    expect(find.text('boom'), findsOneWidget);
    expect(find.text('Discard'), findsOneWidget);
    expect(find.text('Sync now'), findsOneWidget);

    // Widget-Baum abbauen, damit die Drift-Stream-Subscription (Timer) endet.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('Verwerfen entfernt die fehlgeschlagene Op', (tester) async {
    final failedId = await enqueue(
      PendingOp(
        type: PendingOpType.taskUpdate,
        localId: 5,
        payload: const {'title': 'Beta'},
        createdAt: DateTime.now().toUtc().toIso8601String(),
      ),
    );
    await db.pendingOpsDao.markError(failedId, 'boom');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          connectivityStatusProvider.overrideWith(() => _StubConnectivity()),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SyncStatusSheet()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();

    expect(find.text('Edit task · Beta'), findsNothing);
    expect(await db.pendingOpsDao.nextBatch(), isEmpty);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
