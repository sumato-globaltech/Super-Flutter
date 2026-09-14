import 'error_reporter.dart';

class CompositeErrorReporter implements ErrorReporter {
  final List<ErrorReporter> reporters;

  CompositeErrorReporter(this.reporters);

  @override
  void report(Object error, StackTrace stackTrace, {String? reason}) {
    for (final reporter in reporters) {
      reporter.report(error, stackTrace, reason: reason);
    }
  }
}
