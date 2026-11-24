import 'package:go_router/go_router.dart';
import 'package:super_flutter/features/shipments/presentation/request_shipment/screen/request_shipment_screen.dart';
import 'package:super_flutter/features/shipments/presentation/shipment_detail/screen/shipment_detail_screen.dart';
import 'package:super_flutter/features/shipments/presentation/shipments/screen/shipments_screen.dart';

import 'shipments_route_names.dart';

/// GoRoutes owned by the shipments feature.
List<GoRoute> buildShipmentsRoutes() => [
  GoRoute(
    path: ShipmentsRouteNames.root,
    name: ShipmentsRouteNames.root,
    builder: (context, state) => const ShipmentsScreen(),
  ),
  GoRoute(
    path: ShipmentsRouteNames.shipmentDetail,
    name: ShipmentsRouteNames.shipmentDetail,
    builder: (context, state) =>
        ShipmentDetailScreen(shipment: state.pathParameters['shipment']!),
  ),
  GoRoute(
    path: ShipmentsRouteNames.requestShipment,
    name: ShipmentsRouteNames.requestShipment,
    builder: (context, state) => const RequestShipmentScreen(),
  ),
];
