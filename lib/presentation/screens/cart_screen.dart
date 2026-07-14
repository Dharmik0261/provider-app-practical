import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_theme.dart';
import '../providers/cart_provider.dart';
import '../widgets/custom_image_view.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          // Option to clear entire cart
          Consumer<CartProvider>(
            builder: (context, provider, child) {
              if (provider.cartItems.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_sweep_outlined, color: AppTheme.error),
                tooltip: 'Clear Cart',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dialogCtx) => AlertDialog(
                      title: const Text('Clear Cart'),
                      content: const Text('Are you sure you want to remove all items from your cart?'),
                      actions: [
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () => Navigator.pop(dialogCtx),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
                          child: const Text('Clear', style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            context.read<CartProvider>().clearCart();
                            Navigator.pop(dialogCtx);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.cartItems.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
          }

          if (provider.cartItems.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.06),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.shopping_cart_checkout_outlined,
                        size: 80,
                        color: AppTheme.primary.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Your cart is empty',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Looks like you haven\'t added anything to your cart yet.',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'START SHOPPING',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              // Cart items list with swiping/slide to delete capability
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: provider.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = provider.cartItems[index];
                    final product = item.product;

                    return Dismissible(
                      key: Key('cart-item-${product.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete_outline_rounded, color: AppTheme.error, size: 28),
                      ),
                      onDismissed: (direction) {
                        provider.removeFromCart(product.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${product.title} removed from cart.')),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade100, width: 1.5),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: Row(
                          children: [
                            // Cached Thumbnail
                            CustomImageView(
                              imageUrl: product.thumbnail,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            const SizedBox(width: 14),
                            
                            // Info Column
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product.category.toUpperCase(),
                                    style: const TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '\$${product.price.toStringAsFixed(2)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Quantity Controls
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, color: AppTheme.textSecondary, size: 18),
                                  onPressed: () => provider.removeFromCart(product.id),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          provider.updateQuantity(product.id, item.quantity - 1);
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          child: Icon(Icons.remove, size: 14),
                                        ),
                                      ),
                                      Text(
                                        '${item.quantity}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          provider.updateQuantity(product.id, item.quantity + 1);
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          child: Icon(Icons.add, size: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Order Checkout breakdown card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                          Text('\$${provider.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Delivery Charge', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                          Text(
                            provider.deliveryCharge == 0 ? 'Free' : '\$${provider.deliveryCharge.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: provider.deliveryCharge == 0 ? AppTheme.success : AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(
                            '\$${provider.total.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Checkout Button action mock
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Checkout feature is mocked for this module.'),
                                backgroundColor: AppTheme.primary,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'PROCEED TO CHECKOUT',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
