abstract class FarmRouteNames {
  static const String farms = '/farms';
  static const String farmDetail = '/farms/:farmId';

  static String farmDetailFor(String farmId) => '/farms/$farmId';

  static const addFarm = '/farm/add_farm';

  static const editFarm = '/farm/edit_farm/:farm';

  static String editFarmFor(String farm) => '/farm/edit_farm/$farm';
}
