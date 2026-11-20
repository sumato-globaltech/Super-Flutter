import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:super_flutter/core/constants/constants.dart';

class RemoteConfigService {
  RemoteConfigService._();

  static final RemoteConfigService instance = RemoteConfigService._();
  static const String loginFormKey = 'login_form';

  // Resolved lazily so creating the service never throws when Firebase is
  // not initialized; callers handle the failure instead.
  FirebaseRemoteConfig get _remoteConfig => FirebaseRemoteConfig.instance;
  Future<void>? _initializeFuture;

  Future<void> fetchConfig() {
    return _initializeFuture ??= _fetchConfig();
  }

  Future<void> _fetchConfig() async {
    try {
      // final defaultLoginFormJson = await _loadDefaultLoginFormJson();
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: const Duration(minutes: kDebugMode ? 1 : 30),
        ),
      );
      // await _remoteConfig.setDefaults({loginFormKey: defaultLoginFormJson});
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint("Error fetching remote config: $e");
    }
  }

  String getStringValue(String key) {
    return _remoteConfig.getString(key);
  }

  Map<String, dynamic>? getStringJson(String key) {
    try {
      final value = _remoteConfig.getString(key);
      if (value.trim().isEmpty) {
        return null;
      }
      return jsonDecode(value) as Map<String, dynamic>;
    } catch (e) {
      debugPrint("Error decoding JSON from remote config for key $key: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getLoginFormJson() async {
    await fetchConfig();
    return getStringJson(loginFormKey);
  }

  bool getBoolValue(String key) {
    return _remoteConfig.getBool(key);
  }

  Future<Map<String, dynamic>?> getConfigJson() async {
    await fetchConfig();
    return getStringJson(Constants.remoteAppConfig);
  }

  int getIntValue(String key) {
    return _remoteConfig.getInt(key);
  }
}
