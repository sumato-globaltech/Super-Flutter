import '../app_exception.dart';

class UnauthorizedException extends AppException {
  const UnauthorizedException([
    super.message = 'Your session has expired. Please sign in again.',
    Object? cause,
  ]) : super(statusCode: 401, cause: cause);
}