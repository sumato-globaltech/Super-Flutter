import 'package:go_router/go_router.dart';
import 'package:super_flutter/features/iot/presentation/device_detail/screen/device_detail_screen.dart';

import 'iot_route_names.dart';

List<GoRoute> buildIotRoutes() => [
      GoRoute(
        path: IotRouteNames.deviceDetailPath,
        name: IotRouteNames.deviceDetailPath,
        builder: (context, state) => DeviceDetailScreen(
          deviceId: state.pathParameters['deviceId'] ?? '',
        ),
      ),
    ];
