import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';

/// Bump when the privacy notice text changes; signed-in users are asked to
/// accept the new version.
const privacyNoticeVersion = '2026-10-v1';

/// What the server knows about the signed-in user. The role here only
/// decides which screens the app shows; every admin action is checked
/// again on the server.
class ServerProfile {
  const ServerProfile({required this.role, required this.consentVersion});

  factory ServerProfile.fromJson(Map<String, dynamic> j) => ServerProfile(
        role: (j['role'] as String?) ?? 'user',
        consentVersion: (j['consentVersion'] as String?) ?? '',
      );

  final String role;
  final String consentVersion;

  bool get isAdmin => role == 'admin';
  bool get canModerate => role == 'admin' || role == 'moderator';
  bool get needsConsent => consentVersion != privacyNoticeVersion;
}

/// Null when signed out or when there is no server.
final serverProfileProvider = FutureProvider<ServerProfile?>((ref) async {
  final user = ref.watch(authStateProvider).value;
  final api = ref.watch(apiClientProvider);
  if (user == null || !api.isConfigured) return null;
  final d = await api.call('getProfile', authenticated: true);
  return ServerProfile.fromJson((d['profile'] as Map).cast());
});

Future<void> acceptPrivacyNotice(WidgetRef ref) async {
  await ref.read(apiClientProvider).call('updateProfile',
      authenticated: true, payload: {'consentVersion': privacyNoticeVersion});
  ref.invalidate(serverProfileProvider);
}
