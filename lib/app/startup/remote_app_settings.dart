class RemoteAppSettings {
  const RemoteAppSettings({this.apiBaseUrl, this.minBuildNumber = 0});

  factory RemoteAppSettings.fromConfig(
    Map<String, dynamic>? config, {
    required String packageName,
    required String platform,
  }) {
    final app = config?[packageName];
    if (app is! Map) return const RemoteAppSettings();

    final api = app['api'];
    final builds = app['build_number'];

    return RemoteAppSettings(
      apiBaseUrl: api is String && api.trim().isNotEmpty ? api.trim() : null,
      minBuildNumber: builds is Map
          ? int.tryParse('${builds[platform]}') ?? 0
          : 0,
    );
  }

  final String? apiBaseUrl;

  final int minBuildNumber;
}
