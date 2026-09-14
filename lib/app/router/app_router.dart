import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:starter/features/auth/presentation/screens/login_screen.dart';

import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../config/app_config.dart';
import '../startup/splash_screen.dart';
import 'router_refresh.dart';
import 'routes_names.dart';

GoRouter createRouter({
  required AuthCubit authCubit,
  required AppConfig config,
}) {
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  final shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

  // final dashboardNavigatorKey = GlobalKey<NavigatorState>(
  //   debugLabel: 'dashboard',
  // );
  //
  // final searchNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'search');
  //
  // final accountNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'account');

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: !config.isProduction,
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    redirect: (context, state) {
      final authStatus = authCubit.state.status;
      final location = state.matchedLocation;

      final isSplash = location == RouteNames.splash;
      final isLogin = location == RouteNames.login;

      // Authentication status is still being determined.
      if (authStatus == AuthStatus.unknown) {
        return isSplash ? null : RouteNames.splash;
      }

      // User is not authenticated.
      if (authStatus == AuthStatus.unauthenticated) {
        return isLogin ? null : RouteNames.login;
      }

      // User is authenticated.
      if (authStatus == AuthStatus.authenticated) {
        if (isSplash || isLogin) {
          return RouteNames.dashboard;
        }
      }

      return null;
    },

    routes: [
      // ----------------------------------------------------------------------
      // Splash
      // ----------------------------------------------------------------------

      GoRoute(
        path: RouteNames.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: RouteNames.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // ----------------------------------------------------------------------
      // Authentication
      // ----------------------------------------------------------------------
      // GoRoute(
      //   path: RouteNames.login,
      //   name: RouteNames.login,
      //   builder: (context, state) => const LoginPage(),
      // ),

      // ----------------------------------------------------------------------
      // Main application
      // ----------------------------------------------------------------------
      /*StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Dashboard
          StatefulShellBranch(
            navigatorKey: dashboardNavigatorKey,
            routes: [
              GoRoute(
                path: RouteNames.dashboard,
                name: RouteNames.dashboard,
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),

          // Search
          StatefulShellBranch(
            navigatorKey: searchNavigatorKey,
            routes: [
              GoRoute(
                path: RouteNames.search,
                name: RouteNames.search,
                builder: (context, state) => const SearchPage(),
              ),
            ],
          ),

          // Account
          StatefulShellBranch(
            navigatorKey: accountNavigatorKey,
            routes: [
              GoRoute(
                path: RouteNames.account,
                name: RouteNames.account,
                builder: (context, state) => const AccountPage(),
              ),
            ],
          ),
        ],
      ),*/
    ],
  );
}
