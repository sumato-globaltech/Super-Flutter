import 'environment.dart';
import 'flavor.dart';

class AppConfig {
  const AppConfig({
    required this.environment,
    this.defaultPageSize = 30,
    this.productCacheTtl = const Duration(minutes: 10),
    this.searchDebounce = const Duration(milliseconds: 400),
  });

  factory AppConfig.development() =>
      AppConfig(environment: Environment.development());

  factory AppConfig.staging() => AppConfig(environment: Environment.staging());

  factory AppConfig.production() =>
      AppConfig(environment: Environment.production());

  final Environment environment;

  final int defaultPageSize;

  final Duration productCacheTtl;

  final Duration searchDebounce;

  Flavor get flavor => environment.flavor;

  String get appName => environment.appName;

  String get apiBaseUrl => environment.apiBaseUrl;

  bool get isProduction => environment.flavor.isProduction;

  bool get useFakeAuth => environment.useFakeAuth && !isProduction;

  @override
  String toString() => 'AppConfig($environment)';
}
