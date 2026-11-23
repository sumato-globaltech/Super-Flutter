import 'package:go_router/go_router.dart';
import 'package:super_flutter/features/farm/presentation/add_farm/screen/add_farm_screen.dart';
import 'package:super_flutter/features/farm/presentation/edit_farm/screen/edit_farm_screen.dart';
import 'package:super_flutter/features/farm/presentation/farm_detail/screen/farm_detail_screen.dart';
import 'package:super_flutter/features/farm/presentation/farms_list/screen/farms_list_screen.dart';

import 'farm_route_names.dart';

List<GoRoute> buildFarmRoutes() => [
  GoRoute(
    path: FarmRouteNames.farms,
    name: FarmRouteNames.farms,
    builder: (context, state) => const FarmsListScreen(),
    routes: [
      GoRoute(
        path: ':farmId',
        name: FarmRouteNames.farmDetail,
        builder: (context, state) =>
            FarmDetailScreen(farmId: state.pathParameters['farmId']!),
      ),
    ],
  ),
  GoRoute(
    path: FarmRouteNames.addFarm,
    name: FarmRouteNames.addFarm,
    builder: (context, state) => const AddFarmScreen(),
  ),
  GoRoute(
    path: FarmRouteNames.editFarm,
    name: FarmRouteNames.editFarm,
    builder: (context, state) =>
        EditFarmScreen(farm: state.pathParameters['farm']!),
  ),
];
