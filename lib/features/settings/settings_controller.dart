import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Overridden in main() once SharedPreferences has loaded.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider not overridden'),
);

class AppSettings {
  const AppSettings({
    this.locale,
    this.themeMode = ThemeMode.system,
    this.reducedMotion = false,
  });

  /// null follows the device language.
  final Locale? locale;
  final ThemeMode themeMode;
  final bool reducedMotion;

  AppSettings copyWith({
    Locale? Function()? locale,
    ThemeMode? themeMode,
    bool? reducedMotion,
  }) =>
      AppSettings(
        locale: locale != null ? locale() : this.locale,
        themeMode: themeMode ?? this.themeMode,
        reducedMotion: reducedMotion ?? this.reducedMotion,
      );
}

class SettingsController extends Notifier<AppSettings> {
  static const _kLocale = 'settings.locale';
  static const _kTheme = 'settings.themeMode';
  static const _kMotion = 'settings.reducedMotion';

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  AppSettings build() {
    final code = _prefs.getString(_kLocale);
    final theme = _prefs.getString(_kTheme);
    return AppSettings(
      locale: code == null ? null : Locale(code),
      themeMode: ThemeMode.values.firstWhere(
        (m) => m.name == theme,
        orElse: () => ThemeMode.system,
      ),
      reducedMotion: _prefs.getBool(_kMotion) ?? false,
    );
  }

  Future<void> setLocale(Locale? locale) async {
    state = state.copyWith(locale: () => locale);
    if (locale == null) {
      await _prefs.remove(_kLocale);
    } else {
      await _prefs.setString(_kLocale, locale.languageCode);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs.setString(_kTheme, mode.name);
  }

  Future<void> setReducedMotion(bool value) async {
    state = state.copyWith(reducedMotion: value);
    await _prefs.setBool(_kMotion, value);
  }
}

final settingsProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);
