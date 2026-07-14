import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts({
    required int limit,
    required int skip,
    String? sortBy,
    String? order,
  });
  
  Future<List<Product>> searchProducts(
    String query, {
    required int limit,
    required int skip,
  });

  Future<List<String>> getCategories();

  Future<List<Product>> getProductsByCategory(
    String category, {
    required int limit,
    required int skip,
  });

  Future<Product> getProductDetails(int id);
}
