import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mumbai_smart_commute/app.dart';
import 'package:mumbai_smart_commute/core/network/api_client.dart';
import 'package:mumbai_smart_commute/core/providers.dart';
import 'package:mumbai_smart_commute/features/account/account_providers.dart';
import 'package:mumbai_smart_commute/features/alerts/alerts.dart';
import 'package:mumbai_smart_commute/features/auth/auth_repository.dart';
import 'package:mumbai_smart_commute/features/settings/settings_controller.dart';
import 'package:mumbai_smart_commute/features/transit/data/data_pack_repository.dart';
import 'package:mumbai_smart_commute/features/transit/data/transit_providers.dart';
import 'package:mumbai_smart_commute/features/transit/domain/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers.dart';

class _FakeAuth implements AuthRepository {
  static const user = AppUser(uid: 'u1', email: 'a@example.com', emailVerified: true);
  @override
  bool get isAvailable => true;
  @override
  Stream<AppUser?> authStateChanges() => Stream.value(user);
  @override
  AppUser? get currentUser => user;
  @override
  Future<String?> idToken() async => 'tok';
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

/// Pretends to be the Apps Script server; [role] is what getProfile returns.
http.Client fakeServer(String role, {String consent = privacyNoticeVersion, List<String>? calls}) =>
    MockClient((req) async {
      final body = jsonDecode(req.body) as Map<String, dynamic>;
      final action = body['action'] as String;
      calls?.add(action);
      final data = switch (action) {
        'getProfile' => {'profile': {'role': role, 'consentVersion': consent}},
        'updateProfile' => {'profile': {'role': role, 'consentVersion': privacyNoticeVersion}},
        'modListReports' => {
            'reports': [
              {'reportId': 'R1', 'type': 'queue', 'targetId': 'KYN', 'note': 'long', 'lat': 19.2, 'lng': 73.1,
               'createdAt': '2026-10-11T07:00:00Z', 'corroborations': 2, 'reporter': 'u9'},
            ]
          },
        'moderateReport' => {'reportId': 'R1', 'status': 'approved'},
        'adminOverview' => {
            'users': {'total': 3, 'active': 3, 'disabled': 0, 'deleted': 0, 'admins': 1, 'moderators': 1},
            'reports': {'pending': 1, 'live': 1},
            'alerts': {'active': 0},
            'dataPack': {'version': 2, 'generatedAt': '2026-10-11T06:00:00Z'},
            'sync': [],
            'roadDistanceEnabled': false,
          },
        'getAlerts' => {'alerts': []},
        'health' => {'status': 'up'},
        _ => <String, dynamic>{},
      };
      return http.Response(jsonEncode({'ok': true, 'data': data}), 200);
    });

Future<Widget> app(String role, {String consent = privacyNoticeVersion, List<String>? calls}) async {
  SharedPreferences.setMockInitialValues({'settings.locale': 'en'});
  final sp = await SharedPreferences.getInstance();
  final client = fakeServer(role, consent: consent, calls: calls);
  return ProviderScope(
    overrides: [
      appConfigProvider.overrideWithValue(testConfig),
      sharedPreferencesProvider.overrideWithValue(sp),
      authRepositoryProvider.overrideWithValue(_FakeAuth()),
      apiClientProvider.overrideWithValue(ApiClient(
          baseUrl: 'https://example.test/exec',
          idTokenProvider: () async => 'tok',
          httpClient: client)),
      dataPackRepositoryProvider.overrideWithValue(DataPackRepository(
        api: ApiClient(baseUrl: '', idTokenProvider: () async => null),
        cacheDir: () async => throw const FileSystemException('no cache in tests'),
        loadBundled: () async => File('assets/data/seed_pack.json').readAsStringSync(),
      )),
    ],
    child: const MumbaiSmartCommuteApp(),
  );
}

Future<void> openProfile(WidgetTester tester) async {
  await tester.tap(find.text('Profile').last);
  await tester.pumpAndSettle();
}

void main() {
  test('profile flags come from the server role', () {
    const admin = ServerProfile(role: 'admin', consentVersion: privacyNoticeVersion);
    const mod = ServerProfile(role: 'moderator', consentVersion: '');
    const user = ServerProfile(role: 'user', consentVersion: privacyNoticeVersion);
    expect([admin.isAdmin, admin.canModerate, admin.needsConsent], [true, true, false]);
    expect([mod.isAdmin, mod.canModerate, mod.needsConsent], [false, true, true]);
    expect([user.isAdmin, user.canModerate], [false, false]);
  });

  test('alerts apply to ALL, the station itself, or a line through it', () {
    final pack = DataPack.fromJson(
        jsonDecode(File('assets/data/seed_pack.json').readAsStringSync()));
    ServiceAlert a(String scope) => ServiceAlert(
        id: 'a', scope: scope, severity: 'minor', titleEn: 't', body: '',
        startsAt: DateTime(2026), sourceUrl: 'https://x');
    expect(a('ALL').appliesToStation(pack, 'KYN'), isTrue);
    expect(a('KYN').appliesToStation(pack, 'KYN'), isTrue);
    expect(a('CR-MAIN').appliesToStation(pack, 'KYN'), isTrue);
    expect(a('MML1').appliesToStation(pack, 'KYN'), isFalse);
    expect(a('TNA').appliesToStation(pack, 'KYN'), isFalse);
  });

  testWidgets('a normal user sees no admin entry', (tester) async {
    await tester.pumpWidget(await app('user'));
    await tester.pumpAndSettle();
    await openProfile(tester);
    expect(find.byKey(const Key('adminTile')), findsNothing);
    expect(find.text('Privacy notice'), findsOneWidget);
  });

  testWidgets('a moderator only gets the Reports tab and can approve', (tester) async {
    final calls = <String>[];
    await tester.pumpWidget(await app('moderator', calls: calls));
    await tester.pumpAndSettle();
    await openProfile(tester);
    await tester.tap(find.byKey(const Key('adminTile')));
    await tester.pumpAndSettle();
    expect(find.text('Reports'), findsOneWidget);
    expect(find.text('Users'), findsNothing);
    expect(find.text('Audit log'), findsNothing);
    expect(find.text('queue · KYN'), findsOneWidget);
    await tester.tap(find.text('Approve'));
    await tester.pumpAndSettle();
    expect(calls, contains('moderateReport'));
    expect(calls, isNot(contains('adminOverview')));
  });

  testWidgets('an admin sees every tab, starting with the overview', (tester) async {
    await tester.pumpWidget(await app('admin'));
    await tester.pumpAndSettle();
    await openProfile(tester);
    await tester.tap(find.byKey(const Key('adminTile')));
    await tester.pumpAndSettle();
    for (final t in ['Overview', 'Reports', 'Users', 'Alerts', 'Audit log']) {
      expect(find.text(t), findsOneWidget);
    }
    expect(find.text('Active users'), findsOneWidget);
  });

  testWidgets('the admin route itself refuses non-moderators', (tester) async {
    await tester.pumpWidget(await app('user'));
    await tester.pumpAndSettle();
    GoRouter.of(tester.element(find.byType(Scaffold).first)).push('/admin');
    await tester.pumpAndSettle();
    expect(find.text('This section is for admins and moderators.'), findsOneWidget);
  });

  testWidgets('consent is asked once and recorded on the server', (tester) async {
    final calls = <String>[];
    await tester.pumpWidget(await app('user', consent: '', calls: calls));
    await tester.pumpAndSettle();
    await openProfile(tester);
    await tester.tap(find.byKey(const Key('acceptPrivacy')));
    await tester.pumpAndSettle();
    expect(calls, contains('updateProfile'));
  });
}
