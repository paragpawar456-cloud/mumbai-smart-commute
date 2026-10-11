import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mumbai_smart_commute/core/network/api_client.dart';
import 'package:mumbai_smart_commute/features/transit/data/data_pack_repository.dart';

/// Failure modes: whatever the network or disk does, the app keeps a
/// working data pack and never shows data it couldn't validate.
void main() {
  final seed = File('assets/data/seed_pack.json').readAsStringSync();
  final seedJson = jsonDecode(seed) as Map<String, dynamic>;
  late Directory dir;

  setUp(() => dir = Directory.systemTemp.createTempSync('pack'));
  tearDown(() => dir.deleteSync(recursive: true));

  ApiClient api(Future<http.Response> Function(http.Request) handler) => ApiClient(
      baseUrl: 'https://example.test/exec',
      idTokenProvider: () async => null,
      httpClient: MockClient(handler),
      timeout: const Duration(milliseconds: 200));

  // No charset header, like a bare Apps Script reply: bytes are UTF-8.
  http.Response ok(Object data) =>
      http.Response.bytes(utf8.encode(jsonEncode({'ok': true, 'data': data})), 200);

  DataPackRepository repo(ApiClient a, {Future<Directory> Function()? cacheDir}) =>
      DataPackRepository(
          api: a, cacheDir: cacheDir ?? (() async => dir), loadBundled: () async => seed);

  test('corrupt cache file falls back to the bundled pack', () async {
    File('${dir.path}/data_pack.json').writeAsStringSync('{"version": 99, "broken');
    final r = await repo(api((_) async => ok({}))).loadLocal();
    expect(r.origin, PackOrigin.bundled);
  });

  test('server timeout keeps the current pack and reports the problem', () async {
    final r = repo(api((_) => Completer<http.Response>().future));
    final local = await r.loadLocal();
    final next = await r.refresh(local);
    expect(next.pack.version, local.pack.version);
    expect(next.refreshError?.code, 'network');
  });

  test('server HTML error page is rejected', () async {
    final r = repo(api((_) async => http.Response('<html>Google error</html>', 200)));
    final next = await r.refresh(await r.loadLocal());
    expect(next.refreshError?.code, 'bad_response');
  });

  test('malformed pack from the server never replaces a working one', () async {
    final r = repo(api((_) async => ok({'pack': {'version': 99, 'stations': 'nope'}})));
    final local = await r.loadLocal();
    final next = await r.refresh(local);
    expect(next.pack, same(local.pack));
    expect(next.refreshError?.code, 'bad_response');
    expect(File('${dir.path}/data_pack.json').existsSync(), isFalse);
  });

  test('older or equal version from the server is ignored', () async {
    final r = repo(api((_) async => ok({'pack': seedJson})));
    final local = await r.loadLocal();
    expect(identical(await r.refresh(local), local), isTrue);
  });

  test('newer pack is used and cached for next launch', () async {
    final newer = {...seedJson, 'version': (seedJson['version'] as int) + 1};
    final r = repo(api((_) async => ok({'pack': newer})));
    final next = await r.refresh(await r.loadLocal());
    expect(next.origin, PackOrigin.server);
    final again = await repo(api((_) async => ok({}))).loadLocal();
    expect(again.origin, PackOrigin.cached);
    expect(again.pack.version, newer['version']);
    expect(next.pack.stationById['KYN']!.nameMr, 'कल्याण जंक्शन');
  });

  test('a newer pack is still used when it cannot be cached', () async {
    final newer = {...seedJson, 'version': (seedJson['version'] as int) + 1};
    var calls = 0;
    final r = repo(api((_) async => ok({'pack': newer})), cacheDir: () async {
      if (calls++ > 0) throw const FileSystemException('disk full');
      return dir;
    });
    final next = await r.refresh(await r.loadLocal());
    expect(next.origin, PackOrigin.server);
  });
}
