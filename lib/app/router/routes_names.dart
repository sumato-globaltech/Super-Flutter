import 'package:super_flutter/features/auth/routes/auth_route_names.dart';
import 'package:super_flutter/features/dashboard/routes/dashboard_route_names.dart';

/// App-shell routes plus compat re-exports for feature-owned paths.
///
/// Feature screens own their paths (see [AuthRouteNames],
/// [DashboardRouteNames]); this class keeps app-owned paths (splash) and
/// re-exports feature paths so existing `RouteNames.login` /
/// `RouteNames.dashboard` references keep working.
/// New code should import the feature-specific names directly.
abstract final class RouteNames {
  static const splash = '/splash';

  static const login = AuthRouteNames.login;

  static const dashboard = DashboardRouteNames.dashboard;
}
