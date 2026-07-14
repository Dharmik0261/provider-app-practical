import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({
    required int limit,
    required int skip,
    String? sortBy,
    String? order,
  });

  Future<List<ProductModel>> searchProducts(
    String query, {
    required int limit,
    required int skip,
  });

  Future<List<String>> getCategories();

  Future<List<ProductModel>> getProductsByCategory(
    String category, {
    required int limit,
    required int skip,
  });

  Future<ProductModel> getProductDetails(int id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final DioClient dioClient;

  ProductRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<ProductModel>> getProducts({
    required int limit,
    required int skip,
    String? sortBy,
    String? order,
  }) async {
    final Map<String, dynamic> queryParams = {
      'limit': limit,
      'skip': skip,
    };
    if (sortBy != null && sortBy.isNotEmpty) {
      queryParams['sortBy'] = sortBy;
    }
    if (order != null && order.isNotEmpty) {
      queryParams['order'] = order;
    }

    final response = await dioClient.get(
      ApiConstants.products,
      queryParameters: queryParams,
    );

    final List<dynamic> productsList = response.data['products'] as List<dynamic>;
    return productsList
        .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ProductModel>> searchProducts(
    String query, {
    required int limit,
    required int skip,
  }) async {
    final response = await dioClient.get(
      ApiConstants.searchProducts,
      queryParameters: {
        'q': query,
        'limit': limit,
        'skip': skip,
      },
    );

    final List<dynamic> productsList = response.data['products'] as List<dynamic>;
    return productsList
        .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<String>> getCategories() async {
    final response = await dioClient.get(ApiConstants.categories);
    
    // In some dummyjson versions, categories is a list of strings, in some it's a list of objects with slug & name.
    // Let's handle both dynamically to prevent crashes.
    final dynamic data = response.data;
    if (data is List) {
      return data.map((item) {
        if (item is String) {
          return item;
        } else if (item is Map && item.containsKey('slug')) {
          return item['slug'] as String;
        }
        return item.toString();
      }).toList();
    }
    
    return [];
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(
    String category, {
    required int limit,
    required int skip,
  }) async {
    final response = await dioClient.get(
      '${ApiConstants.productsByCategory}/$category',
      queryParameters: {
        'limit': limit,
        'skip': skip,
      },
    );

    final List<dynamic> productsList = response.data['products'] as List<dynamic>;
    return productsList
        .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ProductModel> getProductDetails(int id) async {
    final response = await dioClient.get('${ApiConstants.products}/$id');
    return ProductModel.fromJson(response.data as Map<String, dynamic>);
  }
}
