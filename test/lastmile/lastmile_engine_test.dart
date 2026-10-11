import 'package:flutter_test/flutter_test.dart';
import 'package:mumbai_smart_commute/core/data/data_source_label.dart';
import 'package:mumbai_smart_commute/features/lastmile/domain/lastmile_engine.dart';
import 'package:mumbai_smart_commute/features/lastmile/domain/lastmile_models.dart';

const kalyan = GeoPoint(19.2355, 73.1299);
const yogidham = GeoPoint(19.2440, 73.1170);

FareRule rule(String mode, double min, double minKm, double? perKm) => FareRule(
  id: 'F-$mode',
  mode: mode,
  minFare: min,
  minKm: minKm,
  perKm: perKm,
  nightMultiplier: 1.25,
  nightStart: '00:00',
  nightEnd: '05:00',
  effectiveFrom: DateTime(2026, 9, 1),
  sourceId: 'S1',
);

LastMileData data({double? perKm = 18.22}) => LastMileData(
  fareRules: [rule('auto', 27, 1.5, perKm)],
  pickupPoints: const [
    PickupPoint(
      id: 'P1',
      kind: PickupKind.autoStand,
      nameEn: 'Kalyan West stand',
      point: GeoPoint(19.2358, 73.1295),
      verification: Verification.osm,
      sourceId: 'osm',
    ),
    PickupPoint(
      id: 'P2',
      kind: PickupKind.sharedAuto,
      nameEn: 'Shared autos to Yogidham',
      point: GeoPoint(19.2360, 73.1290),
      sharedFareInr: 20,
      verification: Verification.community,
      sourceId: 'community',
    ),
  ],
  busStops: const [
    BusStop('B1', 'Kalyan Stn', GeoPoint(19.2357, 73.1300), 's'),
    BusStop('B2', 'Midway', GeoPoint(19.2400, 73.1230), 's'),
    BusStop('B3', 'Yogidham', GeoPoint(19.2442, 73.1172), 's'),
  ],
  busRoutes: const [
    BusRoute(
      id: 'R1',
      operator: 'KDMT',
      number: '1',
      nameEn: 'Test route',
      stopIds: ['B1', 'B2', 'B3'],
      sourceId: 's',
    ),
  ],
  providers: const [
    RideProvider(
      id: 'ola',
      name: 'Ola',
      categories: 'auto',
      integration: 'open_app',
      androidPackage: 'com.olacabs.customer',
    ),
  ],
);

void main() {
  test('haversine is close to known distance', () {
    final m = distanceMeters(kalyan, yogidham);
    expect(m, inInclusiveRange(1600, 1800));
  });

  test('meter fare: minimum, per km, night surcharge', () {
    final e = LastMileEngine(data());
    final day = DateTime(2026, 10, 11, 10);
    expect(e.meterFare('auto', 1.0, day)!.amount, 27);
    expect(e.meterFare('auto', 3.5, day)!.amount, (27 + 2 * 18.22).round());
    final night = e.meterFare('auto', 1.0, DateTime(2026, 10, 11, 1));
    expect(night!.nightApplied, isTrue);
    expect(night.amount, (27 * 1.25).round());
  });

  test('no fare before rule is effective, minimum-only without per km', () {
    expect(
      LastMileEngine(data()).meterFare('auto', 3, DateTime(2026, 8, 1)),
      isNull,
    );
    final f = LastMileEngine(data(perKm: null))
        .meterFare('auto', 3, DateTime(2026, 10, 1, 10))!;
    expect(f.minimumOnly, isTrue);
    expect(f.amount, 27);
  });

  test('plan lists walk, auto, shared auto, bus and app link', () {
    final r = LastMileEngine(data())
        .plan(kalyan, yogidham, DateTime(2026, 10, 11, 9));
    final kinds = r.options.map((o) => o.kind).toSet();
    expect(
      kinds,
      containsAll([
        OptionKind.walk,
        OptionKind.autoMeter,
        OptionKind.sharedAuto,
        OptionKind.bus,
        OptionKind.rideHailing,
      ]),
    );
    expect(r.kmIsRoad, isFalse);
    final auto = r.options.firstWhere((o) => o.kind == OptionKind.autoMeter);
    expect(auto.sourceKind, DataSourceKind.estimate);
    expect(auto.availability, Availability.unknown);
    expect(auto.pickup?.id, 'P1');
    final shared = r.options.firstWhere((o) => o.kind == OptionKind.sharedAuto);
    expect(shared.sourceKind, DataSourceKind.community);
    final bus = r.options.firstWhere((o) => o.kind == OptionKind.bus);
    expect(bus.boardStop!.id, 'B1');
    expect(bus.alightStop!.id, 'B3');
  });

  test('road distance overrides the straight-line estimate', () {
    final r = LastMileEngine(data())
        .plan(kalyan, yogidham, DateTime(2026, 10, 11, 9), roadKm: 2.4);
    expect(r.kmIsRoad, isTrue);
    expect(r.km, 2.4);
  });

  test('sorting puts unknown cost last', () {
    final r = LastMileEngine(data())
        .plan(kalyan, yogidham, DateTime(2026, 10, 11, 9));
    final cheap = LastMileEngine.sort(r.options, SortBy.cheapest);
    expect(cheap.first.kind, OptionKind.walk);
    expect(cheap.last.cost, isNull);
    final walk = LastMileEngine.sort(r.options, SortBy.leastWalking);
    expect(walk.first.walkMeters, 0);
  });

  test('no walking option for far destinations', () {
    final r = LastMileEngine(data())
        .plan(kalyan, const GeoPoint(19.30, 73.20), DateTime(2026, 10, 11, 9));
    expect(r.options.any((o) => o.kind == OptionKind.walk), isFalse);
  });
}
