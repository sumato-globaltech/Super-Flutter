import 'package:go_router/go_router.dart';
import 'package:super_flutter/features/support/presentation/create_ticket/screen/create_ticket_screen.dart';
import 'package:super_flutter/features/support/presentation/support/screen/support_screen.dart';
import 'package:super_flutter/features/support/presentation/ticket_detail/screen/ticket_detail_screen.dart';

import 'support_route_names.dart';

/// GoRoutes owned by the support feature.
List<GoRoute> buildSupportRoutes() => [
  GoRoute(
    path: SupportRouteNames.root,
    name: SupportRouteNames.root,
    builder: (context, state) => const SupportScreen(),
  ),
  GoRoute(
    path: SupportRouteNames.ticketDetail,
    name: SupportRouteNames.ticketDetail,
    builder: (context, state) =>
        TicketDetailScreen(ticket: state.pathParameters['ticket']!),
  ),
  GoRoute(
    path: SupportRouteNames.createTicket,
    name: SupportRouteNames.createTicket,
    builder: (context, state) => const CreateTicketScreen(),
  ),
];
