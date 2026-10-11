import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

import '../../../core/network/api_client.dart';
import '../domain/models.dart';

enum PackOrigin { bundled, cached, server }

class LoadedPack {
  const LoadedPack(this.pack, this.origin, {this.refreshError});

  final DataPack pack;
  final PackOrigin origin;

  /// Set when the server could not be reached; the app keeps working on
  /// the bundled or cached pack and says so.
  final ApiException? refreshError;
}

/// Bundled pack (always available) → cached pack (last download) → server
/// pack (only downloaded when its version is newer).
class DataPackRepository {
  DataPackRepository({
    required this.api,
    Future<Directory> Function()? cacheDir,
    Future<String> Function()? loadBundled,
  })  : _cacheDir = cacheDir ?? getApplicationSupportDirectory,
        _loadBundled = loadBundled ??
            (() => rootBundle.loadString('assets/data/seed_pack.json'));

  static const _fileName = 'data_pack.json';

  final ApiClient api;
  final Future<Directory> Function() _cacheDir;
  final Future<String> Function() _loadBundled;

  Future<File> _file() async => File('${(await _cacheDir()).path}/$_fileName');

  Future<LoadedPack> loadLocal() async {
    final bundled = DataPack.fromJson(
        jsonDecode(await _loadBundled()) as Map<String, dynamic>);
    try {
      final f = await _file();
      if (await f.exists()) {
        final cached = DataPack.fromJson(
            jsonDecode(await f.readAsString()) as Map<String, dynamic>);
        if (cached.version >= bundled.version) {
          return LoadedPack(cached, PackOrigin.cached);
        }
      }
    } on Object {
      // A corrupt cache is ignored; the bundled pack still works.
    }
    return LoadedPack(bundled, PackOrigin.bundled);
  }

  Future<LoadedPack> refresh(LoadedPack current) async {
    if (!api.isConfigured) return current;
    try {
      final data = await api.call('getDataPack',
          payload: {'haveVersion': current.pack.version});
      if (data['unchanged'] == true) return current;
      final DataPack pack;
      final Map<String, dynamic> json;
      try {
        json = (data['pack'] as Map).cast<String, dynamic>();
        pack = DataPack.fromJson(json);
      } on Object {
        // A broken pack from the server must never replace a working one.
        return LoadedPack(current.pack, current.origin,
            refreshError: const ApiException('bad_response', 'Invalid data pack'));
      }
      if (pack.version <= current.pack.version) return current;
      try {
        await (await _file()).writeAsString(jsonEncode(json), flush: true);
      } on Object {
        // Can't cache (disk full, no storage): still use it for this session.
      }
      return LoadedPack(pack, PackOrigin.server);
    } on ApiException catch (e) {
      return LoadedPack(current.pack, current.origin, refreshError: e);
    }
  }
}
