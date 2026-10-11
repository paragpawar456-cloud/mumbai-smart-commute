import 'models.dart';
import 'route_planner.dart';

class Departure {
  const Departure(this.trip, this.departure, this.platform, this.terminusId);

  final Trip trip;
  final int departure;
  final String? platform;
  final String terminusId;
}

class ScheduledLeg {
  const ScheduledLeg(this.leg, this.trip, this.departure, this.arrival);

  final RideLeg leg;
  final Trip trip;
  final int departure;
  final int arrival;
}

/// One scheduled train between two stations it stops at, in order.
class TrainRun {
  const TrainRun(this.trip, this.stops, this.boardIndex, this.alightIndex);

  final Trip trip;

  /// Every stop of the train, in order.
  final List<StopTime> stops;
  final int boardIndex;
  final int alightIndex;

  int get departure => stops[boardIndex].departure;
  int get arrival => stops[alightIndex].arrival ?? stops[alightIndex].departure;
  String get originId => stops.first.stationId;
  String get terminusId => stops.last.stationId;
}

/// Timetable look-ups over scheduled data. Results are always "Scheduled";
/// there is no live running information behind them.
class Timetable {
  Timetable(this.pack) {
    for (final st in pack.stopTimes) {
      _byTrip.putIfAbsent(st.tripId, () => []).add(st);
    }
    for (final list in _byTrip.values) {
      list.sort((a, b) => a.seq.compareTo(b.seq));
    }
    for (final t in pack.trips) {
      _trip[t.id] = t;
    }
  }

  final DataPack pack;
  final Map<String, List<StopTime>> _byTrip = {};
  final Map<String, Trip> _trip = {};

  /// Minimum time to change trains at the same station.
  static const changeMinutes = 3;

  List<Departure> departuresFrom(
    String stationId,
    DateTime date, {
    int afterMinute = 0,
    int limit = 20,
    bool holiday = false,
  }) {
    final out = <Departure>[];
    _byTrip.forEach((tripId, stops) {
      final trip = _trip[tripId];
      if (trip == null || !trip.runsOn(date, holiday: holiday)) return;
      for (var i = 0; i < stops.length - 1; i++) {
        final st = stops[i];
        if (st.stationId == stationId && st.departure >= afterMinute) {
          out.add(Departure(trip, st.departure, st.platform, stops.last.stationId));
        }
      }
    });
    out.sort((a, b) => a.departure.compareTo(b.departure));
    return out.take(limit).toList();
  }

  /// All stops of a trip in order (empty if unknown).
  List<StopTime> stopsOf(String tripId) => _byTrip[tripId] ?? const [];

  /// Trains that stop at [fromId] and later at [toId], leaving at or after
  /// [afterMinute], earliest first.
  List<TrainRun> runsBetween(
    String fromId,
    String toId,
    DateTime date, {
    int afterMinute = 0,
    int limit = 20,
    bool holiday = false,
  }) {
    final out = <TrainRun>[];
    _byTrip.forEach((tripId, stops) {
      final trip = _trip[tripId];
      if (trip == null || !trip.runsOn(date, holiday: holiday)) return;
      final a = stops.indexWhere((s) => s.stationId == fromId);
      if (a == -1 || a == stops.length - 1) return;
      final b = stops.indexWhere((s) => s.stationId == toId, a + 1);
      if (b == -1 || stops[a].departure < afterMinute) return;
      out.add(TrainRun(trip, stops, a, b));
    });
    out.sort((x, y) => x.departure.compareTo(y.departure));
    return out.take(limit).toList();
  }

  /// Earliest trip on [leg]'s line from its first to last station, leaving at
  /// or after [afterMinute].
  ScheduledLeg? nextTrip(RideLeg leg, DateTime date, int afterMinute,
      {bool holiday = false}) {
    ScheduledLeg? best;
    _byTrip.forEach((tripId, stops) {
      final trip = _trip[tripId];
      if (trip == null ||
          trip.lineId != leg.line.id ||
          !trip.runsOn(date, holiday: holiday)) {
        return;
      }
      final a = stops.indexWhere((s) => s.stationId == leg.fromId);
      if (a == -1) return;
      final b = stops.indexWhere((s) => s.stationId == leg.toId, a + 1);
      if (b == -1) return;
      final dep = stops[a].departure;
      if (dep < afterMinute) return;
      final arr = stops[b].arrival ?? stops[b].departure;
      if (best == null ||
          arr < best!.arrival ||
          (arr == best!.arrival && dep > best!.departure)) {
        best = ScheduledLeg(leg, trip, dep, arr);
      }
    });
    return best;
  }

  /// Chains each ride leg to the earliest connecting trip. Returns null when
  /// any leg has no scheduled trip (we never invent one).
  List<ScheduledLeg>? schedule(Journey journey, DateTime date, int afterMinute,
      {bool holiday = false}) {
    final out = <ScheduledLeg>[];
    var t = afterMinute;
    for (final leg in journey.legs) {
      switch (leg) {
        case WalkLeg():
          t += leg.minutes;
        case RideLeg():
          final next = nextTrip(leg, date, t, holiday: holiday);
          if (next == null) return null;
          out.add(next);
          t = next.arrival + changeMinutes;
      }
    }
    return out;
  }
}
