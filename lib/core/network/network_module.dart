import 'package:injectable/injectable.dart' hide Environment;
import 'package:super_flutter/core/network/session_manager.dart';

import '../logging/app_logger.dart';
import '../storage/secure_storage.dart';
import 'dio_client.dart';
import '../../app/config/environment.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  DioClient dioClient(
    Environment environment,
    SecureStorage secureStorage,
    AppLogger logger,
    SessionManager sessionManager,
  ) {
    return DioClient(
      environment: environment,
      secureStorage: secureStorage,
      logger: logger,
      onSessionExpired: sessionManager.onSessionExpired,
    );
  }
}
