import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mumbai_smart_commute/features/lastmile/data/lastmile_providers.dart';
import 'package:mumbai_smart_commute/features/lastmile/domain/lastmile_models.dart';

import '../helpers.dart';

void main() {
  test('seed pack carries Kalyan places, stands, fare rules and providers', () {
    final j = jsonDecode(File('assets/data/seed_pack.json').readAsStringSync())
        as Map<String, dynamic>;
    final d = LastMileData.fromPackJson(j);
    expect(d.places.map((p) => p.nameEn), contains('Yogidham'));
    expect(d.pickupPoints, isNotEmpty);
    expect(d.fareRules.map((f) => f.mode), containsAll(['auto', 'taxi']));
    expect(d.providers.map((p) => p.id), containsAll(['uber', 'ola', 'rapido']));
    expect(searchPlaces(d, 'yogi').first.nameEn, 'Yogidham');
    expect(searchPlaces(d, 'योगी').first.nameEn, 'Yogidham');
    final uber = d.providers.firstWhere((p) => p.id == 'uber').bookingUri(
        const GeoPoint(19.2358, 73.1308), const GeoPoint(19.2473, 73.1530),
        toName: 'Yogidham');
    expect(uber.toString(), startsWith('https://m.uber.com/ul/'));
    expect(uber!.queryParameters['dropoff[latitude]'], '19.247300');
    expect(uber.queryParameters['dropoff[nickname]'], 'Yogidham');
  });

  testWidgets('Kalyan to Yogidham shows estimated options with sources',
      (tester) async {
    await tester.pumpWidget(await buildTestApp(prefs: {'settings.locale': 'en'}));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('lastMileCard')));
    await tester.pumpAndSettle();
    expect(find.text('Kalyan'), findsOneWidget);
    expect(find.text('Choose where you are going to see your options.'),
        findsOneWidget);

    await tester.tap(find.byKey(const Key('lastMileTo')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Yogidham');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Yogidham'));
    await tester.pumpAndSettle();

    expect(find.textContaining('by road (estimated)'), findsOneWidget);
    expect(find.text('Auto (by meter)'), findsOneWidget);
    expect(find.textContaining('≈ ₹'), findsWidgets);
    expect(find.text('Estimate'), findsWidgets);
    await tester.scrollUntilVisible(find.text('Uber'), 300);
    expect(find.text('Uber'), findsOneWidget);
    expect(find.text('Price in their app'), findsWidgets);
    // No server in this build: the reports section and its sign-in prompts
    // are left out entirely.
    await tester.scrollUntilVisible(find.text('Stands near the station'), 300);
    expect(find.text('Commuter reports'), findsNothing);
    expect(find.byKey(const Key('reportButton')), findsNothing);
  });
}
