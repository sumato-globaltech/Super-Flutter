abstract final class MarketRouteNames {
  static const market = '/market';

  static String priceHistory(String marketId) => '/market/$marketId';
  static const priceHistoryTemplate = '/market/:marketId';
}
