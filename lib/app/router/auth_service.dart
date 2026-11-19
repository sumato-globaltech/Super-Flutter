import 'package:flutter/foundation.dart';
import 'package:super_flutter/core/constants/constants.dart';
import 'package:super_flutter/core/service/remote_service.dart';
import 'package:super_flutter/core/services/remote_service.dart';
import 'package:super_flutter/core/storage/secure_storage.dart';
import 'package:super_flutter/core/utils/enums.dart';
import 'package:super_flutter/core/utils/utils.dart';

class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();
  AuthStatus authStatus = AuthStatus.unauthenticated;
  // UserRole userRole = UserRole.engineer;

  Future<void> init() async {
    await checkAuth();
  }

  Future<void> checkAuth() async {
    final config = await RemoteConfigService.instance.getConfigJson();
    // final apiBaseUrl = kDebugMode
    //     ? null
    //     : config?[Constants.packageInfo?.packageName]?['api'];
    // ApiService().dio.options.baseUrl =
    //     (apiBaseUrl ?? Constants.apiUrl) + Constants.apiVersion;
    // if (apiBaseUrl != null) {
    //   Constants.apiUrl = apiBaseUrl;
    // }
    final token = await TokenHandler.getToken();
    final int installedBuild =
        int.tryParse(Constants.packageInfo?.buildNumber ?? '0') ?? 0;
    final int minRequiredBuild =
        int.tryParse(
          '${config?[Constants.packageInfo?.packageName]?['build_number'][Utils.getPlatformName] ?? Constants.buildNumber}',
        ) ??
        0;
    if (installedBuild >= minRequiredBuild) {
      if (token.isNotEmpty) {
        authStatus = AuthStatus.authenticated;
        // Check User Role and Verification Status
        // final appSettings = await StorageService.instance.getAppSettings();
        return;
      }
    } else {
      authStatus = AuthStatus.update;
    }
  }
}
