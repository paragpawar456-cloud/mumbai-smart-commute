import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

/// Structured error from the backend or the network layer.
class ApiException implements Exception {
  const ApiException(this.code, this.message, {this.statusCode});

  final String code;
  final String message;
  final int? statusCode;

  bool get isNetwork => code == 'network';

  @override
  String toString() => 'ApiException($code): $message';
}

typedef IdTokenProvider = Future<String?> Function();

/// Thin client for the Apps Script backend.
///
/// Apps Script web apps only expose `doGet`/`doPost`, so every call is a POST
/// with `{action, payload, idToken, requestId}` and the server routes on
/// `action`. Apps Script answers POSTs with a 302 to a googleusercontent URL;
/// `http` follows it for us.
class ApiClient {
  ApiClient({
    required this.baseUrl,
    required this.idTokenProvider,
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 20),
  }) : _http = httpClient ?? http.Client();

  final String baseUrl;
  final IdTokenProvider idTokenProvider;
  final Duration timeout;
  final http.Client _http;
  final Random _random = Random.secure();

  bool get isConfigured => baseUrl.isNotEmpty;

  Future<Map<String, dynamic>> call(
    String action, {
    Map<String, dynamic> payload = const {},
    bool authenticated = false,
  }) async {
    if (!isConfigured) {
      throw const ApiException('not_configured', 'Backend URL is not set');
    }
    final token = authenticated ? await idTokenProvider() : null;
    if (authenticated && token == null) {
      throw const ApiException('unauthenticated', 'Sign in required');
    }
    final body = jsonEncode({
      'action': action,
      'payload': payload,
      'idToken': ?token,
      // Lets the server drop duplicate submissions on retries.
      'requestId': _requestId(),
    });

    final http.Response res;
    try {
      res = await _http
          .post(
            Uri.parse(baseUrl),
            headers: {'Content-Type': 'text/plain;charset=utf-8'},
            body: body,
          )
          .timeout(timeout);
    } on TimeoutException {
      throw const ApiException('network', 'Request timed out');
    } on http.ClientException catch (e) {
      throw ApiException('network', e.message);
    }

    final Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(res.body) as Map<String, dynamic>;
    } on FormatException {
      throw ApiException('bad_response', 'Server returned non-JSON',
          statusCode: res.statusCode);
    }
    if (decoded['ok'] != true) {
      final err = (decoded['error'] as Map?) ?? const {};
      throw ApiException(
        (err['code'] as String?) ?? 'unknown',
        (err['message'] as String?) ?? 'Unknown error',
        statusCode: res.statusCode,
      );
    }
    return (decoded['data'] as Map?)?.cast<String, dynamic>() ?? const {};
  }

  String _requestId() =>
      List.generate(16, (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'))
          .join();
}
