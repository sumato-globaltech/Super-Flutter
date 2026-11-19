import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class DeviceInfoService {
  DeviceInfoService() : _plugin = DeviceInfoPlugin();

  final DeviceInfoPlugin _plugin;
  String? _deviceName;

  Future<String> deviceName() async {
    return _deviceName ??= await _resolveDeviceName();
  }

  Future<String> _resolveDeviceName() async {
    try {
      if (kIsWeb) {
        final web = await _plugin.webBrowserInfo;
        return 'Web ${web.browserName.name}';
      }
      final name = switch (defaultTargetPlatform) {
        TargetPlatform.android => await _android(),
        TargetPlatform.iOS => (await _plugin.iosInfo).name,
        TargetPlatform.macOS => (await _plugin.macOsInfo).computerName,
        TargetPlatform.windows => (await _plugin.windowsInfo).computerName,
        TargetPlatform.linux => (await _plugin.linuxInfo).prettyName,
        TargetPlatform.fuchsia => 'Fuchsia',
      };
      return name.trim().isEmpty ? _fallback : name.trim();
    } on Object {
      return _fallback;
    }
  }

  Future<String> _android() async {
    final info = await _plugin.androidInfo;
    return '${info.manufacturer} ${info.model}';
  }

  String get _fallback => 'flutter-${defaultTargetPlatform.name}';
}
