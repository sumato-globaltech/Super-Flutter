abstract final class ApiEndpoints {
  static const login = '/auth/login';
  static const refresh = '/auth/refresh';
  static const currentUser = '/auth/me';

  static const products = '/products';
  static const productSearch = '/products/search';
  static const categoryList = '/products/category-list';

  static String productById(int id) => '/products/$id';

  static String productsByCategory(String slug) => '/products/category/$slug';

  static String userById(int id) => '/users/$id';

  static const uploadAvatar = '/users/avatar';

  static const publicPaths = <String>{login, refresh};

  static bool isPublic(String path) =>
      publicPaths.any((public) => path.endsWith(public));
}
