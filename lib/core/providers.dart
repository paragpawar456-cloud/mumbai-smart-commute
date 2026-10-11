import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/auth_repository.dart';
import 'config/app_config.dart';
import 'network/api_client.dart';

final appConfigProvider = Provider<AppConfig>((ref) => AppConfig.fromEnvironment());

/// Overridden in main() with the Firebase implementation when configured.
final authRepositoryProvider =
    Provider<AuthRepository>((ref) => const UnavailableAuthRepository());

final authStateProvider = StreamProvider<AppUser?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
);

final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(appConfigProvider);
  final auth = ref.watch(authRepositoryProvider);
  return ApiClient(baseUrl: config.backendUrl, idTokenProvider: auth.idToken);
});

/// Accounts (sign-in, reports, admin) appear only when the build has both a
/// Firebase config and a backend URL. Until the owner sets those up, the app
/// shows no sign-in anywhere and works fully as a guest.
final accountsEnabledProvider = Provider<bool>((ref) =>
    ref.watch(authRepositoryProvider).isAvailable &&
    ref.watch(apiClientProvider).isConfigured);

enum BackendStatus { ok, notConfigured, unreachable }

final backendStatusProvider = FutureProvider<BackendStatus>((ref) async {
  final api = ref.watch(apiClientProvider);
  if (!api.isConfigured) return BackendStatus.notConfigured;
  try {
    await api.call('health');
    return BackendStatus.ok;
  } on ApiException {
    return BackendStatus.unreachable;
  }
});
