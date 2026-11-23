import 'package:dio/dio.dart';

/// Reports a 403 whose `meta.code` is `password_change_required`: the
/// server answers every call that way until the password is changed.
class PasswordPolicyInterceptor extends Interceptor {
  PasswordPolicyInterceptor({required this._onPasswordChangeRequired});

  static const code = 'password_change_required';

  final void Function() _onPasswordChangeRequired;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    final body = response?.data;
    final meta = body is Map ? body['meta'] : null;
    if (response?.statusCode == 403 && meta is Map && meta['code'] == code) {
      _onPasswordChangeRequired();
    }
    handler.next(err);
  }
}
