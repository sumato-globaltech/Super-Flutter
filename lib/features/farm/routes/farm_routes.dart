import 'package:go_router/go_router.dart';
import 'package:super_flutter/data/farm/model/farm_model.dart';
import 'package:super_flutter/features/farm/presentation/farm_detail/screen/farm_detail_screen.dart';
import 'package:super_flutter/features/farm/presentation/farm_form/screen/farm_form_screen.dart';
import 'package:super_flutter/features/farm/presentation/farms_list/screen/farms_list_screen.dart';

import 'farms_route_names.dart';

List<GoRoute> buildFarmsRoutes() => [
      GoRoute(
        path: FarmsRouteNames.farms,
        name: FarmsRouteNames.farms,
        builder: (context, state) => const FarmsListScreen(),
        routes: [
          GoRoute(
            path: 'new',
            name: FarmsRouteNames.newFarm,
            builder: (context, state) => const FarmFormScreen(),
          ),
          GoRoute(
            path: ':farmId',
            name: FarmsRouteNames.farmDetail,
            builder: (context, state) => FarmDetailScreen(
              farmId: state.pathParameters['farmId']!,
            ),
            routes: [
              GoRoute(
                path: 'edit',
                name: FarmsRouteNames.editFarm,
                builder: (context, state) => FarmFormScreen(
                  initialFarm: state.extra is FarmModel
                      ? state.extra as FarmModel
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    ];
