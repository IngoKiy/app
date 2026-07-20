import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/core/di/database_provider.dart';
import 'package:vikunja_app/core/di/repository_provider.dart';
import 'package:vikunja_app/core/network/response.dart';
import 'package:vikunja_app/core/sync/connectivity_provider.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/domain/entities/project_member.dart';
import 'package:vikunja_app/domain/entities/user.dart';
import 'package:vikunja_app/domain/repositories/project_member_repository.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/widgets/project_members_section.dart';

import '../../data/local/test_database.dart';

class _OnlineConnectivity extends ConnectivityStatus {
  @override
  bool build() => true;
}

class _FakeMemberRepository implements ProjectMemberRepository {
  final List<ProjectMember> members;
  final List<User> searchResults;
  int removeCalls = 0;
  int addCalls = 0;
  int updateCalls = 0;

  _FakeMemberRepository({this.members = const [], this.searchResults = const []});

  @override
  Future<Response<List<ProjectMember>>> getMembers(int projectId) async =>
      SuccessResponse<List<ProjectMember>>(members, 200, const {});

  @override
  Future<Response<Object>> addMember(
    int projectId,
    String username,
    int right,
  ) async {
    addCalls++;
    return VoidResponse<Object>();
  }

  @override
  Future<Response<Object>> updateMemberRight(
    int projectId,
    int userId,
    int right,
  ) async {
    updateCalls++;
    return VoidResponse<Object>();
  }

  @override
  Future<Response<Object>> removeMember(int projectId, int userId) async {
    removeCalls++;
    return VoidResponse<Object>();
  }

  @override
  Future<Response<List<User>>> searchUsers(String query) async =>
      SuccessResponse<List<User>>(searchResults, 200, const {});
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  Widget wrap(_FakeMemberRepository repo) {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        connectivityStatusProvider.overrideWith(() => _OnlineConnectivity()),
        projectMemberRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: const Scaffold(
          body: ProjectMembersSection(projectId: 7),
        ),
      ),
    );
  }

  User user(int id, String name, String username) =>
      User(id: id, name: name, username: username);

  testWidgets('rendert Mitglieder mit Namen und Rollen-Badge', (tester) async {
    final repo = _FakeMemberRepository(
      members: [
        ProjectMember(user: user(1, 'Alice', 'alice'), right: 2),
        ProjectMember(user: user(2, 'Bob', 'bob'), right: 0),
      ],
    );

    await tester.pumpWidget(wrap(repo));
    await tester.pump(); // post-frame load
    await tester.pump();

    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
    // Rollen-Dropdowns zeigen die aktuelle Rolle.
    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('Read'), findsOneWidget);
  });

  testWidgets('Hinzufügen-Dialog öffnet über das Personen-Icon', (tester) async {
    final repo = _FakeMemberRepository(
      members: [ProjectMember(user: user(1, 'Alice', 'alice'), right: 1)],
      searchResults: [user(9, 'Dave', 'dave')],
    );

    await tester.pumpWidget(wrap(repo));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byIcon(Icons.person_add_alt));
    await tester.pump();
    await tester.pump();

    // Dialog offen: Titel + Suchergebnis.
    expect(find.text('Add member'), findsWidgets);
    expect(find.text('Dave'), findsOneWidget);
  });

  testWidgets('Entfernen zeigt Bestätigungsdialog', (tester) async {
    final repo = _FakeMemberRepository(
      members: [ProjectMember(user: user(1, 'Alice', 'alice'), right: 1)],
    );

    await tester.pumpWidget(wrap(repo));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pump();

    // Bestätigung erscheint, Repo wurde noch NICHT aufgerufen.
    expect(find.text('Remove member?'), findsOneWidget);
    expect(repo.removeCalls, 0);
  });

  testWidgets('Offline zeigt nur den Hinweis', (tester) async {
    final repo = _FakeMemberRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          projectMemberRepositoryProvider.overrideWithValue(repo),
          // connectivity NICHT als online überschrieben → default build startet
          // Plattformkanäle; deshalb hier ein Offline-Stub.
          connectivityStatusProvider.overrideWith(() => _OfflineConnectivity()),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const Scaffold(body: ProjectMembersSection(projectId: 7)),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Member management is only available online'),
        findsOneWidget);
  });
}

class _OfflineConnectivity extends ConnectivityStatus {
  @override
  bool build() => false;
}
