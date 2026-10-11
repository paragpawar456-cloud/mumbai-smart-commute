/// Build-time configuration, supplied with
/// `flutter run --dart-define-from-file=config/dev.json`.
///
/// Nothing in here is a secret: the Firebase values are public client
/// identifiers and the backend URL is a public Apps Script endpoint that
/// checks every private request server-side. Never put service-account keys,
/// the Sheet ID or admin credentials in these files.
class AppConfig {
  const AppConfig({
    required this.environment,
    required this.backendUrl,
    required this.firebaseApiKey,
    required this.firebaseAppId,
    required this.firebaseProjectId,
    required this.firebaseMessagingSenderId,
    required this.tileUrlTemplate,
    required this.userAgentPackage,
  });

  factory AppConfig.fromEnvironment() => const AppConfig(
        environment: String.fromEnvironment('APP_ENV', defaultValue: 'dev'),
        backendUrl: String.fromEnvironment('BACKEND_URL'),
        firebaseApiKey: String.fromEnvironment('FIREBASE_API_KEY'),
        firebaseAppId: String.fromEnvironment('FIREBASE_APP_ID'),
        firebaseProjectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
        firebaseMessagingSenderId:
            String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
        tileUrlTemplate: String.fromEnvironment(
          'TILE_URL_TEMPLATE',
          defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),
        userAgentPackage: String.fromEnvironment(
          'USER_AGENT_PACKAGE',
          defaultValue: 'com.mumbaismartcommute.mumbai_smart_commute',
        ),
      );

  final String environment;
  final String backendUrl;
  final String firebaseApiKey;
  final String firebaseAppId;
  final String firebaseProjectId;
  final String firebaseMessagingSenderId;

  /// Kept configurable so the tile provider can change without an app update
  /// (OSMF tile usage policy recommends this).
  final String tileUrlTemplate;
  final String userAgentPackage;

  bool get isProduction => environment == 'prod';
  bool get hasBackend => backendUrl.isNotEmpty;
  bool get hasFirebase =>
      firebaseApiKey.isNotEmpty &&
      firebaseAppId.isNotEmpty &&
      firebaseProjectId.isNotEmpty &&
      firebaseMessagingSenderId.isNotEmpty;
}
