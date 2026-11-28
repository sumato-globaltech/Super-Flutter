abstract final class GeoMapEndpoints {
  static const _host = 'http://64.227.134.64';

  static const officeLocations =
      'https://agri-erp.sumato.tech/api/office-locations';

  /// Overridable with `--dart-define=OFFICE_API_KEY=...`.
  static const officeApiKey = String.fromEnvironment(
    'OFFICE_API_KEY',
    defaultValue: 'd9acceac485c1602e7eb4ec5aac6d5f',
  );

  static const weatherForecast =
      'https://api.openweathermap.org/data/2.5/forecast';

  /// Overridable with `--dart-define=WEATHER_API_KEY=...`.
  static const weatherApiKey = String.fromEnvironment(
    'WEATHER_API_KEY',
    defaultValue: '96cf5f5924a95eaafadd8ea77a766161',
  );

  static const suitabilityPoint = '$_host/api/point.php';

  static const villagesAsset = 'assets/geo_map/files/nagaland_vill.geojson';

  static const villagesGeoJson = '$_host/nagaland_vill.geojson';

  static const weatherStationsGeoJson = '$_host/weathr_statn.geojson';

  static String district(String key) => '$_host/districts/$key.geojson';

  static String pmTiles(String file) =>
      'pmtiles://$_host/pmtiles.php?file=$file';

  static String cropTiles(String path) => '$_host/tiles/$path/{z}/{x}/{y}.png';
}
