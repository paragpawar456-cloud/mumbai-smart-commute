import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mumbai_smart_commute/features/transit/domain/models.dart';
import 'package:mumbai_smart_commute/features/transit/domain/route_planner.dart';

void main() {
  late DataPack pack;
  late RoutePlanner planner;

  setUpAll(() {
    pack = DataPack.fromJson(jsonDecode(
            File('assets/data/seed_pack.json').readAsStringSync())
        as Map<String, dynamic>);
    planner = RoutePlanner(pack);
  });

  test('seed pack has the pilot lines and no invented timetable', () {
    expect(pack.lines.map((l) => l.id), containsAll(['CR-MAIN', 'MML1']));
    expect(pack.stationById['KYN']!.nameEn, 'Kalyan');
    expect(pack.stationById['KYN']!.nameMr, 'कल्याण जंक्शन');
    expect(pack.hasTimetable, isFalse);
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
}
