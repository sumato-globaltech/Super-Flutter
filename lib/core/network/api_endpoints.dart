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

  static const farm = '/api/v1/farmer/farms';

  static const blocks = '/api/v1/farmer/blocks';

  static const soilTypes = '/api/v1/farmer/soil-types';

  static const irrigationMethods = '/api/v1/farmer/irrigation-methods';

  static const landOwnerships = '/api/v1/farmer/land-ownerships';

  static String farmDetail(String farm) => '/api/v1/farmer/farms/$farm';
}
