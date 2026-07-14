class ApiConstants {
  static const String baseUrl = 'https://dummyjson.com';
  static const String login = '/auth/login';
  static const String profile = '/auth/me';
  static const String products = '/products';
  static const String categories = '/products/category-list';
  static const String productsByCategory = '/products/category';
  static const String searchProducts = '/products/search';

  // Request timeouts
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
}
