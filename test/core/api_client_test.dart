import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mumbai_smart_commute/core/network/api_client.dart';

void main() {
  ApiClient client(MockClientHandler handler, {String? token}) => ApiClient(
        baseUrl: 'https://script.google.com/macros/s/x/exec',
        idTokenProvider: () async => token,
        httpClient: MockClient(handler),
      );

  test('sends action, payload and requestId; returns data', () async {
    late Map<String, dynamic> sent;
    final api = client((req) async {
      sent = jsonDecode(req.body) as Map<String, dynamic>;
      return http.Response(jsonEncode({'ok': true, 'data': {'status': 'up'}}), 200);
    });

    final data = await api.call('health', payload: {'a': 1});

    expect(data, {'status': 'up'});
    expect(sent['action'], 'health');
    expect(sent['payload'], {'a': 1});
    expect(sent['requestId'], isA<String>());
    expect(sent.containsKey('idToken'), isFalse);
  });

  test('attaches ID token for authenticated calls', () async {
    late Map<String, dynamic> sent;
    final api = client((req) async {
      sent = jsonDecode(req.body) as Map<String, dynamic>;
      return http.Response(jsonEncode({'ok': true, 'data': {}}), 200);
    }, token: 'tok');
    await api.call('getProfile', authenticated: true);
    expect(sent['idToken'], 'tok');
  });

  test('authenticated call without a user fails before the network', () async {
    var called = false;
    final api = client((req) async {
      called = true;
      return http.Response('{}', 200);
    });
    expect(
      () => api.call('getProfile', authenticated: true),
      throwsA(isA<ApiException>()
          .having((e) => e.code, 'code', 'unauthenticated')),
    );
    expect(called, isFalse);
  });

  test('maps structured server errors', () async {
    final api = client((req) async => http.Response(
        jsonEncode({
          'ok': false,
          'error': {'code': 'rate_limited', 'message': 'Slow down'}
        }),
        200));
    expect(
      () => api.call('submitReport'),
      throwsA(isA<ApiException>().having((e) => e.code, 'code', 'rate_limited')),
    );
  });

  test('non-JSON response is a bad_response, never fake data', () async {
    final api = client((req) async => http.Response('<html>', 200));
    expect(
      () => api.call('health'),
      throwsA(isA<ApiException>().having((e) => e.code, 'code', 'bad_response')),
    );
  });

  test('unconfigured client refuses to call', () async {
    final api = ApiClient(baseUrl: '', idTokenProvider: () async => null);
    expect(
      () => api.call('health'),
      throwsA(isA<ApiException>().having((e) => e.code, 'code', 'not_configured')),
    );
  });
}
