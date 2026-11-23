abstract class CropsRouteNames {
  static const String crops = '/crops';
  static const String recommendations = '/crops/recommendations';
  static const String cropDetail = '/crops/:cropSlug';

  static String cropDetailFor(String cropSlug) => '/crops/$cropSlug';
}
