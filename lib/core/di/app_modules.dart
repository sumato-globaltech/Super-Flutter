import 'package:injectable/injectable.dart' hide Environment;
import 'package:starter/app/config/app_config.dart';
import 'package:starter/app/config/environment.dart';

import '../error/composite_error_reporter.dart';
import '../error/error_reporter.dart';
import '../error/logger_error_reporter.dart';
import '../logging/app_logger.dart';


@module
abstract class CoreModule {
  @lazySingleton
  AppLogger get logger => AppLogger();

  /// Exposes the active [Environment] from the manually-registered [AppConfig]
  /// so generated providers (storage, network) can depend on it.
  @lazySingleton
  Environment appEnvironment(AppConfig config) => config.environment;

  @lazySingleton
  ErrorReporter errorReporter(AppLogger logger) {
    return CompositeErrorReporter([LoggerErrorReporter(logger)]);
  }
}
