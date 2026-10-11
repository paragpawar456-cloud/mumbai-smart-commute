import 'package:flutter_test/flutter_test.dart';
import 'package:mumbai_smart_commute/features/transit/domain/models.dart';
import 'package:mumbai_smart_commute/features/transit/domain/route_planner.dart';
import 'package:mumbai_smart_commute/features/transit/domain/timetable.dart';

/// Test-only fixture. These are NOT real train times.
DataPack fixture() => DataPack.fromJson({
      'version': 1,
      'generated_at': '2026-10-11T00:00:00Z',
      'stations': [
        for (final id in ['A', 'B', 'C', 'D', 'X'])
          {'station_id': id, 'name_en': id, 'lat': 0, 'lng': 0},
      ],
      'lines': [
        {'route_id': 'L1', 'operator': 'T', 'mode': 'suburban', 'name_en': 'L1', 'station_sequence': 'A,B,C'},
        {'route_id': 'L2', 'operator': 'T', 'mode': 'metro', 'name_en': 'L2', 'station_sequence': 'X,D'},
      ],
      'interchanges': [
        {'from_station_id': 'C', 'to_station_id': 'X', 'walk_minutes': 5},
      ],
      'trips': [
        _trip('t1', 'L1', 'MON-SAT'),
        _trip('t2', 'L1', 'MON-SAT'),
        _trip('t3', 'L1', 'SUN'),
        _trip('m1', 'L2', 'DAILY'),
        _trip('m2', 'L2', 'DAILY'),
      ],
      'stop_times': [
        ['t1', 1, 'A', null, '08:00'], ['t1', 2, 'B', '08:05', '08:06'], ['t1', 3, 'C', '08:12', '08:12'],
        ['t2', 1, 'A', null, '08:20'], ['t2', 2, 'B', '08:25', '08:26'], ['t2', 3, 'C', '08:32', '08:32'],
        ['t3', 1, 'A', null, '09:00'], ['t3', 2, 'B', '09:05', '09:06'], ['t3', 3, 'C', '09:12', '09:12'],
        ['m1', 1, 'X', null, '08:15'], ['m1', 2, 'D', '08:20', '08:20'],
        ['m2', 1, 'X', null, '08:25'], ['m2', 2, 'D', '08:30', '08:30'],
      ],
    });

Map<String, dynamic> _trip(String id, String line, String days) => {
      'trip_id': id, 'route_id': line, 'direction': 'down', 'service_days': days,
      'train_type': 'slow', 'ac': false, 'ladies_special': false,
      'valid_from': '2026-01-01',
    };

void main() {
  final monday = DateTime(2026, 10, 12);
  final sunday = DateTime(2026, 10, 11);
  final pack = fixture();
  final tt = Timetable(pack);

  test('departures respect service days and holidays', () {
    expect(tt.departuresFrom('A', monday).map((d) => d.trip.id), ['t1', 't2']);
    expect(tt.departuresFrom('A', sunday).map((d) => d.trip.id), ['t3']);
    expect(tt.departuresFrom('A', monday, holiday: true).map((d) => d.trip.id), ['t3']);
  });

  test('terminus station is not listed as a departure', () {
    expect(tt.departuresFrom('C', monday), isEmpty);
  });

  test('departures after a time', () {
    expect(tt.departuresFrom('A', monday, afterMinute: 8 * 60 + 1).single.trip.id, 't2');
  });

  test('journey is chained with walking and change time', () {
    final j = RoutePlanner(pack).plan('A', 'D')!;
    final s = tt.schedule(j, monday, 8 * 60)!;
    expect(s[0].trip.id, 't1');
    expect(formatMinutes(s[0].arrival), '08:12');
    // 08:12 + 5 min walk = 08:17, so the 08:15 metro is missed.
    expect(s[1].trip.id, 'm2');
    expect(formatMinutes(s[1].arrival), '08:30');
  });

  test('no scheduled trip means no result, never a guess', () {
    final j = RoutePlanner(pack).plan('A', 'D')!;
    expect(tt.schedule(j, monday, 9 * 60), isNull);
  });

  test('trip validity window', () {
    final t = pack.trips.first;
    expect(t.runsOn(DateTime(2025, 12, 31)), isFalse);
  });
}
