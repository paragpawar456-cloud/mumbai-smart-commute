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

  testWidgets('home search resolves stations and plans a journey',
      (tester) async {
    await tester.pumpWidget(await buildTestApp(prefs: {'settings.locale': 'en'}));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('fromField')), 'Kalyan');
    await tester.enterText(find.byKey(const Key('toField')), 'Thane');
    await tester.tap(find.byKey(const Key('findRoutesButton')));
    await tester.pumpAndSettle();

    expect(find.text('Plan a journey'), findsOneWidget);
    expect(find.text('Direct · 7 stops'), findsOneWidget);
    expect(find.text('Board at Kalyan'), findsOneWidget);
    expect(find.text('Get off at Thane'), findsOneWidget);
    // No timetable in the seed pack, so no times are shown, only the notice.
    expect(find.textContaining('Timetable not loaded yet'), findsOneWidget);
    expect(find.textContaining('Next train'), findsNothing);
  });

  testWidgets('saving a journey shows it on Home', (tester) async {
    await tester.pumpWidget(await buildTestApp(prefs: {'settings.locale': 'en'}));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('fromField')), 'Kalyan');
    await tester.enterText(find.byKey(const Key('toField')), 'Andheri');
    await tester.tap(find.byKey(const Key('findRoutesButton')));
    await tester.pumpAndSettle();

    expect(find.text('1 change · 21 stops'), findsOneWidget);
    await tester.tap(find.byKey(const Key('saveJourney')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    expect(find.text('Kalyan → Andheri'), findsOneWidget);
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
