import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasource/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Product>> getProducts({
    required int limit,
    required int skip,
    String? sortBy,
    String? order,
  }) async {
    return await remoteDataSource.getProducts(
      limit: limit,
      skip: skip,
      sortBy: sortBy,
      order: order,
    );
  }

  @override
  Future<List<Product>> searchProducts(
    String query, {
    required int limit,
    required int skip,
  }) async {
    return await remoteDataSource.searchProducts(
      query,
      limit: limit,
      skip: skip,
    );
  }

  @override
  Future<List<String>> getCategories() async {
    return await remoteDataSource.getCategories();
  }

  @override
  Future<List<Product>> getProductsByCategory(
    String category, {
    required int limit,
    required int skip,
  }) async {
    return await remoteDataSource.getProductsByCategory(
      category,
      limit: limit,
      skip: skip,
    );
  }

  @override
  Future<Product> getProductDetails(int id) async {
    return await remoteDataSource.getProductDetails(id);
  }
}
