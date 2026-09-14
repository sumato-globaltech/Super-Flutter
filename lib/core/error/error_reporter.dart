

abstract interface class ErrorReporter {

  void report(
      Object error,
      StackTrace stackTrace, {
        String? reason,
      });

}