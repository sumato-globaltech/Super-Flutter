abstract final class ApiEndpoints {
  static const login = '/api/v1/login';
  static const tokenRefresh = '/api/v1/token/refresh';

  static const publicPaths = <String>{login, requestOtp, verifyOtp};

  static bool isPublic(String path) =>
      publicPaths.any((public) => path.endsWith(public));

  static const me = '/api/v1/me';

  static const logout = '/api/v1/logout';

  static const logoutAll = '/api/v1/logout-all';

  static const requestOtp = '/api/v1/otp/request';

  static const verifyOtp = '/api/v1/otp/verify';

  static const changePassword = '/api/v1/profile/password';

  static String notice(String notice) => '/api/v1/notices/$notice';

  static const notices = '/api/v1/notices';

  static const alerts = '/api/v1/alerts';

  static const banners = '/api/v1/banners';
}
