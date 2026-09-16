import 'package:go_router/go_router.dart';
import 'package:starter/features/dashboard/dashboard/screen/dashboard_screen.dart';

import 'dashboard_route_names.dart';

/// GoRoutes owned by the dashboard feature. Aggregated by the app router —
/// the auth guard itself stays in `lib/app/router/app_router.dart`.
List<GoRoute> buildDashboardRoutes() => [
  GoRoute(
    path: DashboardRouteNames.dashboard,
    name: DashboardRouteNames.dashboard,
    builder: (context, state) => const DashboardScreen(),
  ),
];
