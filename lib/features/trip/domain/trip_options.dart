import '../../lastmile/domain/lastmile_engine.dart';
import '../../lastmile/domain/lastmile_models.dart';
import '../../transit/domain/models.dart';
import '../../transit/domain/route_planner.dart';
import '../../transit/domain/timetable.dart';
import 'trip_planner.dart';

enum TripOptionKind { train, auto, cab, bus, walk }

/// How to cover one road leg of a train trip.
enum LegMode { none, walk, auto }

/// One way to make the trip, summarised for the options list.
class TripOption {
  const TripOption({
    required this.kind,
    required this.minutes,
    this.fare,
    this.fareMinimumOnly = false,
    this.plusTicket = false,
    this.firstLeg = LegMode.none,
    this.lastLeg = LegMode.none,
    this.trainFromTimetable = false,
    this.roadOptions = const [],
  });

  final TripOptionKind kind;

  /// Door-to-door minutes without traffic or waiting. Always an estimate.
  final int? minutes;

  /// Rupees; null when no fare can be estimated (cab apps, buses).
  final int? fare;
  final bool fareMinimumOnly;

  /// Train options: the rail ticket is extra (no fare table loaded).
  final bool plusTicket;
  final LegMode firstLeg;
  final LegMode lastLeg;

  /// True when the train time comes from the loaded timetable.
  final bool trainFromTimetable;

  /// The road choices behind a road option, for its detail page.
  final List<LastMileOption> roadOptions;
}

/// Walking is chosen for a station leg when it takes at most this long.
const walkLegMaxMinutes = 12;

/// Suburban trains average about this between stops, including stops.
const railKmh = 32.0;

(LegMode, int, int?, bool) _leg(StationLeg? leg) {
  final r = leg?.result;
  if (r == null) return (LegMode.none, 0, 0, false);
  final walk = r.options.where((o) => o.kind == OptionKind.walk).firstOrNull;
  if (walk != null && walk.minutes! <= walkLegMaxMinutes) {
    return (LegMode.walk, walk.minutes!, 0, false);
  }
  final auto = r.options.where((o) => o.kind == OptionKind.autoMeter).firstOrNull;
  if (auto != null) {
    return (LegMode.auto, auto.minutes ?? 0, auto.fare?.amount,
        auto.fare?.minimumOnly ?? false);
  }
  return (LegMode.walk, walk?.minutes ?? 0, 0, false);
}

/// Estimated in-train minutes from station spacing, plus changes.
int estimateRailMinutes(Journey j, DataPack pack) {
  var minutes = 0.0;
  for (final leg in j.legs) {
    switch (leg) {
      case WalkLeg():
        minutes += leg.minutes;
      case RideLeg():
        for (var i = 0; i < leg.stationIds.length - 1; i++) {
          final a = pack.stationById[leg.stationIds[i]];
          final b = pack.stationById[leg.stationIds[i + 1]];
          if (a == null || b == null) continue;
          minutes += distanceMeters(GeoPoint(a.lat, a.lng), GeoPoint(b.lat, b.lng)) /
              1000 / railKmh * 60;
        }
    }
  }
  return (minutes + j.transfers * Timetable.changeMinutes).ceil();
}

List<TripOption> buildTripOptions(
    TripPlan plan, DataPack pack, Timetable? tt, DateTime now) {
  final out = <TripOption>[];
  final direct = plan.direct.options;
  LastMileOption? first(OptionKind k) =>
      direct.where((o) => o.kind == k).firstOrNull;

  if (plan.hasTrain) {
    final (fm, fmMin, fmFare, fmMinOnly) = _leg(plan.firstMile);
    final (lm, lmMin, lmFare, lmMinOnly) = _leg(plan.lastMile);
    final rides = plan.rail!.rides.toList();
    var rail = estimateRailMinutes(plan.rail!, pack);
    var fromTimetable = false;
    if (tt != null && pack.hasTimetable && rides.length == 1) {
      final run = tt
          .runsBetween(rides.first.fromId, rides.first.toId, now,
              afterMinute: now.hour * 60 + now.minute + fmMin, limit: 1)
          .firstOrNull;
      if (run != null) {
        rail = run.arrival - run.departure;
        fromTimetable = true;
      }
    }
    out.add(TripOption(
      kind: TripOptionKind.train,
      minutes: fmMin + rail + lmMin,
      fare: (fmFare ?? 0) + (lmFare ?? 0),
      fareMinimumOnly: fmMinOnly || lmMinOnly,
      plusTicket: true,
      firstLeg: fm,
      lastLeg: lm,
      trainFromTimetable: fromTimetable,
    ));
  }

  final auto = first(OptionKind.autoMeter);
  if (auto != null) {
    out.add(TripOption(
      kind: TripOptionKind.auto,
      minutes: auto.minutes,
      fare: auto.fare?.amount,
      fareMinimumOnly: auto.fare?.minimumOnly ?? false,
      roadOptions: direct
          .where((o) =>
              o.kind == OptionKind.autoMeter || o.kind == OptionKind.sharedAuto)
          .toList(),
    ));
  }

  final taxi = first(OptionKind.taxiMeter);
  final apps = direct.where((o) => o.kind == OptionKind.rideHailing).toList();
  if (taxi != null || apps.isNotEmpty) {
    out.add(TripOption(
      kind: TripOptionKind.cab,
      minutes: taxi?.minutes ?? auto?.minutes,
      fare: taxi?.fare?.amount,
      fareMinimumOnly: taxi?.fare?.minimumOnly ?? false,
      roadOptions: [?taxi, ...apps],
    ));
  }

  final buses = direct.where((o) => o.kind == OptionKind.bus).toList();
  if (buses.isNotEmpty) {
    out.add(TripOption(
      kind: TripOptionKind.bus,
      minutes: buses.first.minutes,
      fare: buses.first.fixedFare?.round(),
      roadOptions: buses,
    ));
  }

  final walk = first(OptionKind.walk);
  if (walk != null) {
    out.add(TripOption(
      kind: TripOptionKind.walk,
      minutes: walk.minutes,
      fare: 0,
      roadOptions: [walk],
    ));
  }

  if (plan.trainFirst) return out;
  // Short trips: road options first, train after them.
  final train = out.where((o) => o.kind == TripOptionKind.train).toList();
  return [...out.where((o) => o.kind != TripOptionKind.train), ...train];
}

/// Fastest option, ignoring walking over 30 minutes.
TripOption? fastestOption(List<TripOption> options) {
  TripOption? best;
  for (final o in options) {
    if (o.minutes == null) continue;
    if (o.kind == TripOptionKind.walk && o.minutes! > 30) continue;
    if (best == null || o.minutes! < best.minutes!) best = o;
  }
  return best;
}

/// Cheapest option with a known fare, not counting walking.
TripOption? cheapestOption(List<TripOption> options) {
  TripOption? best;
  for (final o in options) {
    if (o.fare == null || o.kind == TripOptionKind.walk) continue;
    if (best == null || o.fare! < best.fare!) best = o;
  }
  return best;
}
