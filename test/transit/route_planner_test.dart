import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mumbai_smart_commute/features/transit/domain/models.dart';
import 'package:mumbai_smart_commute/features/transit/domain/route_planner.dart';
import 'package:mumbai_smart_commute/features/transit/domain/timetable.dart';

void main() {
  late DataPack pack;
  late RoutePlanner planner;

  setUpAll(() {
    pack = DataPack.fromJson(jsonDecode(
            File('assets/data/seed_pack.json').readAsStringSync())
        as Map<String, dynamic>);
    planner = RoutePlanner(pack);
  });

  test('seed pack has the pilot lines and the official CR timetable', () {
    expect(pack.lines.map((l) => l.id), containsAll(['CR-MAIN', 'MML1']));
    expect(pack.stationById['KYN']!.nameEn, 'Kalyan');
    expect(pack.stationById['KYN']!.nameMr, 'कल्याण जंक्शन');
    expect(pack.hasTimetable, isTrue);
    expect(pack.sources.map((s) => s.id), contains('cr-ptt-ml-2024-10'));
    // Every train comes from that timetable, never made up.
    expect(pack.trips.every((t) => t.sourceId == 'cr-ptt-ml-2024-10'), isTrue);
    for (final line in pack.lines) {
      for (final id in line.stationIds) {
        expect(pack.stationById.containsKey(id), isTrue, reason: id);
      }
    }
  });

  test('Kalyan to CSMT is one ride on the Central line', () {
    final j = planner.plan('KYN', 'CSMT')!;
    expect(j.transfers, 0);
    final ride = j.rides.single;
    expect(ride.line.id, 'CR-MAIN');
    expect(ride.fromId, 'KYN');
    expect(ride.toId, 'CSMT');
    expect(ride.stops, 25);
  });

  test('Kalyan to Andheri metro changes at Ghatkopar with a walk', () {
    final j = planner.plan('KYN', 'M1-AND')!;
    expect(j.transfers, 1);
    expect(j.legs[0], isA<RideLeg>());
    expect((j.legs[0] as RideLeg).toId, 'GC');
    expect(j.legs[1], isA<WalkLeg>());
    expect((j.legs[1] as WalkLeg).toId, 'M1-GKP');
    expect((j.legs[2] as RideLeg).line.id, 'MML1');
    expect((j.legs[2] as RideLeg).toId, 'M1-AND');
  });

  test('same station or unknown station gives no journey', () {
    expect(planner.plan('KYN', 'KYN'), isNull);
    expect(planner.plan('KYN', 'NOPE'), isNull);
  });

  test('Kalyan to Thane has many trains on a weekday, in time order', () {
    final tt = Timetable(pack);
    final monday = DateTime(2026, 10, 12);
    final runs = tt.runsBetween('KYN', 'TNA', monday, limit: 1000);
    expect(runs.length, greaterThan(150));
    for (var i = 1; i < runs.length; i++) {
      expect(runs[i].departure, greaterThanOrEqualTo(runs[i - 1].departure));
    }
    for (final r in runs.take(20)) {
      expect(r.arrival, greaterThan(r.departure));
      expect(r.arrival - r.departure, inInclusiveRange(15, 45));
    }
    // Trains from beyond Kalyan keep their real origin and destination.
    expect(runs.any((r) => r.trip.originName != null), isTrue);
  });
}
