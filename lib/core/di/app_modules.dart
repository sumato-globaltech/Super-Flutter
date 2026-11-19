import 'package:injectable/injectable.dart' hide Environment;
import 'package:super_flutter/app/config/app_config.dart';
import 'package:super_flutter/app/config/environment.dart';

import '../error/composite_error_reporter.dart';
import '../error/error_reporter.dart';
import '../error/logger_error_reporter.dart';
import '../logging/app_logger.dart';


@module
abstract class CoreModule {
  @lazySingleton
  AppLogger get logger => AppLogger();

  @lazySingleton
  Environment appEnvironment(AppConfig config) => config.environment;

  @lazySingleton
  ErrorReporter errorReporter(AppLogger logger) {
    return CompositeErrorReporter([LoggerErrorReporter(logger)]);
  }
}
