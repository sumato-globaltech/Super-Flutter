class CropEndpoints {
  static const String crops = '/api/v1/crops';
  static const String recommendations = '/api/v1/crops/recommendations';
  static const String sowingMonths = '/api/v1/crops/sowing-months';
  static String crop(String slug) => '/api/v1/crops/$slug';
  static String advisory(String slug) => '/api/v1/crops/$slug/advisory';
  static String calendar(String slug) => '/api/v1/crops/$slug/calendar';
  static String fertilizers(String slug) => '/api/v1/crops/$slug/fertilizers';
  static String economics(String slug) => '/api/v1/crops/$slug/economics';
  static String prices(String slug) => '/api/v1/crops/$slug/prices';
}
