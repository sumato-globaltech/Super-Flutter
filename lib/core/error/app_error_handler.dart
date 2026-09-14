
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'error_reporter.dart';

@lazySingleton
class AppErrorHandler {
  final ErrorReporter reporter;

  AppErrorHandler(this.reporter);

  void initialize() {
    FlutterError.onError = _handleFlutterError;
    PlatformDispatcher.instance.onError = _handlePlatformError;
  }

  void _handleFlutterError(
      FlutterErrorDetails details,
      ) {
    // Keep Flutter's default error presentation.
    FlutterError.presentError(details);

    reporter.report(
      details.exception,
      details.stack ?? StackTrace.empty,
      reason: details.context?.toString(),
    );
  }

  bool _handlePlatformError(
      Object error,
      StackTrace stack,
      ) {
    reporter.report(
      error,
      stack,
      reason: 'Unhandled platform error',
    );

    return true;
  }
}