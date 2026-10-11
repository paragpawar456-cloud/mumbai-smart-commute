import '../../lastmile/domain/lastmile_models.dart';

/// Where a [TripPoint] came from, so the app can say how it knows it.
enum TripPointSource { station, place, osm, myLocation, pin }

/// One end of a door-to-door trip: a station, a place in the data pack, an
/// OpenStreetMap search result, the phone's location or a pin on the map.
class TripPoint {
  const TripPoint({
    required this.name,
    required this.point,
    required this.source,
    this.stationId,
  });

  final String name;
  final GeoPoint point;
  final TripPointSource source;

  /// Set only when this point is a station in the network.
  final String? stationId;

  bool get isStation => stationId != null;

  Map<String, String> toQuery(String prefix) => {
        '${prefix}Name': name,
        '${prefix}Lat': point.lat.toStringAsFixed(6),
        '${prefix}Lng': point.lng.toStringAsFixed(6),
        '${prefix}Src': source.name,
        '${prefix}Station': ?stationId,
      };

  static TripPoint? fromQuery(Map<String, String> q, String prefix) {
    final lat = double.tryParse(q['${prefix}Lat'] ?? '');
    final lng = double.tryParse(q['${prefix}Lng'] ?? '');
    final name = q['${prefix}Name'];
    if (lat == null || lng == null || name == null) return null;
    return TripPoint(
      name: name,
      point: GeoPoint(lat, lng),
      source: TripPointSource.values
              .where((s) => s.name == q['${prefix}Src'])
              .firstOrNull ??
          TripPointSource.pin,
      stationId: q['${prefix}Station'],
    );
  }
}
