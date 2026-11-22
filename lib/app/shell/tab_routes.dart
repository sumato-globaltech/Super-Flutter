import 'package:go_router/go_router.dart';
import 'package:super_flutter/features/dashboard/routes/dashboard_route_names.dart';
import 'package:super_flutter/features/dashboard/routes/dashboard_routes.dart';

/// Routes of the features that are bottom bar tabs, by tab path. A tab
/// without an entry shows TabPlaceholderScreen until its feature is built.
Map<String, List<RouteBase>> appTabRoutes() => {
  DashboardRouteNames.dashboard: buildDashboardRoutes(),
};
