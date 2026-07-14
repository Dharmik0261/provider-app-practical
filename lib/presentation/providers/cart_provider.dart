import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/cart_usecases.dart';

class CartProvider extends ChangeNotifier {
  final GetCartUseCase getCartUseCase;
  final AddToCartUseCase addToCartUseCase;
  final RemoveFromCartUseCase removeFromCartUseCase;
  final UpdateCartQuantityUseCase updateCartQuantityUseCase;
  final ClearCartUseCase clearCartUseCase;
  final SharedPreferences sharedPreferences;

  List<CartItem> _cartItems = [];
  List<int> _wishlistProductIds = [];
  bool _isLoading = false;
  String? _errorMessage;

  static const String _wishlistKey = 'user_wishlist_ids';

  CartProvider({
    required this.getCartUseCase,
    required this.addToCartUseCase,
    required this.removeFromCartUseCase,
    required this.updateCartQuantityUseCase,
    required this.clearCartUseCase,
    required this.sharedPreferences,
  });

  // Getters
  List<CartItem> get cartItems => _cartItems;
  List<int> get wishlistProductIds => _wishlistProductIds;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get subtotal => _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get deliveryCharge => subtotal > 100 ? 0.0 : (subtotal == 0 ? 0.0 : 10.0); // Free delivery over $100
  double get total => subtotal + deliveryCharge;
  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  Future<void> loadCartAndWishlist() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _cartItems = await getCartUseCase.execute();
      
      // Load wishlist
      final wishlistStrings = sharedPreferences.getStringList(_wishlistKey) ?? [];
      _wishlistProductIds = wishlistStrings.map((e) => int.parse(e)).toList();
    } catch (e) {
      _errorMessage = 'Failed to load cart items from local storage.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(Product product, int quantity) async {
    _isLoading = true;
    notifyListeners();

    try {
      _cartItems = await addToCartUseCase.execute(product, quantity);
    } catch (e) {
      _errorMessage = 'Failed to add item to cart.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeFromCart(int productId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _cartItems = await removeFromCartUseCase.execute(productId);
    } catch (e) {
      _errorMessage = 'Failed to remove item.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateQuantity(int productId, int quantity) async {
    // Optimistic UI updates for ultra smooth performance
    final originalItems = List<CartItem>.from(_cartItems);
    
    _cartItems = _cartItems.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).where((item) => item.quantity > 0).toList();
    notifyListeners();

    try {
      _cartItems = await updateCartQuantityUseCase.execute(productId, quantity);
      notifyListeners();
    } catch (e) {
      // Revert if background update fails
      _cartItems = originalItems;
      _errorMessage = 'Failed to update quantity.';
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      _cartItems = await clearCartUseCase.execute();
    } catch (e) {
      _errorMessage = 'Failed to clear cart.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleWishlist(int productId) async {
    if (_wishlistProductIds.contains(productId)) {
      _wishlistProductIds.remove(productId);
    } else {
      _wishlistProductIds.add(productId);
    }
    notifyListeners();

    try {
      final stringList = _wishlistProductIds.map((id) => id.toString()).toList();
      await sharedPreferences.setStringList(_wishlistKey, stringList);
    } catch (_) {
      // Revert in case of storage failure
    }
  }

  bool isWishlisted(int productId) {
    return _wishlistProductIds.contains(productId);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
