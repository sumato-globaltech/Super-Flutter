import 'package:go_router/go_router.dart';
import 'package:super_flutter/features/facilities/presentation/facilities/screen/facilities_screen.dart';
import 'package:super_flutter/features/facilities/presentation/facility_stats/screen/facility_stats_screen.dart';

import 'facilities_route_names.dart';

/// GoRoutes owned by the facilities feature.
List<GoRoute> buildFacilitiesRoutes() => [
  GoRoute(
    path: FacilitiesRouteNames.root,
    name: FacilitiesRouteNames.root,
    builder: (context, state) => const FacilitiesScreen(),
  ),
  GoRoute(
    path: FacilitiesRouteNames.facilityStats,
    name: FacilitiesRouteNames.facilityStats,
    builder: (context, state) => const FacilityStatsScreen(),
  ),
];
