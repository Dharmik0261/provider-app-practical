import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item_model.dart';
import '../../core/errors/exceptions.dart';

abstract class CartLocalDataSource {
  Future<List<CartItemModel>> getCart();
  Future<void> saveCart(List<CartItemModel> items);
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  final SharedPreferences sharedPreferences;

  CartLocalDataSourceImpl(this.sharedPreferences);

  static const String _cartKey = 'user_cart_items';

  @override
  Future<List<CartItemModel>> getCart() async {
    final cartJson = sharedPreferences.getString(_cartKey);
    if (cartJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(cartJson) as List<dynamic>;
        return decoded
            .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  @override
  Future<void> saveCart(List<CartItemModel> items) async {
    try {
      final String encoded = jsonEncode(
        items.map((item) => item.toJson()).toList(),
      );
      await sharedPreferences.setString(_cartKey, encoded);
    } catch (e) {
      throw CacheException(message: 'Failed to persist cart items locally');
    }
  }
}
