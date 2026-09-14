import 'package:dio/dio.dart';

import '../error/app_exception.dart';
import '../error/exceptions/unauthorized_exception.dart';
import '../error/exceptions/validation_exception.dart';

class NetworkException extends AppException {
  const NetworkException(super.message, {super.statusCode, super.cause});

  static AppException fromDioException(DioException error) {
    final existing = error.error;
    if (existing is AppException) return existing;

    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout => RequestTimeoutException(
        cause: error,
      ),

      DioExceptionType.cancel => RequestCancelledException(cause: error),

      DioExceptionType.connectionError => NoInternetException(cause: error),

      DioExceptionType.badCertificate => const NoInternetException(
        message: 'Could not verify the server certificate.',
      ),

      DioExceptionType.badResponse => _fromResponse(error),

      DioExceptionType.unknown => NetworkException(
        error.message ?? 'A network error occurred.',
        cause: error,
      ),
    };
  }

  static AppException _fromResponse(DioException error) {
    final response = error.response;
    final status = response?.statusCode ?? 0;
    final message = _extractMessage(response?.data);

    if (status == 401 || status == 403) {
      return UnauthorizedException(
        message ?? 'Your session has expired. Please sign in again.',
        error,
      );
    }
    if (status == 404) {
      return NotFoundException(
        message: message ?? 'We could not find what you were looking for.',
        cause: error,
      );
    }
    if (status >= 500) {
      return ServerException(
        message ?? 'Something went wrong on our side.',
        statusCode: status,
        cause: error,
      );
    }
    if (status >= 400) {
      final fieldErrors = _extractFieldErrors(response?.data);
      if (fieldErrors.isNotEmpty) {
        return ValidationException(
          message ?? 'Please correct the highlighted fields.',
          fieldErrors: fieldErrors,
        );
      }
      return BadRequestException(
        message ?? 'The request could not be completed.',
        statusCode: status,
        cause: error,
      );
    }
    return NetworkException(
      message ?? 'Unexpected response ($status).',
      statusCode: status,
      cause: error,
    );
  }

  static String? _extractMessage(Object? data) {
    if (data is String && data.trim().isNotEmpty) return data;
    if (data is! Map) return null;

    for (final key in const ['message', 'error', 'detail', 'title']) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) return value;
    }

    final fieldErrors = _extractFieldErrors(data);
    if (fieldErrors.isNotEmpty) return fieldErrors.values.first;

    return null;
  }

  static Map<String, String> _extractFieldErrors(Object? data) {
    if (data is! Map) return const {};

    final errors = data['errors'];
    if (errors is! Map) return const {};

    final result = <String, String>{};
    for (final entry in errors.entries) {
      final key = entry.key;
      final value = entry.value;
      if (key is! String) continue;

      if (value is String && value.trim().isNotEmpty) {
        result[key] = value;
      } else if (value is List) {
        final first = value.whereType<String>().firstOrNull;
        if (first != null && first.trim().isNotEmpty) result[key] = first;
      }
    }
    return result;
  }
}

class NoInternetException extends NetworkException {
  const NoInternetException({
    String message = 'No internet connection.',
    super.cause,
  }) : super(message);
}

class RequestTimeoutException extends NetworkException {
  const RequestTimeoutException({
    String message = 'The request took too long. Please try again.',
    super.cause,
  }) : super(message);
}

class RequestCancelledException extends NetworkException {
  const RequestCancelledException({
    String message = 'Request cancelled.',
    super.cause,
  }) : super(message);
}

class BadRequestException extends NetworkException {
  const BadRequestException(super.message, {super.statusCode, super.cause});
}

class NotFoundException extends NetworkException {
  const NotFoundException({String message = 'Not found.', super.cause})
    : super(message, statusCode: 404);
}

class ServerException extends NetworkException {
  const ServerException(super.message, {super.statusCode, super.cause});
}
