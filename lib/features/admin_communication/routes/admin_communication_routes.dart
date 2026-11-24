import 'package:go_router/go_router.dart';
import 'package:super_flutter/data/admin_communication/model/admin_alert_model.dart';
import 'package:super_flutter/data/admin_communication/model/admin_notice_model.dart';
import 'package:super_flutter/features/admin_communication/presentation/add_alert/screen/add_alert_screen.dart';
import 'package:super_flutter/features/admin_communication/presentation/add_notice/screen/add_notice_screen.dart';
import 'package:super_flutter/features/admin_communication/presentation/admin_alerts/screen/admin_alerts_screen.dart';
import 'package:super_flutter/features/admin_communication/presentation/admin_notices/screen/admin_notices_screen.dart';
import 'package:super_flutter/features/admin_communication/presentation/edit_alert/screen/edit_alert_screen.dart';
import 'package:super_flutter/features/admin_communication/presentation/edit_notice/screen/edit_notice_screen.dart';

import 'admin_communication_route_names.dart';

/// GoRoutes owned by the admin_communication feature.
List<GoRoute> buildAdminCommunicationRoutes() => [
  GoRoute(
    path: AdminCommunicationRouteNames.root,
    name: AdminCommunicationRouteNames.root,
    builder: (context, state) => const AdminNoticesScreen(),
  ),
  GoRoute(
    path: AdminCommunicationRouteNames.adminAlerts,
    name: AdminCommunicationRouteNames.adminAlerts,
    builder: (context, state) => const AdminAlertsScreen(),
  ),
  GoRoute(
    path: AdminCommunicationRouteNames.addNotice,
    name: AdminCommunicationRouteNames.addNotice,
    builder: (context, state) => const AddNoticeScreen(),
  ),
  GoRoute(
    path: AdminCommunicationRouteNames.editNotice,
    name: AdminCommunicationRouteNames.editNotice,
    // There is no API for one notice: the list passes it along.
    redirect: (context, state) => state.extra is AdminNoticeModel
        ? null
        : AdminCommunicationRouteNames.root,
    builder: (context, state) =>
        EditNoticeScreen(notice: state.extra! as AdminNoticeModel),
  ),
  GoRoute(
    path: AdminCommunicationRouteNames.addAlert,
    name: AdminCommunicationRouteNames.addAlert,
    builder: (context, state) => const AddAlertScreen(),
  ),
  GoRoute(
    path: AdminCommunicationRouteNames.editAlert,
    name: AdminCommunicationRouteNames.editAlert,
    // There is no API for one alert: the list passes it along.
    redirect: (context, state) => state.extra is AdminAlertModel
        ? null
        : AdminCommunicationRouteNames.adminAlerts,
    builder: (context, state) =>
        EditAlertScreen(alert: state.extra! as AdminAlertModel),
  ),
];
