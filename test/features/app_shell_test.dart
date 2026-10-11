import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  testWidgets('home shows search and all five tabs', (tester) async {
    await tester.pumpWidget(await buildTestApp(prefs: {'settings.locale': 'en'}));
    await tester.pumpAndSettle();

    expect(find.text('Where are you going?'), findsOneWidget);
    for (final tab in ['Home', 'Routes', 'Live Map', 'Saved', 'Profile']) {
      expect(find.text(tab), findsWidgets);
    }
  });

  testWidgets('searching opens Routes with the query', (tester) async {
    await tester.pumpWidget(await buildTestApp(prefs: {'settings.locale': 'en'}));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('fromField')), 'Kalyan');
    await tester.enterText(
        find.byKey(const Key('toField')), 'Yogidham, Kalyan West');
    await tester.tap(find.byKey(const Key('findRoutesButton')));
    await tester.pumpAndSettle();

    expect(find.text('Plan a journey'), findsOneWidget);
    expect(find.text('Kalyan  →  Yogidham, Kalyan West'), findsOneWidget);
  });

  testWidgets('saved language is applied (Marathi)', (tester) async {
    await tester.pumpWidget(await buildTestApp(prefs: {'settings.locale': 'mr'}));
    await tester.pumpAndSettle();
    expect(find.text('तुम्ही कुठे जात आहात?'), findsOneWidget);
  });

  testWidgets('Hindi is available', (tester) async {
    await tester.pumpWidget(await buildTestApp(prefs: {'settings.locale': 'hi'}));
    await tester.pumpAndSettle();
    expect(find.text('आप कहाँ जा रहे हैं?'), findsOneWidget);
  });

  testWidgets('profile works in guest mode without Firebase or backend',
      (tester) async {
    await tester.pumpWidget(await buildTestApp(prefs: {'settings.locale': 'en'}));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();

    expect(find.text('Not signed in'), findsOneWidget);
    expect(find.text('Server not configured in this build'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Sign-in is not configured in this build.'), findsOneWidget);
  });
}
