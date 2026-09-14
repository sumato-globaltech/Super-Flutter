import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../error/composite_error_reporter.dart';
import '../error/error_reporter.dart';
import '../error/logger_error_reporter.dart';
import '../logging/app_logger.dart';


@module
abstract class CoreModule {
  @lazySingleton
  AppLogger get logger => AppLogger();

  @lazySingleton
  ErrorReporter errorReporter(AppLogger logger) {
    return CompositeErrorReporter([LoggerErrorReporter(logger)]);
  }
}
