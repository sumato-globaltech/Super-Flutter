import '../logging/app_logger.dart';
import 'error_reporter.dart';

class LoggerErrorReporter implements ErrorReporter {
  final AppLogger logger;

  LoggerErrorReporter(this.logger);

  @override
  void report(Object error, StackTrace stackTrace, {String? reason}) {
    logger.error(
      reason ?? 'Unhandled application error',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
