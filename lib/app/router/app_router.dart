import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
// sf:feature-routes-imports:begin
import 'package:super_flutter/features/auth/routes/auth_routes.dart';
import 'package:super_flutter/features/dashboard/routes/dashboard_routes.dart';
import 'package:super_flutter/features/super_awesome/routes/super_awesome_routes.dart';

// sf:feature-routes-imports:end
import '../config/app_config.dart';
import '../startup/splash_screen.dart';
import 'routes.dart';
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
    // refreshListenable: GoRouterRefreshStream(authCubit.stream),
    // redirect: (context, state) {
    //   final authStatus = authCubit.state.status;
    //   final location = state.matchedLocation;

    //   final isSplash = location == RouteNames.splash;
    //   final isLogin = location == AuthRouteNames.login;

    //   // Authentication status is still being determined.
    //   if (authStatus == AuthStatus.unknown) {
    //     return isSplash ? null : RouteNames.splash;
    //   }

    //   // User is not authenticated.
    //   if (authStatus == AuthStatus.unauthenticated) {
    //     return isLogin ? null : AuthRouteNames.login;
    //   }

    //   // User is authenticated.
    //   if (authStatus == AuthStatus.authenticated) {
    //     if (isSplash || isLogin) {
    //       return DashboardRouteNames.dashboard;
    //     }
    //   }
    //   return null;
    // },
    redirect: (context, state) {
      final authService = AuthService.instance;
      final location = state.matchedLocation;
      if (location == Routes.main) {
        // if (authService.authStatus == AuthStatus.authenticated) {
        //   if (authService.userRole == UserRole.engineer) {
        //     return Routes.homeEngineer;
        //   }
        //   if (authService.userRole == UserRole.contractor) {
        //     return Routes.homeContractor;
        //   }
        //   return Routes.homeEngineer;
        // } else if (authService.authStatus == AuthStatus.update) {
        //   return Routes.newUpdate;
        // }
        return Routes.login;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      // sf:feature-routes:begin
      ...buildAuthRoutes(),
      ...buildDashboardRoutes(),
      ...buildSuperAwesomeRoutes(),
      // sf:feature-routes:end
    ],
  );
}
