import 'package:go_router/go_router.dart';
import 'package:super_flutter/features/meetings/presentation/meetings/screen/meetings_screen.dart';

import 'meetings_route_names.dart';

/// GoRoutes owned by the meetings feature.
List<GoRoute> buildMeetingsRoutes() => [
  GoRoute(
    path: MeetingsRouteNames.root,
    name: MeetingsRouteNames.root,
    builder: (context, state) => const MeetingsScreen(),
  ),
];
