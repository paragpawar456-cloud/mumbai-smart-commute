import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers.dart';
import '../../transit/data/transit_providers.dart';
import '../domain/lastmile_engine.dart';
import '../domain/lastmile_models.dart';

final lastMileEngineProvider = Provider<LastMileEngine?>((ref) {
  final pack = ref.watch(dataPackProvider).value?.pack;
  return pack == null ? null : LastMileEngine(pack.lastMile);
});

List<Place> searchPlaces(LastMileData data, String query, {int limit = 20}) {
  final q = normalizeSearch(query);
  if (q.isEmpty) return const [];
  final hits = <(int, Place)>[];
  for (final p in data.places) {
    var best = 99;
    for (final n in [p.nameEn, p.nameMr, p.nameHi]) {
      if (n == null) continue;
      final v = normalizeSearch(n);
      final s = v.startsWith(q)
          ? 0
          : v.split(' ').any((w) => w.startsWith(q))
              ? 1
              : v.contains(q)
                  ? 2
                  : 99;
      if (s < best) best = s;
    }
    if (best < 99) hits.add((best, p));
  }
  hits.sort((a, b) {
    final c = a.$1.compareTo(b.$1);
    return c != 0 ? c : a.$2.nameEn.compareTo(b.$2.nameEn);
  });
  return hits.take(limit).map((e) => e.$2).toList();
}

const reportTypes = [
  'queue',
  'no_vehicles',
  'stand_moved',
  'stop_issue',
  'closure',
  'disruption',
];

class CommunityReport {
  const CommunityReport({
    required this.id,
    required this.type,
    required this.point,
    required this.note,
    required this.createdAt,
    required this.expiresAt,
    required this.corroborations,
    this.targetId,
  });

  factory CommunityReport.fromJson(Map<String, dynamic> j) => CommunityReport(
        id: j['reportId'] as String,
        type: j['type'] as String,
        targetId: j['targetId'] as String?,
        point: GeoPoint(
            (j['lat'] as num).toDouble(), (j['lng'] as num).toDouble()),
        note: (j['note'] as String?) ?? '',
        createdAt: DateTime.parse(j['createdAt'] as String),
        expiresAt: DateTime.parse(j['expiresAt'] as String),
        corroborations: (j['corroborations'] as num?)?.toInt() ?? 0,
      );

  final String id;
  final String type;
  final String? targetId;
  final GeoPoint point;
  final String note;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int corroborations;
}

class RoadDistance {
  const RoadDistance(this.km, this.attribution);
  final double km;
  final String attribution;
}

/// Server calls for the last-mile screen. Everything here is optional: when
/// the backend isn't configured the screen still works from the data pack.
class LastMileApi {
  const LastMileApi(this.api);
  final ApiClient api;

  bool get available => api.isConfigured;

  Future<List<CommunityReport>> reportsNear(GeoPoint p) async {
    final d = await api.call('listReports',
        payload: {'lat': p.lat, 'lng': p.lng, 'radiusKm': 2});
    return ((d['reports'] as List?) ?? const [])
        .map((e) => CommunityReport.fromJson((e as Map).cast()))
        .toList();
  }

  Future<void> submit({
    required String type,
    required GeoPoint at,
    String? targetId,
    String note = '',
  }) =>
      api.call('submitReport', authenticated: true, payload: {
        'type': type,
        'lat': at.lat,
        'lng': at.lng,
        'targetId': ?targetId,
        if (note.trim().isNotEmpty) 'note': note.trim(),
      });

  Future<int> confirm(String reportId) async {
    final d = await api.call('corroborateReport',
        authenticated: true, payload: {'reportId': reportId});
    return (d['corroborations'] as num).toInt();
  }

  /// Null when unavailable for any reason; callers fall back to an estimate.
  Future<RoadDistance?> roadDistance(GeoPoint from, GeoPoint to) async {
    try {
      final d = await api.call('roadDistance', authenticated: true, payload: {
        'fromLat': from.lat,
        'fromLng': from.lng,
        'toLat': to.lat,
        'toLng': to.lng,
      });
      if (d['available'] != true) return null;
      return RoadDistance(
          (d['km'] as num).toDouble(), (d['attribution'] as String?) ?? '');
    } on ApiException {
      return null;
    }
  }
}

final lastMileApiProvider =
    Provider((ref) => LastMileApi(ref.watch(apiClientProvider)));

final reportsNearProvider =
    FutureProvider.autoDispose.family<List<CommunityReport>, String>(
        (ref, stationId) async {
  final api = ref.watch(lastMileApiProvider);
  final pack = ref.watch(dataPackProvider).value?.pack;
  final s = pack?.stationById[stationId];
  if (!api.available || s == null) return const [];
  return api.reportsNear(GeoPoint(s.lat, s.lng));
});
