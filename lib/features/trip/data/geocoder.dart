import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/providers.dart';
import '../../lastmile/domain/lastmile_models.dart';

class GeocodeResult {
  const GeocodeResult({
    required this.name,
    required this.detail,
    required this.point,
  });

  final String name;

  /// Area and city, e.g. "Dombivli East, Kalyan-Dombivli".
  final String detail;
  final GeoPoint point;
}

class GeocodeException implements Exception {
  const GeocodeException(this.message);
  final String message;
  @override
  String toString() => 'GeocodeException: $message';
}

/// Free place search on OpenStreetMap data through a Photon server
/// (https://photon.komoot.io by default; no key, no account).
///
/// Results are limited to the Mumbai region and biased towards Kalyan. Only
/// the typed text is sent, never the user's location. Answers are cached for
/// the session so retyping doesn't repeat requests.
class Geocoder {
  Geocoder({
    required this.baseUrl,
    required this.userAgent,
    http.Client? client,
    this.timeout = const Duration(seconds: 10),
  }) : _http = client ?? http.Client();

  final String baseUrl;
  final String userAgent;
  final Duration timeout;
  final http.Client _http;
  final Map<String, List<GeocodeResult>> _cache = {};

  /// Mumbai Metropolitan Region: west, south, east, north.
  static const bbox = '72.75,18.85,73.50,19.55';

  bool get isAvailable => baseUrl.isNotEmpty;

  Future<List<GeocodeResult>> search(String query, {int limit = 8}) async {
    final q = query.trim();
    if (q.length < 3 || !isAvailable) return const [];
    final key = q.toLowerCase();
    final cached = _cache[key];
    if (cached != null) return cached;

    final uri = Uri.parse(baseUrl).replace(queryParameters: {
      'q': q,
      'limit': '$limit',
      'lang': 'en',
      'bbox': bbox,
      'lat': '19.2358',
      'lon': '73.1308',
    });
    final http.Response res;
    try {
      res = await _http
          .get(uri, headers: {'User-Agent': userAgent})
          .timeout(timeout);
    } on TimeoutException {
      throw const GeocodeException('timeout');
    } on Exception catch (e) {
      throw GeocodeException('network: $e');
    }
    if (res.statusCode != 200) {
      throw GeocodeException('http ${res.statusCode}');
    }
    final List<GeocodeResult> out;
    try {
      out = parse(jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>);
    } on Object {
      throw const GeocodeException('bad response');
    }
    _cache[key] = out;
    return out;
  }

  /// Parses a Photon GeoJSON answer, dropping duplicates and unnamed hits.
  static List<GeocodeResult> parse(Map<String, dynamic> json) {
    final out = <GeocodeResult>[];
    final seen = <String>{};
    for (final f in (json['features'] as List? ?? const [])) {
      final props = ((f as Map)['properties'] as Map?) ?? const {};
      final coords = ((f['geometry'] as Map?)?['coordinates'] as List?) ?? const [];
      if (coords.length < 2) continue;
      String? s(String k) {
        final v = props[k]?.toString().trim();
        return v == null || v.isEmpty ? null : v;
      }

      final street = s('street');
      final name = s('name') ??
          (street == null ? null : [s('housenumber'), street].whereType<String>().join(' '));
      if (name == null) continue;
      final detailParts = <String>[];
      for (final k in ['street', 'locality', 'district', 'city', 'county']) {
        final v = s(k);
        if (v != null && v != name && !detailParts.contains(v)) detailParts.add(v);
      }
      final lng = (coords[0] as num).toDouble();
      final lat = (coords[1] as num).toDouble();
      final dedupe = '${name.toLowerCase()}|${lat.toStringAsFixed(3)}|${lng.toStringAsFixed(3)}';
      if (!seen.add(dedupe)) continue;
      out.add(GeocodeResult(
        name: name,
        detail: detailParts.take(3).join(', '),
        point: GeoPoint(lat, lng),
      ));
    }
    return out;
  }
}

final geocoderProvider = Provider<Geocoder>((ref) {
  final config = ref.watch(appConfigProvider);
  return Geocoder(
    baseUrl: config.geocoderUrl,
    userAgent: '${config.userAgentPackage} (Mumbai Smart Commute)',
  );
});
