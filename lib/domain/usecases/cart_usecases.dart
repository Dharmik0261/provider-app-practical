import '../entities/cart_item.dart';
import '../entities/product.dart';
import '../repositories/cart_repository.dart';

class GetCartUseCase {
  final CartRepository repository;

  GetCartUseCase(this.repository);

  Future<List<CartItem>> execute() {
    return repository.getCart();
  }
}

class AddToCartUseCase {
  final CartRepository repository;

  AddToCartUseCase(this.repository);

  Future<List<CartItem>> execute(Product product, int quantity) {
    return repository.addToCart(product, quantity);
  }
}

class RemoveFromCartUseCase {
  final CartRepository repository;

  RemoveFromCartUseCase(this.repository);

  Future<List<CartItem>> execute(int productId) {
    return repository.removeFromCart(productId);
  }
}

class UpdateCartQuantityUseCase {
  final CartRepository repository;

  UpdateCartQuantityUseCase(this.repository);

  Future<List<CartItem>> execute(int productId, int quantity) {
    return repository.updateQuantity(productId, quantity);
  }
}

class ClearCartUseCase {
  final CartRepository repository;

  ClearCartUseCase(this.repository);

  Future<List<CartItem>> execute() {
    return repository.clearCart();
  }
}
