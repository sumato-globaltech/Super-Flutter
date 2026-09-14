import '../app_exception.dart';

class ValidationException extends AppException {
  const ValidationException(super.message, {this.fieldErrors = const {}});

  final Map<String, String> fieldErrors;
}