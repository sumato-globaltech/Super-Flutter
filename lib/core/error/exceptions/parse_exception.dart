import '../app_exception.dart';

class ParseException extends AppException {
  const ParseException([
    super.message = 'Unexpected response from the server.',
    Object? cause,
  ]) : super(cause: cause);
}