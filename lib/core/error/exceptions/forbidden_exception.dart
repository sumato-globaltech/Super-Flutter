import '../app_exception.dart';

class ForbiddenException extends AppException {
  const ForbiddenException([
    super.message = 'You do not have access to this.',
    Object? cause,
  ]) : super(statusCode: 403, cause: cause);
}
