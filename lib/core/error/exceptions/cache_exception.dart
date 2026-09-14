import '../app_exception.dart';

class CacheException extends AppException {
  const CacheException([
    super.message = 'Could not read locally stored data.',
    Object? cause,
  ]) : super(cause: cause);
}