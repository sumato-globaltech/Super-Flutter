import 'package:go_router/go_router.dart';
import 'package:super_flutter/features/farming_assistant/presentation/farming_assistant/screen/farming_assistant_screen.dart';

import 'farming_assistant_route_names.dart';

/// GoRoutes owned by the farming_assistant feature.
List<GoRoute> buildFarmingAssistantRoutes() => [
  GoRoute(
    path: FarmingAssistantRouteNames.root,
    name: FarmingAssistantRouteNames.root,
    builder: (context, state) => const FarmingAssistantScreen(),
  ),
];
