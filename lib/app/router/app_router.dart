import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/routes/auth_route_names.dart';
import '../../features/auth/routes/auth_routes.dart';
import '../config/app_config.dart';
import '../startup/splash_screen.dart';
import 'router_refresh.dart';
import 'routes_names.dart';

GoRouter createRouter({
  required AuthCubit authCubit,
  required AppConfig config,
}) {
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: !config.isProduction,
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    redirect: (context, state) {
      final authStatus = authCubit.state.status;
      final location = state.matchedLocation;

      final isSplash = location == RouteNames.splash;
      final isLogin = location == AuthRouteNames.login;

      // Authentication status is still being determined.
      if (authStatus == AuthStatus.unknown) {
        return isSplash ? null : RouteNames.splash;
      }

      // User is not authenticated.
      if (authStatus == AuthStatus.unauthenticated) {
        return isLogin ? null : AuthRouteNames.login;
      }

      // User is authenticated.
      if (authStatus == AuthStatus.authenticated) {
        if (isSplash || isLogin) {
          return AuthRouteNames.dashboard;
        }
      }

      return null;
    },

    routes: [
      GoRoute(
        path: RouteNames.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      ...buildAuthRoutes(),
    ],
  );
}
