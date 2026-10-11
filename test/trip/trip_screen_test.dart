import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mumbai_smart_commute/features/trip/data/geocoder.dart';

import '../features/app_shell_test.dart' show pickPlace;
import '../helpers.dart';
import 'geocoder_test.dart' show photonAnswer;

void main() {
  testWidgets('Yogidham to a building found online plans door to door',
      (tester) async {
    final geocoder = Geocoder(
      baseUrl: 'https://photon.example/api/',
      userAgent: 'test',
      client: MockClient((_) async =>
          http.Response.bytes(utf8.encode(jsonEncode(photonAnswer)), 200)),
    );
    await tester.pumpWidget(await buildTestApp(
      prefs: {'settings.locale': 'en'},
      overrides: [geocoderProvider.overrideWithValue(geocoder)],
    ));
    await tester.pumpAndSettle();

    // From the app's own places.
    await pickPlace(tester, 'fromField', 'yogidham', 'Yogidham');
    // Not in the app: comes from OpenStreetMap after a short pause.
    await tester.tap(find.byKey(const Key('toField')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'runwal');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    expect(find.text('More places (OpenStreetMap)'), findsOneWidget);
    await tester.tap(find.widgetWithText(ListTile, 'Runwal Garden City'));
    await tester.pumpAndSettle();

    expect(find.text('Yogidham'), findsOneWidget);
    expect(find.text('Runwal Garden City'), findsOneWidget);
    await tester.tap(find.byKey(const Key('findRoutesButton')));
    await tester.pumpAndSettle();

    expect(find.text('Your journey'), findsOneWidget);
    // Under 8 km, so road options come first and the train follows.
    expect(find.text('Direct by road'), findsOneWidget);
    final list = find.byType(Scrollable).first;
    for (final t in [
      'By train',
      'Get to Kalyan station',
      'Board at Kalyan',
      'Get off at Dombivli',
      'Dombivli station to Runwal Garden City',
    ]) {
      await tester.scrollUntilVisible(find.text(t), 300, scrollable: list);
      expect(find.text(t), findsOneWidget);
    }
  });

  testWidgets('offline: online search failure is explained, local results stay',
      (tester) async {
    final geocoder = Geocoder(
      baseUrl: 'https://photon.example/api/',
      userAgent: 'test',
      client: MockClient((_) async => throw http.ClientException('offline')),
    );
    await tester.pumpWidget(await buildTestApp(
      prefs: {'settings.locale': 'en'},
      overrides: [geocoderProvider.overrideWithValue(geocoder)],
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('toField')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'kalyan');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListTile, 'Kalyan'), findsOneWidget);
    expect(find.textContaining("Couldn't search online"), findsOneWidget);
  });

  testWidgets('Find routes with nothing chosen opens the search',
      (tester) async {
    await tester.pumpWidget(await buildTestApp(prefs: {'settings.locale': 'en'}));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('findRoutesButton')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('useMyLocation')), findsOneWidget);
  });
}
