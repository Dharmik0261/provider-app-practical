import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductsUseCase {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  Future<List<Product>> execute({
    required int limit,
    required int skip,
    String? sortBy,
    String? order,
  }) {
    return repository.getProducts(
      limit: limit,
      skip: skip,
      sortBy: sortBy,
      order: order,
    );
  }
}

class SearchProductsUseCase {
  final ProductRepository repository;

  SearchProductsUseCase(this.repository);

  Future<List<Product>> execute(
    String query, {
    required int limit,
    required int skip,
  }) {
    return repository.searchProducts(
      query,
      limit: limit,
      skip: skip,
    );
  }
}

class GetCategoriesUseCase {
  final ProductRepository repository;

  GetCategoriesUseCase(this.repository);

  Future<List<String>> execute() {
    return repository.getCategories();
  }
}

class GetProductsByCategoryUseCase {
  final ProductRepository repository;

  GetProductsByCategoryUseCase(this.repository);

  Future<List<Product>> execute(
    String category, {
    required int limit,
    required int skip,
  }) {
    return repository.getProductsByCategory(
      category,
      limit: limit,
      skip: skip,
    );
  }
}

class GetProductDetailsUseCase {
  final ProductRepository repository;

  GetProductDetailsUseCase(this.repository);

  Future<Product> execute(int id) {
    return repository.getProductDetails(id);
  }
}
