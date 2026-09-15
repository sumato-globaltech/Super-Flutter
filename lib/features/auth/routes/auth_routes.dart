import 'package:go_router/go_router.dart';
import 'package:starter/features/auth/presentation/screens/dashboard_screen.dart';
import 'package:starter/features/auth/presentation/screens/login_screen.dart';

import 'auth_route_names.dart';

/// GoRoutes owned by the auth feature. Aggregated by the app router —
/// the auth guard itself stays in `lib/app/router/app_router.dart`.
List<GoRoute> buildAuthRoutes() => [
  GoRoute(
    path: AuthRouteNames.login,
    name: AuthRouteNames.login,
    builder: (context, state) => const LoginScreen(),
  ),
  GoRoute(
    path: AuthRouteNames.dashboard,
    name: AuthRouteNames.dashboard,
    builder: (context, state) => const DashboardScreen(),
  ),
];
