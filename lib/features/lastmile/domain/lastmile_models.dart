/// Last-mile data: places, pickup points, bus stops/routes, fare rules and
/// ride-hailing providers. A pickup point is a PLACE where vehicles are
/// usually found; it never means a vehicle is waiting there now.
library;

String? _s(Object? v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

double? _d(Object? v) => v == null || v.toString().trim().isEmpty
    ? null
    : double.tryParse(v.toString());

class GeoPoint {
  const GeoPoint(this.lat, this.lng);
  final double lat;
  final double lng;
}

class Place {
  const Place({
    required this.id,
    required this.nameEn,
    this.nameMr,
    this.nameHi,
    required this.point,
    required this.kind,
    required this.sourceId,
  });

  factory Place.fromJson(Map<String, dynamic> j) => Place(
    id: j['place_id'] as String,
    nameEn: j['name_en'] as String,
    nameMr: _s(j['name_mr']),
    nameHi: _s(j['name_hi']),
    point: GeoPoint(_d(j['lat'])!, _d(j['lng'])!),
    kind: _s(j['kind']) ?? 'place',
    sourceId: _s(j['source_id']) ?? '',
  );

  final String id;
  final String nameEn;
  final String? nameMr;
  final String? nameHi;
  final GeoPoint point;
  final String kind;
  final String sourceId;

  String name(String lang) => switch (lang) {
    'mr' => nameMr ?? nameEn,
    'hi' => nameHi ?? nameEn,
    _ => nameEn,
  };
}

enum PickupKind { autoStand, sharedAuto, taxiStand, ridePickup }

enum Verification { adminVerified, osm, community }

class PickupPoint {
  const PickupPoint({
    required this.id,
    required this.kind,
    required this.nameEn,
    required this.point,
    this.nearStationId,
    this.destinations,
    this.sharedFareInr,
    this.fareSource,
    required this.verification,
    this.verifiedAt,
    required this.sourceId,
  });

  factory PickupPoint.fromJson(Map<String, dynamic> j) => PickupPoint(
    id: j['pickup_id'] as String,
    kind: switch (j['kind']) {
      'shared_auto' => PickupKind.sharedAuto,
      'taxi_stand' => PickupKind.taxiStand,
      'ride_pickup' => PickupKind.ridePickup,
      _ => PickupKind.autoStand,
    },
    nameEn: j['name_en'] as String,
    point: GeoPoint(_d(j['lat'])!, _d(j['lng'])!),
    nearStationId: _s(j['near_station_id']),
    destinations: _s(j['destinations']),
    sharedFareInr: _d(j['shared_fare_inr']),
    fareSource: _s(j['fare_source']),
    verification: switch (j['verification']) {
      'admin_verified' => Verification.adminVerified,
      'community' => Verification.community,
      _ => Verification.osm,
    },
    verifiedAt: _s(j['verified_at']) == null
        ? null
        : DateTime.tryParse(j['verified_at'] as String),
    sourceId: _s(j['source_id']) ?? '',
  );

  final String id;
  final PickupKind kind;
  final String nameEn;
  final GeoPoint point;
  final String? nearStationId;

  /// Shared autos: areas served, e.g. "Yogidham, Gauripada".
  final String? destinations;

  /// Only present when verified; see [fareSource].
  final double? sharedFareInr;
  final String? fareSource;
  final Verification verification;
  final DateTime? verifiedAt;
  final String sourceId;
}

class BusStop {
  const BusStop(this.id, this.nameEn, this.point, this.sourceId);

  factory BusStop.fromJson(Map<String, dynamic> j) => BusStop(
    j['stop_id'] as String,
    j['name_en'] as String,
    GeoPoint(_d(j['lat'])!, _d(j['lng'])!),
    _s(j['source_id']) ?? '',
  );

  final String id;
  final String nameEn;
  final GeoPoint point;
  final String sourceId;
}

class BusRoute {
  const BusRoute({
    required this.id,
    required this.operator,
    required this.number,
    required this.nameEn,
    required this.stopIds,
    this.frequencyNote,
    this.firstDeparture,
    this.lastDeparture,
    required this.sourceId,
  });

  factory BusRoute.fromJson(Map<String, dynamic> j) => BusRoute(
    id: j['bus_route_id'] as String,
    operator: j['operator'] as String,
    number: j['route_number'].toString(),
    nameEn: j['name_en'] as String,
    stopIds: (j['stop_sequence'] as String)
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList(),
    frequencyNote: _s(j['frequency_note']),
    firstDeparture: _s(j['first_departure']),
    lastDeparture: _s(j['last_departure']),
    sourceId: _s(j['source_id']) ?? '',
  );

  final String id;
  final String operator;
  final String number;
  final String nameEn;
  final List<String> stopIds;
  final String? frequencyNote;
  final String? firstDeparture;
  final String? lastDeparture;
  final String sourceId;
}

class FareRule {
  const FareRule({
    required this.id,
    required this.mode,
    required this.minFare,
    required this.minKm,
    this.perKm,
    this.nightMultiplier,
    this.nightStart,
    this.nightEnd,
    required this.effectiveFrom,
    required this.sourceId,
  });

  factory FareRule.fromJson(Map<String, dynamic> j) => FareRule(
    id: j['fare_rule_id'] as String,
    mode: j['mode'] as String,
    minFare: _d(j['min_fare_inr'])!,
    minKm: _d(j['min_km'])!,
    perKm: _d(j['per_km_inr']),
    nightMultiplier: _d(j['night_multiplier']),
    nightStart: _s(j['night_start']),
    nightEnd: _s(j['night_end']),
    effectiveFrom: DateTime.parse(j['effective_from'] as String),
    sourceId: _s(j['source_id']) ?? '',
  );

  final String id;
  final String mode;
  final double minFare;
  final double minKm;
  final double? perKm;
  final double? nightMultiplier;
  final String? nightStart;
  final String? nightEnd;
  final DateTime effectiveFrom;
  final String sourceId;
}

class RideProvider {
  const RideProvider({
    required this.id,
    required this.name,
    required this.categories,
    required this.integration,
    this.androidPackage,
    this.linkTemplate,
  });

  factory RideProvider.fromJson(Map<String, dynamic> j) => RideProvider(
    id: j['provider_id'] as String,
    name: j['name'] as String,
    categories: _s(j['categories']) ?? '',
    integration: _s(j['integration']) ?? 'none',
    androidPackage: _s(j['android_package']),
    linkTemplate: _s(j['link_template']),
  );

  final String id;
  final String name;
  final String categories;

  /// deep_link (trip prefilled) or open_app (opens the provider's app page).
  final String integration;
  final String? androidPackage;
  final String? linkTemplate;

  /// The provider's own app shows the real price; we never show one.
  Uri? bookingUri(
    GeoPoint from,
    GeoPoint to, {
    String fromName = '',
    String toName = '',
  }) {
    if (integration == 'deep_link' && linkTemplate != null) {
      String f(double v) => v.toStringAsFixed(6);
      return Uri.parse(
        linkTemplate!
            .replaceAll('{plat}', f(from.lat))
            .replaceAll('{plng}', f(from.lng))
            .replaceAll('{dlat}', f(to.lat))
            .replaceAll('{dlng}', f(to.lng))
            .replaceAll('{pname}', Uri.encodeComponent(fromName))
            .replaceAll('{dname}', Uri.encodeComponent(toName)),
      );
    }
    if (androidPackage != null) {
      return Uri.parse(
        'https://play.google.com/store/apps/details?id=$androidPackage',
      );
    }
    return null;
  }
}

/// Everything last-mile in the data pack. All lists may be empty.
class LastMileData {
  const LastMileData({
    this.places = const [],
    this.pickupPoints = const [],
    this.busStops = const [],
    this.busRoutes = const [],
    this.fareRules = const [],
    this.providers = const [],
  });

  factory LastMileData.fromPackJson(Map<String, dynamic> j) {
    List<T> list<T>(String key, T Function(Map<String, dynamic>) f) =>
        ((j[key] as List?) ?? const [])
            .map((e) => f((e as Map).cast<String, dynamic>()))
            .toList();
    return LastMileData(
      places: list('places', Place.fromJson),
      pickupPoints: list('pickup_points', PickupPoint.fromJson),
      busStops: list('bus_stops', BusStop.fromJson),
      busRoutes: list('bus_routes', BusRoute.fromJson),
      fareRules: list('fare_rules', FareRule.fromJson),
      providers: list('providers', RideProvider.fromJson),
    );
  }

  final List<Place> places;
  final List<PickupPoint> pickupPoints;
  final List<BusStop> busStops;
  final List<BusRoute> busRoutes;
  final List<FareRule> fareRules;
  final List<RideProvider> providers;
}
