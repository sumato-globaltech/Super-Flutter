import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:super_flutter/app/router/auth_service.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/utils/enums.dart';
// sf:feature-routes-imports:begin
import 'package:super_flutter/features/auth/routes/auth_routes.dart';
import 'package:super_flutter/features/dashboard/routes/dashboard_routes.dart';
import 'package:super_flutter/features/super_awesome/routes/super_awesome_routes.dart';

// sf:feature-routes-imports:end
import '../config/app_config.dart';
import '../startup/splash_screen.dart';
import 'routes.dart';
import 'routes_names.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final AppConfig _config = getIt.get<AppConfig>();

final GoRouter goRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: RouteNames.splash,
  debugLogDiagnostics: !_config.isProduction,
  // refreshListenable: GoRouterRefreshStream(authCubit.stream),
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
