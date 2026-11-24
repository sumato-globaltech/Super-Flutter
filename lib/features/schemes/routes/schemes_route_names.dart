/// Route paths owned by the schemes feature.
abstract final class SchemesRouteNames {
  static const root = '/schemes';

  static const schemeDetail = '/schemes/scheme_detail/:scheme';

  static String schemeDetailFor(String scheme) =>
      '/schemes/scheme_detail/$scheme';

  static const myApplications = '/schemes/my_applications';
}
