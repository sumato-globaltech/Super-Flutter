import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../core/constants/constants.dart';
import '../../core/logging/app_logger.dart';
import '../../core/network/dio_client.dart';
import '../../core/service/remote_service.dart';
import '../../core/storage/storage_service.dart';
import '../../core/utils/utils.dart';
import '../../features/auth/session/bloc/auth_cubit.dart';
import 'remote_app_settings.dart';

@lazySingleton
class AppStartup {
  AppStartup(this._storage, this._authCubit, this._dioClient, this._logger);

  final StorageService _storage;
  final AuthCubit _authCubit;
  final DioClient _dioClient;
  final AppLogger _logger;

  static const _remoteConfigTimeout = Duration(seconds: 5);

  RemoteAppSettings _settings = const RemoteAppSettings();
  bool _updateRequired = false;

  RemoteAppSettings get settings => _settings;

  bool get updateRequired => _updateRequired;

  Future<void> run() async {
    await Constants.setAppInfo();

    await _storage.restoreSession();

    _settings = await _loadRemoteSettings();
    _applyApiBaseUrl(_settings.apiBaseUrl);
    _updateRequired = Constants.buildNumber < _settings.minBuildNumber;

    await _authCubit.initialize();
  }

  Future<RemoteAppSettings> _loadRemoteSettings() async {
    try {
      final config = await RemoteConfigService.instance.getConfigJson().timeout(
        _remoteConfigTimeout,
      );
      return RemoteAppSettings.fromConfig(
        config,
        packageName: Constants.packageInfo?.packageName ?? '',
        platform: Utils.getPlatformName,
      );
    } on Object catch (error) {
      _logger.warning('Remote Config unavailable, using defaults: $error');
      return const RemoteAppSettings();
    }
  }

  void _applyApiBaseUrl(String? apiBaseUrl) {
    if (kDebugMode || apiBaseUrl == null) return;
    _dioClient.setBaseUrl(apiBaseUrl);
    _logger.info('API base URL overridden by Remote Config: $apiBaseUrl');
  }
}
