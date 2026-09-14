import 'dart:developer' as developer;

enum LogLevel { debug, info, warning, error }

class AppLogger {

  AppLogger({this.enabled = true, this.minimumLevel = LogLevel.debug});

  final bool enabled;

  final LogLevel minimumLevel;

  void debug(String message, {String name = 'app'}) =>
      _log(LogLevel.debug, message, name: name);

  void info(String message, {String name = 'app'}) =>
      _log(LogLevel.info, message, name: name);

  void warning(String message, {String name = 'app'}) =>
      _log(LogLevel.warning, message, name: name);

  void error(
    String message, {
    String name = 'app',
    Object? error,
    StackTrace? stackTrace,
  }) => _log(
    LogLevel.error,
    message,
    name: name,
    error: error,
    stackTrace: stackTrace,
  );

  void _log(
    LogLevel level,
    String message, {
    required String name,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!enabled || level.index < minimumLevel.index) return;

    developer.log(
      message,
      name: name,
      level: _severity(level),
      error: error,
      stackTrace: stackTrace,
    );
  }

  int _severity(LogLevel level) => switch (level) {
    LogLevel.debug => 500,
    LogLevel.info => 800,
    LogLevel.warning => 900,
    LogLevel.error => 1000,
  };
}
