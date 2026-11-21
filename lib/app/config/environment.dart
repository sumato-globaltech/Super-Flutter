import 'flavor.dart';

class Environment {
  const Environment({
    required this.flavor,
    required this.appName,
    required this.apiBaseUrl,
    required this.databaseName,
    this.apiKey = const String.fromEnvironment('API_KEY'),
    this.connectTimeout = const Duration(seconds: 15),
    this.receiveTimeout = const Duration(seconds: 20),
    this.sendTimeout = const Duration(seconds: 20),
    this.enableHttpLogging = false,
    this.enableVerboseLogging = false,
    this.showFlavorBanner = false,
    this.useFakeAuth = false,
  });

  factory Environment.development() => const Environment(
    flavor: Flavor.development,
    appName: 'Flutter Kit Dev',
    apiBaseUrl: 'http://dam.test',
    databaseName: 'flutter_kit_dev',
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 30),
    sendTimeout: Duration(seconds: 30),
    enableHttpLogging: true,
    enableVerboseLogging: true,
    showFlavorBanner: true,
    useFakeAuth: bool.fromEnvironment('FAKE_AUTH'),
  );

  factory Environment.staging() => const Environment(
    flavor: Flavor.staging,
    appName: 'Flutter Kit Staging',
    apiBaseUrl: 'https://agri-erp.sumato.tech',
    databaseName: 'flutter_kit_staging',
    enableHttpLogging: true,
    showFlavorBanner: true,
    useFakeAuth: bool.fromEnvironment('FAKE_AUTH'),
  );

  factory Environment.production() => const Environment(
    flavor: Flavor.production,
    appName: 'Flutter Kit',
    apiBaseUrl: 'https://agri-erp.sumato.tech',
    databaseName: 'flutter_kit',
  );

  final Flavor flavor;
  final String appName;
  final String apiBaseUrl;
  final String apiKey;

  final String databaseName;

  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;

  final bool enableHttpLogging;

  final bool enableVerboseLogging;

  final bool showFlavorBanner;

  final bool useFakeAuth;

  @override
  String toString() => 'Environment(${flavor.name}, $apiBaseUrl)';
}
