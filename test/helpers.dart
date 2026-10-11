import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mumbai_smart_commute/app.dart';
import 'package:mumbai_smart_commute/core/config/app_config.dart';
import 'package:mumbai_smart_commute/core/providers.dart';
import 'package:mumbai_smart_commute/features/settings/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

const testConfig = AppConfig(
  environment: 'test',
  backendUrl: '',
  firebaseApiKey: '',
  firebaseAppId: '',
  firebaseProjectId: '',
  firebaseMessagingSenderId: '',
  tileUrlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  userAgentPackage: 'test',
);

Future<Widget> buildTestApp({Map<String, Object> prefs = const {}}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [
      appConfigProvider.overrideWithValue(testConfig),
      sharedPreferencesProvider.overrideWithValue(sp),
    ],
    child: const MumbaiSmartCommuteApp(),
  );
}
