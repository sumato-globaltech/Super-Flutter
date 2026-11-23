import 'package:go_router/go_router.dart';
import 'package:super_flutter/features/crops/presentation/crop_detail/screen/crop_detail_screen.dart';
import 'package:super_flutter/features/crops/presentation/crop_recommendations/screen/crop_recommendations_screen.dart';
import 'package:super_flutter/features/crops/presentation/crops_list/screen/crops_list_screen.dart';

import 'crops_route_names.dart';

List<GoRoute> buildCropsRoutes() => [
      GoRoute(
        path: CropsRouteNames.crops,
        name: CropsRouteNames.crops,
        builder: (context, state) => const CropsListScreen(),
        routes: [
          GoRoute(
            path: 'recommendations',
            name: CropsRouteNames.recommendations,
            builder: (context, state) => const CropRecommendationsScreen(),
          ),
          GoRoute(
            path: ':cropSlug',
            name: CropsRouteNames.cropDetail,
            builder: (context, state) => CropDetailScreen(
              cropSlug: state.pathParameters['cropSlug']!,
            ),
          ),
        ],
      ),
    ];
