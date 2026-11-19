class RemoteAppSettings {
  const RemoteAppSettings({
    this.apiBaseUrl,
    this.minBuildNumber = 0,
    this.storeLink,
    this.loginBannerImage,
    this.bannerImages = const [],
  });

  factory RemoteAppSettings.fromConfig(
    Map<String, dynamic>? config, {
    required String packageName,
    required String platform,
  }) {
    final app = config?[packageName];
    if (app is! Map) return const RemoteAppSettings();

    final builds = app['build_number'];
    final storeLinks = app['store_links'];
    final info = app['info'];
    final banners = info is Map ? info['banner_images'] : null;

    return RemoteAppSettings(
      apiBaseUrl: _nonEmpty(app['api']),
      minBuildNumber: builds is Map
          ? int.tryParse('${builds[platform]}') ?? 0
          : 0,
      storeLink: storeLinks is Map ? _nonEmpty(storeLinks[platform]) : null,
      loginBannerImage: info is Map
          ? _nonEmpty(info['login_banner_image'])
          : null,
      bannerImages: banners is List
          ? banners.map(_nonEmpty).whereType<String>().toList(growable: false)
          : const [],
    );
  }

  final String? apiBaseUrl;

  final int minBuildNumber;

  final String? storeLink;

  final String? loginBannerImage;

  final List<String> bannerImages;

  static String? _nonEmpty(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
