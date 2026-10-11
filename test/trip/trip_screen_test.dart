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
    expect(find.textContaining('ways to go'), findsOneWidget);
    for (final k in ['option-auto', 'option-cab', 'option-train']) {
      await tester.scrollUntilVisible(find.byKey(Key(k)), 200,
          scrollable: find.byType(Scrollable).first);
      expect(find.byKey(Key(k)), findsOneWidget);
    }
    expect(find.text('Train + auto'), findsOneWidget);

    // The train option: steps, then the train list (no timetable yet).
    await tester.tap(find.byKey(const Key('option-train')));
    await tester.pumpAndSettle();
    expect(find.text('Auto to Kalyan'), findsOneWidget);
    expect(find.text('Board at Kalyan'), findsOneWidget);
    await tester.scrollUntilVisible(
        find.textContaining("Train times aren't loaded yet"), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Trains Kalyan → Dombivli'), findsOneWidget);
    expect(find.textContaining('Next train'), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Auto all the way, then "Where is my auto": stands, never a fake auto.
    await tester.scrollUntilVisible(find.byKey(const Key('option-auto')), -200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.byKey(const Key('option-auto')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('whereButton')));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(find.text('Auto stands near Yogidham'), findsOneWidget);
    expect(find.textContaining('no live tracking'), findsOneWidget);
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

  testWidgets('Home shortcut: where is my bus says when there is no data',
      (tester) async {
    await tester.pumpWidget(await buildTestApp(prefs: {'settings.locale': 'en'}));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('whereBus')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Khadakpada');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Khadakpada'));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(find.text('Bus stops near Khadakpada'), findsOneWidget);
    expect(find.textContaining('no live location'), findsOneWidget);
  });
}
