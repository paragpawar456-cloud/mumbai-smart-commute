import 'dart:math' as math;

import '../../../core/data/data_source_label.dart';
import 'lastmile_models.dart';

/// Stated assumptions behind every estimate. Shown to the user next to the
/// numbers they produce, so nothing looks more precise than it is.
class Assumptions {
  const Assumptions({
    this.walkKmh = 4.5,
    this.streetDetour = 1.3,
    this.autoKmh = 18,
    this.taxiKmh = 20,
    this.nearStopMeters = 600,
    this.nearPickupMeters = 1000,
    this.maxWalkKm = 3,
  });

  final double walkKmh;

  /// Straight-line distance × this ≈ street distance, used only when no
  /// road route is available.
  final double streetDetour;
  final double autoKmh;
  final double taxiKmh;
  final double nearStopMeters;
  final double nearPickupMeters;
  final double maxWalkKm;
}

double distanceMeters(GeoPoint a, GeoPoint b) {
  const r = 6371000.0;
  double rad(double d) => d * math.pi / 180;
  final dLat = rad(b.lat - a.lat), dLng = rad(b.lng - a.lng);
  final h =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(rad(a.lat)) *
          math.cos(rad(b.lat)) *
          math.pow(math.sin(dLng / 2), 2);
  return 2 * r * math.asin(math.sqrt(h));
}

enum OptionKind { walk, autoMeter, taxiMeter, sharedAuto, bus, rideHailing }

enum Availability { confirmed, estimated, unknown }

class FareEstimate {
  const FareEstimate({
    required this.amount,
    required this.km,
    required this.minimumOnly,
    required this.nightApplied,
    required this.rule,
  });

  /// Rounded to the rupee.
  final int amount;
  final double km;

  /// True when the per-km rate isn't entered, so [amount] is only the
  /// minimum fare ("from ₹27").
  final bool minimumOnly;
  final bool nightApplied;
  final FareRule rule;
}

class LastMileOption {
  const LastMileOption({
    required this.kind,
    required this.walkMeters,
    required this.sourceKind,
    required this.availability,
    this.pickup,
    this.busRoute,
    this.boardStop,
    this.alightStop,
    this.fare,
    this.fixedFare,
    this.minutes,
    this.provider,
    this.bookingUri,
  });

  final OptionKind kind;
  final double walkMeters;
  final DataSourceKind sourceKind;
  final Availability availability;
  final PickupPoint? pickup;
  final BusRoute? busRoute;
  final BusStop? boardStop;
  final BusStop? alightStop;
  final FareEstimate? fare;

  /// A verified flat fare (shared autos).
  final double? fixedFare;

  /// Travel time estimate in minutes (excludes waiting, which we don't know).
  final int? minutes;
  final RideProvider? provider;
  final Uri? bookingUri;

  double? get cost =>
      fare?.amount.toDouble() ??
      fixedFare ??
      (kind == OptionKind.walk ? 0 : null);
}

class NearbyPickup {
  const NearbyPickup(this.point, this.meters);
  final PickupPoint point;
  final double meters;
}

class LastMileResult {
  const LastMileResult({
    required this.straightKm,
    required this.km,
    required this.kmIsRoad,
    required this.options,
    required this.nearbyPickups,
  });

  final double straightKm;

  /// Distance used for fares: road distance if known, else straight × detour.
  final double km;
  final bool kmIsRoad;
  final List<LastMileOption> options;
  final List<NearbyPickup> nearbyPickups;
}

enum SortBy { cheapest, fastest, leastWalking }

class LastMileEngine {
  const LastMileEngine(this.data, {this.assumptions = const Assumptions()});

  final LastMileData data;
  final Assumptions assumptions;

  FareRule? _rule(String mode, DateTime now) {
    final rules =
        data.fareRules
            .where((r) => r.mode == mode && !r.effectiveFrom.isAfter(now))
            .toList()
          ..sort((a, b) => b.effectiveFrom.compareTo(a.effectiveFrom));
    return rules.isEmpty ? null : rules.first;
  }

  static bool _inWindow(DateTime t, String start, String end) {
    int m(String s) {
      final p = s.split(':');
      return int.parse(p[0]) * 60 + int.parse(p[1]);
    }

    final now = t.hour * 60 + t.minute, a = m(start), b = m(end);
    return a <= b ? (now >= a && now < b) : (now >= a || now < b);
  }

  FareEstimate? meterFare(String mode, double km, DateTime now) {
    final r = _rule(mode, now);
    if (r == null) return null;
    double amount;
    var minimumOnly = false;
    if (km <= r.minKm) {
      amount = r.minFare;
    } else if (r.perKm != null) {
      amount = r.minFare + (km - r.minKm) * r.perKm!;
    } else {
      amount = r.minFare;
      minimumOnly = true;
    }
    final night =
        r.nightMultiplier != null &&
        r.nightStart != null &&
        r.nightEnd != null &&
        _inWindow(now, r.nightStart!, r.nightEnd!);
    if (night) amount *= r.nightMultiplier!;
    return FareEstimate(
      amount: amount.round(),
      km: km,
      minimumOnly: minimumOnly,
      nightApplied: night,
      rule: r,
    );
  }

  LastMileResult plan(
    GeoPoint from,
    GeoPoint to,
    DateTime now, {
    double? roadKm,
    String fromName = '',
    String toName = '',
  }) {
    final a = assumptions;
    final straightKm = distanceMeters(from, to) / 1000;
    final km = roadKm ?? straightKm * a.streetDetour;
    final options = <LastMileOption>[];

    if (straightKm <= a.maxWalkKm) {
      options.add(
        LastMileOption(
          kind: OptionKind.walk,
          walkMeters: km * 1000,
          minutes: (km / a.walkKmh * 60).ceil(),
          sourceKind: DataSourceKind.estimate,
          availability: Availability.confirmed,
        ),
      );
    }

    final nearby =
        data.pickupPoints
            .map((p) => NearbyPickup(p, distanceMeters(from, p.point)))
            .where((n) => n.meters <= a.nearPickupMeters)
            .toList()
          ..sort((x, y) => x.meters.compareTo(y.meters));

    PickupPoint? nearestOf(PickupKind k) {
      for (final n in nearby) {
        if (n.point.kind == k) return n.point;
      }
      return null;
    }

    for (final (mode, kind, standKind, kmh) in [
      ('auto', OptionKind.autoMeter, PickupKind.autoStand, a.autoKmh),
      ('taxi', OptionKind.taxiMeter, PickupKind.taxiStand, a.taxiKmh),
    ]) {
      final fare = meterFare(mode, km, now);
      if (fare == null) continue;
      final stand = nearestOf(standKind);
      options.add(
        LastMileOption(
          kind: kind,
          pickup: stand,
          walkMeters: stand == null ? 0 : distanceMeters(from, stand.point),
          fare: fare,
          minutes: (km / kmh * 60).ceil(),
          sourceKind: DataSourceKind.estimate,
          // A stand nearby is not a vehicle waiting; we can't know that.
          availability: Availability.unknown,
        ),
      );
    }

    for (final n in nearby.where(
      (n) => n.point.kind == PickupKind.sharedAuto,
    )) {
      final p = n.point;
      options.add(
        LastMileOption(
          kind: OptionKind.sharedAuto,
          pickup: p,
          walkMeters: n.meters,
          fixedFare: p.sharedFareInr,
          sourceKind: p.verification == Verification.community
              ? DataSourceKind.community
              : DataSourceKind.official,
          availability: Availability.unknown,
        ),
      );
    }

    options.addAll(_busOptions(from, to));

    for (final pr in data.providers) {
      final uri = pr.bookingUri(from, to, fromName: fromName, toName: toName);
      if (uri == null) continue;
      options.add(
        LastMileOption(
          kind: OptionKind.rideHailing,
          provider: pr,
          bookingUri: uri,
          walkMeters: 0,
          sourceKind: DataSourceKind.unknown,
          availability: Availability.unknown,
        ),
      );
    }

    return LastMileResult(
      straightKm: straightKm,
      km: km,
      kmIsRoad: roadKm != null,
      options: options,
      nearbyPickups: nearby,
    );
  }

  Iterable<LastMileOption> _busOptions(GeoPoint from, GeoPoint to) sync* {
    final a = assumptions;
    final stopById = {for (final s in data.busStops) s.id: s};
    final seen = <String>{};
    for (final route in data.busRoutes) {
      LastMileOption? best;
      for (var i = 0; i < route.stopIds.length; i++) {
        final board = stopById[route.stopIds[i]];
        if (board == null) continue;
        final walkA = distanceMeters(from, board.point);
        if (walkA > a.nearStopMeters) continue;
        for (var j = i + 1; j < route.stopIds.length; j++) {
          final alight = stopById[route.stopIds[j]];
          if (alight == null) continue;
          final walkB = distanceMeters(alight.point, to);
          if (walkB > a.nearStopMeters) continue;
          final total = walkA + walkB;
          if (best == null || total < best.walkMeters) {
            best = LastMileOption(
              kind: OptionKind.bus,
              busRoute: route,
              boardStop: board,
              alightStop: alight,
              walkMeters: total,
              sourceKind: DataSourceKind.scheduled,
              availability: Availability.unknown,
            );
          }
        }
      }
      if (best != null && seen.add(route.id)) yield best;
    }
  }

  static List<LastMileOption> sort(List<LastMileOption> options, SortBy by) {
    int nullLast(num? x, num? y) =>
        x == null ? (y == null ? 0 : 1) : (y == null ? -1 : x.compareTo(y));
    final list = [...options];
    list.sort((x, y) {
      final c = switch (by) {
        SortBy.cheapest => nullLast(x.cost, y.cost),
        SortBy.fastest => nullLast(x.minutes, y.minutes),
        SortBy.leastWalking => x.walkMeters.compareTo(y.walkMeters),
      };
      return c != 0 ? c : x.kind.index.compareTo(y.kind.index);
    });
    return list;
  }
}
