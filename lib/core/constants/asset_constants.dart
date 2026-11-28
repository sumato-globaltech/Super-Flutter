/// Central asset paths. Add the matching files under assets/ before
/// referencing a constant in UI — missing files currently fall back to
/// placeholders at runtime. Prefer these constants over string literals.
abstract final class AssetConstants {
  static const _images = 'assets/images';
  static const _icons = 'assets/icons';
  static const _animations = 'assets/animations';

  static const logo = '$_images/logo.png';
  static const placeholder = '$_images/placeholder.png';
  static const emptyBox = '$_images/empty_box.png';

  static const appIcon = '$_icons/app_icon.png';
  static const googleIcon = '$_icons/google.png';
  static const appleIcon = '$_icons/apple.png';

  static const loadingAnimation = '$_animations/loading.json';
  static const errorAnimation = '$_animations/error.json';

  static const _geoMap = 'assets/geo_map';
  static const geoMapStyle = '$_geoMap/style.json';
  static const geoMapCatalog = '$_geoMap/catalog.v1.json';
  static const geoMapDistricts = '$_geoMap/files/districts.geojson';
  static const geoMapMarkerIcon = '$_geoMap/icons/map_marker.png';
  static const geoMapOfficeIcon = '$_geoMap/icons/office.png';
  static const geoMapWeatherIcon = '$_geoMap/icons/weather_station.png';
  static const geoMapAdminIcon = '$_geoMap/icons/admin_hq.png';
  static const geoMapPeakIcon = '$_geoMap/icons/mountain_peak_new.png';
}
