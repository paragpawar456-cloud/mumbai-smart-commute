import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/providers.dart';

/// Admin/moderator server calls. The server re-checks the caller's role on
/// every one, so these are safe to expose in the app.
class AdminApi {
  const AdminApi(this._api);
  final ApiClient _api;

  Future<Map<String, dynamic>> _c(String action,
          [Map<String, dynamic> payload = const {}]) =>
      _api.call(action, payload: payload, authenticated: true);

  Future<Map<String, dynamic>> overview() => _c('adminOverview');

  Future<List<Map<String, dynamic>>> users(String query) async =>
      ((await _c('adminListUsers', {'query': query, 'pageSize': 50}))['users']
              as List)
          .cast<Map>()
          .map((m) => m.cast<String, dynamic>())
          .toList();

  Future<void> setStatus(String uid, String status) =>
      _c('adminSetUserStatus', {'uid': uid, 'status': status});

  Future<void> setRole(String uid, String role) =>
      _c('adminSetUserRole', {'uid': uid, 'role': role});

  Future<List<Map<String, dynamic>>> pendingReports() async =>
      ((await _c('modListReports', {'status': 'pending'}))['reports'] as List)
          .cast<Map>()
          .map((m) => m.cast<String, dynamic>())
          .toList();

  Future<void> moderate(String reportId, String decision) =>
      _c('moderateReport', {'reportId': reportId, 'decision': decision});

  Future<List<Map<String, dynamic>>> alerts() async =>
      ((await _c('adminListAlerts'))['alerts'] as List)
          .cast<Map>()
          .map((m) => m.cast<String, dynamic>())
          .toList();

  Future<void> saveAlert(Map<String, dynamic> alert) =>
      _c('adminSaveAlert', alert);

  Future<void> endAlert(String id) => _c('adminEndAlert', {'alertId': id});

  Future<List<Map<String, dynamic>>> audit({int page = 0}) async =>
      ((await _c('adminListAudit', {'page': page, 'pageSize': 50}))['entries']
              as List)
          .cast<Map>()
          .map((m) => m.cast<String, dynamic>())
          .toList();
}

final adminApiProvider =
    Provider((ref) => AdminApi(ref.watch(apiClientProvider)));
