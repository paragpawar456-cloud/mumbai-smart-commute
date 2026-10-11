import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/providers.dart';
import 'features/auth/auth_repository.dart';
import 'features/settings/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = AppConfig.fromEnvironment();
  final prefs = await SharedPreferences.getInstance();

  AuthRepository auth = const UnavailableAuthRepository();
  if (config.hasFirebase) {
    try {
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: config.firebaseApiKey,
          appId: config.firebaseAppId,
          projectId: config.firebaseProjectId,
          messagingSenderId: config.firebaseMessagingSenderId,
        ),
      );
      auth = FirebaseAuthRepository(FirebaseAuth.instance);
    } on Exception catch (e) {
      // The app stays usable in guest mode; sign-in shows "not configured".
      debugPrint('Firebase init failed: $e');
    }
  }

  runApp(ProviderScope(
    overrides: [
      appConfigProvider.overrideWithValue(config),
      sharedPreferencesProvider.overrideWithValue(prefs),
      authRepositoryProvider.overrideWithValue(auth),
    ],
    child: const MumbaiSmartCommuteApp(),
  ));
}
