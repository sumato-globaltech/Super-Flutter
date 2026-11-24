import 'package:go_router/go_router.dart';
import 'package:super_flutter/features/help_desk/presentation/queue_summary/screen/queue_summary_screen.dart';

import 'help_desk_route_names.dart';

/// GoRoutes owned by the help_desk feature.
List<GoRoute> buildHelpDeskRoutes() => [
  GoRoute(
    path: HelpDeskRouteNames.root,
    name: HelpDeskRouteNames.root,
    builder: (context, state) => const QueueSummaryScreen(),
  ),
];
