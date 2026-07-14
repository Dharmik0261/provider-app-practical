import '../../domain/entities/cart_item.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasource/cart_local_data_source.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource localDataSource;

  CartRepositoryImpl({required this.localDataSource});

  @override
  Future<List<CartItem>> getCart() async {
    return await localDataSource.getCart();
  }

  @override
  Future<List<CartItem>> addToCart(Product product, int quantity) async {
    final currentItems = await localDataSource.getCart();
    final updatedList = List<CartItemModel>.from(currentItems);

    final existingIndex = updatedList.indexWhere((item) => item.product.id == product.id);

    if (existingIndex != -1) {
      final existingItem = updatedList[existingIndex];
      updatedList[existingIndex] = CartItemModel(
        product: _toProductModel(product),
        quantity: existingItem.quantity + quantity,
      );
    } else {
      updatedList.add(CartItemModel(
        product: _toProductModel(product),
        quantity: quantity,
      ));
    }

    await localDataSource.saveCart(updatedList);
    return updatedList;
  }

  @override
  Future<List<CartItem>> removeFromCart(int productId) async {
    final currentItems = await localDataSource.getCart();
    final updatedList = currentItems.where((item) => item.product.id != productId).toList();

    await localDataSource.saveCart(updatedList);
    return updatedList;
  }

  @override
  Future<List<CartItem>> updateQuantity(int productId, int quantity) async {
    final currentItems = await localDataSource.getCart();
    
    if (quantity <= 0) {
      return await removeFromCart(productId);
    }

    final updatedList = List<CartItemModel>.from(currentItems);
    final existingIndex = updatedList.indexWhere((item) => item.product.id == productId);

    if (existingIndex != -1) {
      updatedList[existingIndex] = CartItemModel(
        product: _toProductModel(updatedList[existingIndex].product),
        quantity: quantity,
      );
    }

    await localDataSource.saveCart(updatedList);
    return updatedList;
  }

  @override
  Future<List<CartItem>> clearCart() async {
    final List<CartItemModel> emptyList = [];
    await localDataSource.saveCart(emptyList);
    return emptyList;
  }

  // Convert Product entity to ProductModel for local serialization
  ProductModel _toProductModel(Product p) {
    if (p is ProductModel) return p;
    return ProductModel(
      id: p.id,
      title: p.title,
      description: p.description,
      price: p.price,
      discountPercentage: p.discountPercentage,
      rating: p.rating,
      stock: p.stock,
      brand: p.brand,
      category: p.category,
      thumbnail: p.thumbnail,
      images: p.images,
    );
  }
}
