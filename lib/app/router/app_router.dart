import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:super_flutter/features/auth/routes/auth_route_names.dart';
import 'package:super_flutter/features/auth/session/bloc/auth_cubit.dart';
import 'package:super_flutter/features/auth/session/bloc/auth_state.dart';
import 'package:super_flutter/domain/auth/entities/access_policy.dart';
import 'package:super_flutter/features/dashboard/routes/dashboard_route_names.dart';
// sf:feature-routes-imports:begin
import 'package:super_flutter/features/auth/routes/auth_routes.dart';
import 'package:super_flutter/features/super_awesome/routes/super_awesome_routes.dart';
import 'package:super_flutter/features/ui_gallery/routes/ui_gallery_routes.dart';

// sf:feature-routes-imports:end
import '../access/app_features.dart';
import '../access/feature_registry.dart';
import '../config/app_config.dart';
import '../shell/app_shell_route.dart';
import '../startup/app_startup.dart';
import '../startup/force_update_screen.dart';
import '../startup/splash_screen.dart';
import 'navigator_keys.dart';
import 'routes_names.dart';

GoRouter createRouter({
  required AuthCubit authCubit,
  required AppStartup startup,
  required AppConfig config,
  required Listenable refreshListenable,
}) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: !config.isProduction,
    refreshListenable: refreshListenable,
    redirect: (context, state) => resolveRedirect(
      location: state.matchedLocation,
      status: authCubit.state.status,
      updateRequired: startup.updateRequired,
      access: authCubit.state.access,
      passwordChangeRequired: authCubit.state.mustChangePassword,
    ),
    routes: [
      GoRoute(
        path: RouteNames.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.forceUpdate,
        name: RouteNames.forceUpdate,
        builder: (context, state) =>
            ForceUpdateScreen(storeLink: startup.settings.storeLink),
      ),
      buildAppShellRoute(),
      // sf:feature-routes:begin
      ...buildAuthRoutes(),
      ...buildSuperAwesomeRoutes(),
      ...buildUiGalleryRoutes(),
      // sf:feature-routes:end
    ],
  );
}

@visibleForTesting
String? resolveRedirect({
  required String location,
  required AuthStatus status,
  required bool updateRequired,
  AccessPolicy? access,
  FeatureRegistry? registry,
  bool passwordChangeRequired = false,
}) {
  if (updateRequired) {
    return location == RouteNames.forceUpdate ? null : RouteNames.forceUpdate;
  }
  final isEntryRoute =
      location == RouteNames.splash || location == RouteNames.forceUpdate;
  final isAuthRoute = location == AuthRouteNames.login;
  switch (status) {
    case AuthStatus.unknown:
      return location == RouteNames.splash ? null : RouteNames.splash;
    case AuthStatus.unauthenticated:
      return isAuthRoute ? null : AuthRouteNames.login;
    case AuthStatus.authenticated:
      // The server refuses everything else until the password is changed.
      const changePassword = AuthRouteNames.changePassword;
      if (passwordChangeRequired) {
        return location == changePassword ? null : changePassword;
      }
      if (location == changePassword) return null;
      const home = DashboardRouteNames.dashboard;
      if (isEntryRoute || isAuthRoute) return home;
      if (location == home) return null;
      final allowed = (registry ?? appFeatures).canOpen(
        location,
        access ?? AccessPolicy.signedInWithoutDetails,
      );
      return allowed ? null : home;
  }
}
