import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mumbai_smart_commute/features/lastmile/domain/lastmile_engine.dart';
import 'package:mumbai_smart_commute/features/lastmile/domain/lastmile_models.dart';
import 'package:mumbai_smart_commute/features/transit/domain/models.dart';
import 'package:mumbai_smart_commute/features/transit/domain/route_planner.dart';
import 'package:mumbai_smart_commute/features/transit/domain/timetable.dart';
import 'package:mumbai_smart_commute/features/trip/domain/trip_options.dart';
import 'package:mumbai_smart_commute/features/trip/domain/trip_planner.dart';
import 'package:mumbai_smart_commute/features/trip/domain/trip_point.dart';

void main() {
  final pack = DataPack.fromJson(
      jsonDecode(File('assets/data/seed_pack.json').readAsStringSync())
          as Map<String, dynamic>);
  final planner =
      TripPlanner(pack, RoutePlanner(pack), LastMileEngine(pack.lastMile));
  final noon = DateTime(2026, 10, 12, 12);

  const yogidham = TripPoint(
      name: 'Yogidham',
      point: GeoPoint(19.247338, 73.153039),
      source: TripPointSource.place);
  // Roughly Manpada, Thane (a test point, as a search would return it).
  const manpada = TripPoint(
      name: 'Runwal, Manpada',
      point: GeoPoint(19.2330, 72.9740),
      source: TripPointSource.osm);

  test('Yogidham to Manpada: train first, then auto and cab', () {
    final plan = planner.plan(yogidham, manpada, noon);
    expect(plan.firstMile!.station.id, 'KYN');
    // Kalwa and Thane are about equally close in a straight line; Thane must
    // be offered so the user can switch.
    expect(plan.lastMile!.station.id, anyOf('KLVA', 'TNA'));
    expect(plan.alightChoices.map((s) => s.id), contains('TNA'));
    final viaThane = planner.plan(yogidham, manpada, noon, alightId: 'TNA');
    expect(viaThane.lastMile!.station.id, 'TNA');
    final options = buildTripOptions(plan, pack, Timetable(pack), noon);
    expect(options.map((o) => o.kind),
        [TripOptionKind.train, TripOptionKind.auto, TripOptionKind.cab]);
    final train = options.first;
    expect(train.firstLeg, LegMode.auto);
    expect(train.lastLeg, LegMode.auto);
    expect(train.plusTicket, isTrue);
    expect(train.trainFromTimetable, isTrue);
    // Kalyan to Thane is about 20 km of track: tens of minutes, not hours.
    final rail = estimateRailMinutes(plan.rail!, pack);
    expect(rail, inInclusiveRange(25, 60));
    expect(fastestOption(options), isNotNull);
    expect(cheapestOption(options)!.kind, TripOptionKind.train);
  });

  test('a short trip lists road options before the train', () {
    const dombivli = TripPoint(
        name: 'Dombivli East',
        point: GeoPoint(19.2140, 73.0950),
        source: TripPointSource.osm);
    final plan = planner.plan(yogidham, dombivli, noon);
    final kinds = buildTripOptions(plan, pack, null, noon).map((o) => o.kind);
    expect(kinds.first, TripOptionKind.auto);
    expect(kinds.last, TripOptionKind.train);
  });
}
