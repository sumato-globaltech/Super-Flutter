abstract class FarmsRouteNames {
  static const String farms = '/farms';
  static const String newFarm = '/farms/new';
  static const String farmDetail = '/farms/:farmId';
  static const String editFarm = '/farms/:farmId/edit';

  static String farmDetailFor(String farmId) => '/farms/$farmId';
  static String editFarmFor(String farmId) => '/farms/$farmId/edit';
}
