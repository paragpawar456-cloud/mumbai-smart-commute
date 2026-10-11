import '../../lastmile/domain/lastmile_engine.dart';
import '../../lastmile/domain/lastmile_models.dart';
import '../../transit/domain/models.dart';
import '../../transit/domain/route_planner.dart';
import 'trip_point.dart';

/// Why a trip has no train option.
enum NoTrainReason { close, sameStation, noStationNear, noRoute }

/// A station leg of the trip: getting to or from a station by road.
class StationLeg {
  const StationLeg(this.station, this.result);
  final Station station;

  /// Null when the point is the station itself (or right next to it).
  final LastMileResult? result;
}

class TripPlan {
  const TripPlan({
    required this.from,
    required this.to,
    required this.straightKm,
    required this.direct,
    this.firstMile,
    this.rail,
    this.lastMile,
    this.noTrainReason,
  });

  final TripPoint from;
  final TripPoint to;
  final double straightKm;

  /// Door to door by road (walk, auto, taxi, cab apps, bus).
  final LastMileResult direct;

  final StationLeg? firstMile;
  final Journey? rail;
  final StationLeg? lastMile;
  final NoTrainReason? noTrainReason;

  bool get hasTrain => rail != null;

  /// For longer trips the train usually wins, so it is shown first.
  bool get trainFirst => hasTrain && straightKm >= 8;
}

/// Plans a door-to-door trip from any two points, fully offline.
///
/// The train option boards at the station nearest the start and leaves at
/// the station nearest the destination; the road legs at each end use the
/// same estimates as the last-mile finder. Nothing here claims a vehicle is
/// available.
class TripPlanner {
  const TripPlanner(
    this.pack,
    this.rail,
    this.road, {
    this.minTrainKm = 3,
    this.maxStationKm = 10,
    this.atStationMeters = 150,
  });

  final DataPack pack;
  final RoutePlanner rail;
  final LastMileEngine road;

  /// Trips shorter than this go by road only.
  final double minTrainKm;

  /// A station further than this from a point doesn't count as "near".
  final double maxStationKm;

  /// Closer than this to a station means you are at the station.
  final double atStationMeters;

  Station? _station(String? id) => id == null ? null : pack.stationById[id];

  /// Nearest station that is on at least one line.
  (Station, double)? nearestStation(GeoPoint p) {
    final onLines = {for (final ln in pack.lines) ...ln.stationIds};
    (Station, double)? best;
    for (final s in pack.stations) {
      if (!onLines.contains(s.id)) continue;
      final m = distanceMeters(p, GeoPoint(s.lat, s.lng));
      if (best == null || m < best.$2) best = (s, m);
    }
    return best;
  }

  TripPlan plan(TripPoint from, TripPoint to, DateTime now) {
    final straightKm = distanceMeters(from.point, to.point) / 1000;
    final direct = road.plan(from.point, to.point, now,
        fromName: from.name, toName: to.name);

    TripPlan roadOnly(NoTrainReason why) => TripPlan(
          from: from,
          to: to,
          straightKm: straightKm,
          direct: direct,
          noTrainReason: why,
        );

    final bothStations = from.isStation && to.isStation;
    if (straightKm < minTrainKm && !bothStations) {
      return roadOnly(NoTrainReason.close);
    }

    (Station, double)? resolve(TripPoint t) {
      final s = _station(t.stationId);
      return s != null ? (s, 0) : nearestStation(t.point);
    }

    final a = resolve(from), b = resolve(to);
    if (a == null ||
        b == null ||
        a.$2 > maxStationKm * 1000 ||
        b.$2 > maxStationKm * 1000) {
      return roadOnly(NoTrainReason.noStationNear);
    }
    if (a.$1.id == b.$1.id) return roadOnly(NoTrainReason.sameStation);

    final journey = rail.plan(a.$1.id, b.$1.id);
    if (journey == null) return roadOnly(NoTrainReason.noRoute);

    StationLeg leg(Station s, double meters, GeoPoint p, bool toStation) {
      if (meters <= atStationMeters) return StationLeg(s, null);
      final sp = GeoPoint(s.lat, s.lng);
      return StationLeg(
        s,
        toStation
            ? road.plan(p, sp, now, fromName: from.name, toName: s.nameEn)
            : road.plan(sp, p, now, fromName: s.nameEn, toName: to.name),
      );
    }

    return TripPlan(
      from: from,
      to: to,
      straightKm: straightKm,
      direct: direct,
      firstMile: leg(a.$1, a.$2, from.point, true),
      rail: journey,
      lastMile: leg(b.$1, b.$2, to.point, false),
    );
  }
}
