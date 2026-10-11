import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/account/privacy_screen.dart';
import '../../features/admin/admin_screen.dart';
import '../../features/auth/sign_in_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/lastmile/ui/lastmile_screen.dart';
import '../../features/map/map_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/routes/routes_screen.dart';
import '../../features/saved/saved_screen.dart';
import '../../features/transit/ui/station_screen.dart';
import '../../shared/widgets/app_shell.dart';

GoRouter buildRouter() => GoRouter(
      initialLocation: '/',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) =>
              AppShell(navigationShell: shell),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/routes',
                builder: (_, state) => RoutesScreen(
                  key: ValueKey(state.uri.query),
                  from: state.uri.queryParameters['from'],
                  to: state.uri.queryParameters['to'],
                  fromId: state.uri.queryParameters['fromId'],
                  toId: state.uri.queryParameters['toId'],
                ),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/map',
                builder: (_, state) => MapScreen(
                    focusStationId: state.uri.queryParameters['station']),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: '/saved', builder: (_, _) => const SavedScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                  path: '/profile', builder: (_, _) => const ProfileScreen()),
            ]),
          ],
        ),
        GoRoute(
          path: '/station/:id',
          builder: (_, state) =>
              StationScreen(stationId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/last-mile',
          builder: (_, state) => LastMileScreen(
            fromStationId: state.uri.queryParameters['from'],
            placeId: state.uri.queryParameters['place'],
          ),
        ),
        GoRoute(path: '/admin', builder: (_, _) => const AdminScreen()),
        GoRoute(path: '/privacy', builder: (_, _) => const PrivacyScreen()),
        GoRoute(
          path: '/sign-in',
          pageBuilder: (_, _) =>
              const MaterialPage(fullscreenDialog: true, child: SignInScreen()),
        ),
      ],
    );
