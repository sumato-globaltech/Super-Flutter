import 'package:go_router/go_router.dart';
import 'package:super_flutter/features/communication/presentation/notice_detail/screen/notice_detail_screen.dart';
import 'package:super_flutter/features/communication/presentation/notices/screen/notices_screen.dart';
import 'package:super_flutter/features/communication/presentation/alerts/screen/alerts_screen.dart';

import 'communication_route_names.dart';

/// GoRoutes owned by the communication feature. Aggregated by the app router —
/// the auth guard itself stays in `lib/app/router/app_router.dart`.
List<GoRoute> buildCommunicationRoutes() => [
  GoRoute(
    path: CommunicationRouteNames.notices,
    name: CommunicationRouteNames.notices,
    builder: (context, state) => const NoticesScreen(),
    routes: [
      GoRoute(
        path: ':noticeId',
        builder: (context, state) => NoticeDetailScreen(
          noticeId: state.pathParameters['noticeId']!,
        ),
      ),
    ],
  ),
  GoRoute(
    path: CommunicationRouteNames.alerts,
    name: CommunicationRouteNames.alerts,
    builder: (context, state) => const AlertsScreen(),
  ),
];
