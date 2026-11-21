abstract final class ApiEndpoints {
  static const login = '/api/v1/login';
  static const tokenRefresh = '/api/v1/token/refresh';

  static const publicPaths = <String>{login};

  static bool isPublic(String path) =>
      publicPaths.any((public) => path.endsWith(public));
}
