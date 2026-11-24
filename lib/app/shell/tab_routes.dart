import 'package:go_router/go_router.dart';
import 'package:super_flutter/features/dashboard/routes/dashboard_route_names.dart';
import 'package:super_flutter/features/dashboard/routes/dashboard_routes.dart';
import 'package:super_flutter/features/farm/routes/farm_route_names.dart';
import 'package:super_flutter/features/farm/routes/farm_routes.dart';
import 'package:super_flutter/features/help_desk/routes/help_desk_route_names.dart';
import 'package:super_flutter/features/help_desk/routes/help_desk_routes.dart';
import 'package:super_flutter/features/market/routes/market_route_names.dart';
import 'package:super_flutter/features/market/routes/market_routes.dart';
import 'package:super_flutter/features/schemes/routes/schemes_route_names.dart';
import 'package:super_flutter/features/schemes/routes/schemes_routes.dart';
import 'package:super_flutter/features/shipments/routes/shipments_route_names.dart';
import 'package:super_flutter/features/shipments/routes/shipments_routes.dart';

/// Routes of the features that are bottom bar tabs, by tab path. A tab
/// without an entry shows TabPlaceholderScreen until its feature is built.
Map<String, List<RouteBase>> appTabRoutes() => {
  DashboardRouteNames.dashboard: buildDashboardRoutes(),
  MarketRouteNames.market: buildMarketRoutes(),
  FarmRouteNames.farms: buildFarmRoutes(),
  ShipmentsRouteNames.root: buildShipmentsRoutes(),
  SchemesRouteNames.root: buildSchemesRoutes(),
  HelpDeskRouteNames.root: buildHelpDeskRoutes(),
};
