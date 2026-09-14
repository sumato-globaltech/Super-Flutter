import '../app_exception.dart';

class UnknownException extends AppException {
  const UnknownException([
    super.message = 'Something went wrong. Please try again.',
    Object? cause,
  ]) : super(cause: cause);
}