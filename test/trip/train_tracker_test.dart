import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mumbai_smart_commute/core/providers.dart';
import 'package:mumbai_smart_commute/features/settings/settings_controller.dart';
import 'package:mumbai_smart_commute/features/transit/domain/timetable.dart';
import 'package:mumbai_smart_commute/features/trip/domain/train_tracker.dart';
import 'package:mumbai_smart_commute/features/trip/ui/where_is_my_train_screen.dart';
import 'package:mumbai_smart_commute/l10n/gen/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../transit/timetable_test.dart' show fixture;

// The fixture's times are made up for tests only: t1 leaves A 08:00,
// reaches B 08:05, leaves B 08:06, reaches C 08:12.
void main() {
  final pack = fixture();
  final tt = Timetable(pack);
  final monday = DateTime(2026, 10, 12);
  final stops = tt.stopsOf('t1');
  double at(int h, int m, [int s = 0]) => h * 60 + m + s / 60;

  test('position follows the timetable', () {
    expect(trainPositionAt(stops, at(7, 59)).phase, TrainPhase.notStarted);
    final moving = trainPositionAt(stops, at(8, 2));
    expect(moving.phase, TrainPhase.moving);
    expect(moving.index, 0);
    expect(moving.fraction, closeTo(0.4, 1e-9));
    final atB = trainPositionAt(stops, at(8, 5, 30));
    expect(atB.phase, TrainPhase.atStation);
    expect(atB.index, 1);
    expect(trainPositionAt(stops, at(8, 9)).progress, closeTo(1.5, 1e-9));
    expect(trainPositionAt(stops, at(8, 12, 30)).phase, TrainPhase.atStation);
    expect(trainPositionAt(stops, at(8, 20)).phase, TrainPhase.finished);
    expect(minutesUntil(stops, 1, at(8, 2)), 3);
  });

  test('runs between two stations, in order, after a time', () {
    final runs = tt.runsBetween('B', 'C', monday);
    expect(runs.map((r) => r.trip.id), ['t1', 't2']);
    expect(runs.first.departure, 8 * 60 + 6);
    expect(runs.first.arrival, 8 * 60 + 12);
    expect(tt.runsBetween('C', 'B', monday), isEmpty, reason: 'wrong direction');
    expect(tt.runsBetween('B', 'C', monday, afterMinute: 8 * 60 + 7).single.trip.id,
        't2');
  });

  Future<void> pumpAt(WidgetTester tester, DateTime now) async {
    SharedPreferences.setMockInitialValues({'settings.reducedMotion': true});
    final sp = await SharedPreferences.getInstance();
    final run = tt.runsBetween('B', 'C', monday).first;
    await tester.pumpWidget(ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sp),
        clockProvider.overrideWithValue(() => now),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: WhereIsMyTrainScreen(run: run, pack: pack),
      ),
    ));
    await tester.pump(const Duration(seconds: 1));
  }

  String headline(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('trainHeadline'))).data!;

  testWidgets('counts down to your station', (tester) async {
    await pumpAt(tester, DateTime(2026, 10, 12, 8, 2));
    expect(headline(tester), 'Reaches B in 3 min');
    expect(find.text('Between A and B'), findsOneWidget);
    expect(find.text('You board here'), findsOneWidget);
    expect(find.byKey(const Key('trainMarker')), findsOneWidget);
    expect(find.textContaining('not live GPS'), findsOneWidget);
  });

  testWidgets('at your station, then on the way', (tester) async {
    await pumpAt(tester, DateTime(2026, 10, 12, 8, 5, 30));
    expect(headline(tester), 'At B now');
    expect(find.text('Reaches C in 7 min'), findsOneWidget);
  });

  testWidgets('journey over', (tester) async {
    await pumpAt(tester, DateTime(2026, 10, 12, 8, 20));
    expect(headline(tester), 'Reached C, journey over');
    expect(find.byKey(const Key('trainMarker')), findsNothing);
  });
}
