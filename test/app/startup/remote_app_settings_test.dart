import 'package:flutter_test/flutter_test.dart';
import 'package:super_flutter/app/startup/remote_app_settings.dart';

void main() {
  const package = 'tech.sumato.solaragent';
  final config = <String, dynamic>{
    package: {
      'api': 'https://skyrossolar.com',
      'build_number': {'IOS': 1, 'Android': 1},
      'store_links': {
        'Android': '',
        'IOS': 'https://apps.apple.com/us/app/asrlm-hrms/id6764757959',
      },
      'info': {
        'login_banner_image': 'https://ik.imagekit.io/a.png',
        'banner_images': ['https://ik.imagekit.io/a.png', '', 'https://b.png'],
      },
    },
  };

  RemoteAppSettings parseFrom(Map<String, dynamic>? json, String platform) =>
      RemoteAppSettings.fromConfig(
        json,
        packageName: package,
        platform: platform,
      );

  RemoteAppSettings parse(String platform, [Map<String, dynamic>? json]) =>
      parseFrom(json ?? config, platform);

  test('reads every field for the current platform', () {
    final ios = parse('IOS');
    expect(ios.apiBaseUrl, 'https://skyrossolar.com');
    expect(ios.minBuildNumber, 1);
    expect(ios.storeLink, contains('apps.apple.com'));
    expect(ios.loginBannerImage, 'https://ik.imagekit.io/a.png');
    expect(ios.bannerImages, ['https://ik.imagekit.io/a.png', 'https://b.png']);
  });

  test('empty store link becomes null', () {
    expect(parse('Android').storeLink, isNull);
  });

  test('missing or malformed config falls back to defaults', () {
    for (final json in <Map<String, dynamic>?>[
      null,
      {},
      {package: 'oops'},
      {
        package: {'build_number': 'x', 'store_links': 1, 'info': []},
      },
    ]) {
      final s = parseFrom(json, 'IOS');
      expect(s.apiBaseUrl, isNull);
      expect(s.minBuildNumber, 0);
      expect(s.storeLink, isNull);
      expect(s.bannerImages, isEmpty);
    }
  });
}
