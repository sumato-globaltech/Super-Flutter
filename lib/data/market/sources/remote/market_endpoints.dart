abstract final class MarketEndpoints {
  static const markets = '/api/v1/markets';
  static const summary = '/api/v1/markets/summary';
  static const favourites = '/api/v1/markets/favourites';

  static String prices(String marketId) => '/api/v1/markets/$marketId/prices';
  static String favourite(String marketId) => '/api/v1/markets/$marketId/favourite';
}
