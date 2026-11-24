import 'package:go_router/go_router.dart';
import 'package:super_flutter/features/national_farming_ai_assistant/presentation/national_farming_ai_assistant/screen/national_farming_ai_assistant_screen.dart';

import 'national_farming_ai_assistant_route_names.dart';

/// GoRoutes owned by the National Farming AI Assistant feature.
List<GoRoute> buildNationalFarmingAiAssistantRoutes() => [
  GoRoute(
    path: NationalFarmingAiAssistantRouteNames.root,
    name: NationalFarmingAiAssistantRouteNames.root,
    builder: (context, state) => const NationalFarmingAiAssistantScreen(),
  ),
];
