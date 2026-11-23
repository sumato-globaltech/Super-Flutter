import 'package:go_router/go_router.dart';
import 'package:super_flutter/features/dashboard/routes/dashboard_route_names.dart';
import 'package:super_flutter/features/dashboard/routes/dashboard_routes.dart';
import 'package:super_flutter/features/farm/routes/farms_route_names.dart';
import 'package:super_flutter/features/farm/routes/farms_routes.dart';
import 'package:super_flutter/features/market/routes/market_route_names.dart';
import 'package:super_flutter/features/market/routes/market_routes.dart';

/// Routes of the features that are bottom bar tabs, by tab path. A tab
/// without an entry shows TabPlaceholderScreen until its feature is built.
Map<String, List<RouteBase>> appTabRoutes() => {
  DashboardRouteNames.dashboard: buildDashboardRoutes(),
  MarketRouteNames.market: buildMarketRoutes(),
  FarmsRouteNames.farms: buildFarmsRoutes(),
};
