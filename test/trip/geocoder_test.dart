import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mumbai_smart_commute/features/trip/data/geocoder.dart';

const photonAnswer = {
  'type': 'FeatureCollection',
  'features': [
    {
      'type': 'Feature',
      'geometry': {'type': 'Point', 'coordinates': [73.0950, 19.2140]},
      'properties': {
        'name': 'Runwal Garden City',
        'district': 'Dombivli East',
        'city': 'Kalyan-Dombivli',
        'osm_key': 'place',
      },
    },
    // Same place twice: kept once.
    {
      'type': 'Feature',
      'geometry': {'type': 'Point', 'coordinates': [73.09501, 19.21401]},
      'properties': {'name': 'Runwal Garden City', 'city': 'Kalyan-Dombivli'},
    },
    // A street address with no name.
    {
      'type': 'Feature',
      'geometry': {'type': 'Point', 'coordinates': [73.1, 19.2]},
      'properties': {'street': 'Runwal Road', 'housenumber': '4'},
    },
    // Nothing usable.
    {
      'type': 'Feature',
      'geometry': {'type': 'Point', 'coordinates': [73.1, 19.2]},
      'properties': <String, Object>{},
    },
  ],
};

void main() {
  test('parses Photon results, dropping duplicates and unnamed hits', () {
    final r = Geocoder.parse(photonAnswer);
    expect(r.map((e) => e.name), ['Runwal Garden City', '4 Runwal Road']);
    expect(r.first.detail, 'Dombivli East, Kalyan-Dombivli');
    expect(r.first.point.lat, 19.2140);
    expect(r.first.point.lng, 73.0950);
  });

  test('sends only the text, limited to the Mumbai region, and caches', () async {
    var calls = 0;
    late Uri seen;
    final g = Geocoder(
      baseUrl: 'https://photon.example/api/',
      userAgent: 'test',
      client: MockClient((req) async {
        calls++;
        seen = req.url;
        return http.Response.bytes(utf8.encode(jsonEncode(photonAnswer)), 200);
      }),
    );
    expect(await g.search('ru'), isEmpty, reason: 'too short to search');
    expect(calls, 0);
    final r = await g.search('Runwal');
    expect(r, hasLength(2));
    expect(seen.queryParameters['q'], 'Runwal');
    expect(seen.queryParameters['bbox'], Geocoder.bbox);
    await g.search('runwal ');
    expect(calls, 1, reason: 'cached');
  });

  test('server errors become a GeocodeException', () async {
    final g = Geocoder(
      baseUrl: 'https://photon.example/api/',
      userAgent: 'test',
      client: MockClient((_) async => http.Response('busy', 503)),
    );
    expect(g.search('Runwal'), throwsA(isA<GeocodeException>()));
  });

  test('no URL means online search is off', () async {
    final g = Geocoder(baseUrl: '', userAgent: 'test');
    expect(g.isAvailable, isFalse);
    expect(await g.search('Runwal'), isEmpty);
  });
}
