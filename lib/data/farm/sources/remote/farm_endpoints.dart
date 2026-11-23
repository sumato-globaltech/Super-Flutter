class FarmEndpoints {
  static const String farms = '/api/v1/farms';
  static String farm(String id) => '/api/v1/farms/$id';
  static String archive(String id) => '/api/v1/farms/$id/archive';
  static String unarchive(String id) => '/api/v1/farms/$id/unarchive';
  static String crops(String id) => '/api/v1/farms/$id/crops';
  static String crop(String id, String cropId) =>
      '/api/v1/farms/$id/crops/$cropId';
  static String transactions(String id) => '/api/v1/farms/$id/transactions';
  static String transactionSummary(String id) =>
      '/api/v1/farms/$id/transactions/summary';
  static String photos(String id) => '/api/v1/farms/$id/photos';
  static String photo(String id, String photoId) =>
      '/api/v1/farms/$id/photos/$photoId';
}
