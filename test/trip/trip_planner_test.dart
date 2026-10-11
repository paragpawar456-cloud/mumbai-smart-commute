import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mumbai_smart_commute/features/lastmile/domain/lastmile_engine.dart';
import 'package:mumbai_smart_commute/features/lastmile/domain/lastmile_models.dart';
import 'package:mumbai_smart_commute/features/transit/domain/models.dart';
import 'package:mumbai_smart_commute/features/transit/domain/route_planner.dart';
import 'package:mumbai_smart_commute/features/trip/domain/trip_planner.dart';
import 'package:mumbai_smart_commute/features/trip/domain/trip_point.dart';

void main() {
  final pack = DataPack.fromJson(
      jsonDecode(File('assets/data/seed_pack.json').readAsStringSync())
          as Map<String, dynamic>);
  final planner =
      TripPlanner(pack, RoutePlanner(pack), LastMileEngine(pack.lastMile));
  final noon = DateTime(2026, 10, 11, 12);

  const yogidham = TripPoint(
      name: 'Yogidham',
      point: GeoPoint(19.247338, 73.153039),
      source: TripPointSource.place);
  // A building in Dombivli East found through place search.
  const dombivliEast = TripPoint(
      name: 'Runwal test building',
      point: GeoPoint(19.2140, 73.0950),
      source: TripPointSource.osm);

  test('place to place: road legs at both ends with the train between', () {
    final plan = planner.plan(yogidham, dombivliEast, noon);
    expect(plan.hasTrain, isTrue);
    expect(plan.firstMile!.station.id, 'KYN');
    expect(plan.lastMile!.station.id, 'DI');
    expect(plan.firstMile!.result, isNotNull);
    expect(plan.lastMile!.result, isNotNull);
    expect(plan.rail!.rides.first.stops, greaterThan(0));
    // Road options are always there too.
    expect(plan.direct.options, isNotEmpty);
  });

  test('close places get road options only', () {
    const kalyanWest = TripPoint(
        name: 'Khadakpada',
        point: GeoPoint(19.252504, 73.137376),
        source: TripPointSource.place);
    final plan = planner.plan(yogidham, kalyanWest, noon);
    expect(plan.hasTrain, isFalse);
    expect(plan.noTrainReason, NoTrainReason.close);
    expect(plan.direct.options.any((o) => o.kind == OptionKind.autoMeter),
        isTrue);
  });

  test('a station end has no road leg', () {
    final kyn = pack.stationById['KYN']!;
    final station = TripPoint(
        name: 'Kalyan',
        point: GeoPoint(kyn.lat, kyn.lng),
        source: TripPointSource.station,
        stationId: 'KYN');
    final plan = planner.plan(station, dombivliEast, noon);
    expect(plan.firstMile!.result, isNull);
    expect(plan.lastMile!.result, isNotNull);
  });

  test('far from every station: road only, says why', () {
    const lonavala = TripPoint(
        name: 'Far away',
        point: GeoPoint(18.75, 73.40),
        source: TripPointSource.pin);
    final plan = planner.plan(yogidham, lonavala, noon);
    expect(plan.hasTrain, isFalse);
    expect(plan.noTrainReason, NoTrainReason.noStationNear);
  });

  test('trip points survive the trip page link', () {
    final q = {...yogidham.toQuery('from'), ...dombivliEast.toQuery('to')};
    final from = TripPoint.fromQuery(q, 'from')!;
    expect(from.name, 'Yogidham');
    expect(from.source, TripPointSource.place);
    expect(from.point.lat, closeTo(19.247338, 1e-6));
    expect(TripPoint.fromQuery(q, 'to')!.stationId, isNull);
    expect(TripPoint.fromQuery(const {}, 'from'), isNull);
  });
}
