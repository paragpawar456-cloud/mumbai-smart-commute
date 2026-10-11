import '../../l10n/gen/app_localizations.dart';

/// Which build this is, set by CI with --dart-define, so testers can tell
/// whether they have the latest APK.
abstract final class BuildInfo {
  static const number = String.fromEnvironment('BUILD_NUMBER');
  static const sha = String.fromEnvironment('BUILD_SHA');

  static String label(AppLocalizations l) => number.isEmpty
      ? l.buildLabelLocal
      : l.buildLabel(number, sha.length >= 7 ? sha.substring(0, 7) : sha);
}
