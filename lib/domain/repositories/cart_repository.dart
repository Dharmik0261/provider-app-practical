import '../entities/cart_item.dart';
import '../entities/product.dart';

abstract class CartRepository {
  Future<List<CartItem>> getCart();
  Future<List<CartItem>> addToCart(Product product, int quantity);
  Future<List<CartItem>> removeFromCart(int productId);
  Future<List<CartItem>> updateQuantity(int productId, int quantity);
  Future<List<CartItem>> clearCart();
}
