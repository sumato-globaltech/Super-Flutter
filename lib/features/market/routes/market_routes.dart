import 'package:go_router/go_router.dart';
import 'package:super_flutter/data/market/model/market_model.dart';
import 'package:super_flutter/features/market/presentation/market/screen/market_screen.dart';
import 'package:super_flutter/features/market/presentation/market_prices/screen/market_prices_screen.dart';

import 'market_route_names.dart';

List<GoRoute> buildMarketRoutes() => [
  GoRoute(
    path: MarketRouteNames.market,
    name: MarketRouteNames.market,
    builder: (context, state) => const MarketScreen(),
    routes: [
      GoRoute(
        path: ':marketId',
        builder: (context, state) => MarketPricesScreen(
          marketId: state.pathParameters['marketId']!,
          market: state.extra as MarketModel?,
        ),
      ),
    ],
  ),
];
