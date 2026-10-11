import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/settings_controller.dart';
import 'l10n/gen/app_localizations.dart';

class MumbaiSmartCommuteApp extends ConsumerStatefulWidget {
  const MumbaiSmartCommuteApp({super.key});

  @override
  ConsumerState<MumbaiSmartCommuteApp> createState() =>
      _MumbaiSmartCommuteAppState();
}

class _MumbaiSmartCommuteAppState extends ConsumerState<MumbaiSmartCommuteApp> {
  late final GoRouter _router = buildRouter();

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp.router(
      onGenerateTitle: (c) => AppLocalizations.of(c).appTitle,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      themeAnimationDuration:
          settings.reducedMotion ? Duration.zero : kThemeAnimationDuration,
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: _router,
      builder: (context, child) => settings.reducedMotion
          ? MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child!,
            )
          : child!,
    );
  }
}
