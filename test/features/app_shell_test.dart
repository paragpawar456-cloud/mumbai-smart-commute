import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

/// Opens a Home field's place search, types [query] and picks [name].
Future<void> pickPlace(
    WidgetTester tester, String field, String query, String name) async {
  await tester.tap(find.byKey(Key(field)));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField).last, query);
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(ListTile, name).first);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('home shows search and all five tabs', (tester) async {
    await tester.pumpWidget(await buildTestApp(prefs: {'settings.locale': 'en'}));
    await tester.pumpAndSettle();

    expect(find.text('Where are you going?'), findsOneWidget);
    for (final tab in ['Home', 'Routes', 'Live Map', 'Saved', 'Profile']) {
      expect(find.text(tab), findsWidgets);
    }
    for (final k in ['whereTrain', 'whereAuto', 'whereBus', 'whereCab']) {
      expect(find.byKey(Key(k)), findsOneWidget);
    }
  });

  testWidgets('home shows the next trains from Kalyan, counting down',
      (tester) async {
    await tester.pumpWidget(await buildTestApp(prefs: {'settings.locale': 'en'}));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('nextTrainsCard')));
    expect(find.text('Next trains from Kalyan'), findsOneWidget);
    // Monday 09:00 in tests: the first train leaves at 09:02.
    expect(find.text('09:02'), findsWidgets);
    expect(find.text('in 2 min'), findsWidgets);
    expect(find.text('Check the station display before you travel'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('buildLabel')));
    expect(find.text('Local build'), findsOneWidget);
  });

  testWidgets('home search resolves stations and plans a journey',
      (tester) async {
    await tester.pumpWidget(await buildTestApp(prefs: {'settings.locale': 'en'}));
    await tester.pumpAndSettle();

    await pickPlace(tester, 'fromField', 'Kalyan', 'Kalyan');
    await pickPlace(tester, 'toField', 'Thane', 'Thane');
    await tester.tap(find.byKey(const Key('findRoutesButton')));
    await tester.pumpAndSettle();

    expect(find.text('Plan a journey'), findsOneWidget);
    expect(find.text('Direct · 7 stops'), findsOneWidget);
    expect(find.text('Board at Kalyan'), findsOneWidget);
    expect(find.text('Get off at Thane'), findsOneWidget);
    // Times come from the official timetable in the seed pack.
    expect(find.textContaining('Timetable not loaded yet'), findsNothing);
    expect(find.textContaining('Next train'), findsWidgets);
  });

  testWidgets('saving a journey shows it on Home', (tester) async {
    await tester.pumpWidget(await buildTestApp(prefs: {'settings.locale': 'en'}));
    await tester.pumpAndSettle();
    await pickPlace(tester, 'fromField', 'Kalyan', 'Kalyan');
    await pickPlace(tester, 'toField', 'Andheri', 'Andheri');
    await tester.tap(find.byKey(const Key('findRoutesButton')));
    await tester.pumpAndSettle();

    expect(find.text('1 change · 21 stops'), findsOneWidget);
    await tester.tap(find.byKey(const Key('saveJourney')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -400));
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

    // Accounts aren't set up in this build, so no sign-in appears anywhere.
    expect(find.text('Sign in'), findsNothing);
    expect(find.text('Not signed in'), findsNothing);
    expect(find.text('Delete account'), findsNothing);
    expect(find.text('Server not configured in this build'), findsNothing);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Privacy notice'), findsOneWidget);
  });
}
