import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_theme.dart';
import '../../domain/entities/product.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/custom_image_view.dart';
import '../widgets/shimmer_loaders.dart';
import 'cart_screen.dart';
import 'login_screen.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  late AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    _authProvider = context.read<AuthProvider>();
    _authProvider.addListener(_authListener);

    // Fetch initial list and categories
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchCategories();
      context.read<ProductProvider>().fetchProducts(isRefresh: true);
      context.read<CartProvider>().loadCartAndWishlist();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    _authProvider.removeListener(_authListener);
    super.dispose();
  }

  void _authListener() {
    if (!mounted) return;
    if (!_authProvider.isAuthenticated) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<ProductProvider>().fetchProducts();
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<ProductProvider>().search(query.trim());
    });
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final productProvider = context.read<ProductProvider>();
        final currentSortBy = productProvider.sortBy;
        final currentSortOrder = productProvider.sortOrder;

        Widget sortTile(String title, String field, String order) {
          final isSelected = currentSortBy == field && currentSortOrder == order;
          return ListTile(
            title: Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
              ),
            ),
            trailing: isSelected ? const Icon(Icons.check_circle, color: AppTheme.primary) : null,
            onTap: () {
              productProvider.setSort(field, order);
              Navigator.pop(sheetContext);
            },
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Sort Products By',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              sortTile('Default (Featured)', '', ''),
              sortTile('Price: Low to High', 'price', 'asc'),
              sortTile('Price: High to Low', 'price', 'desc'),
              sortTile('Name: A to Z', 'title', 'asc'),
              sortTile('Name: Z to A', 'title', 'desc'),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Aura Catalog',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        leading: IconButton(
          icon: const Icon(Icons.logout_rounded, color: AppTheme.textSecondary),
          tooltip: 'Sign Out',
          onPressed: () {
            showDialog(
              context: context,
              builder: (dialogCtx) => AlertDialog(
                title: const Text('Sign Out'),
                content: const Text('Are you sure you want to log out?'),
                actions: [
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(dialogCtx),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
                    child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      Navigator.pop(dialogCtx);
                      context.read<AuthProvider>().logout();
                    },
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          // Dynamic Cart count badge
          Consumer<CartProvider>(
            builder: (context, provider, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined, size: 28),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CartScreen()),
                      );
                    },
                  ),
                  if (provider.itemCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppTheme.accent,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                        child: Text(
                          '${provider.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search and Sort controls
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primary),
                        hintText: 'Search products...',
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () {
                                  _searchController.clear();
                                  context.read<ProductProvider>().search('');
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Sort button
                GestureDetector(
                  onTap: _showSortSheet,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200, width: 1.5),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: const Icon(Icons.tune_rounded, color: AppTheme.primary),
                  ),
                ),
              ],
            ),
          ),

          // Horizontal Categories scroll bar
          Consumer<ProductProvider>(
            builder: (context, provider, child) {
              if (provider.categories.isEmpty) {
                return const CategoryListShimmer();
              }

              return SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.categories.length + 1,
                  itemBuilder: (context, index) {
                    final isAll = index == 0;
                    final categoryName = isAll ? 'All' : provider.categories[index - 1];
                    final isSelected = isAll
                        ? provider.selectedCategory == null
                        : provider.selectedCategory == categoryName;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(
                          categoryName.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : AppTheme.textSecondary,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppTheme.primary,
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: isSelected ? AppTheme.primary : Colors.grey.shade200,
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        showCheckmark: false,
                        onSelected: (selected) {
                          provider.selectCategory(isAll ? null : categoryName);
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // Main Product Grid listing
          Expanded(
            child: RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: () async {
                await context.read<ProductProvider>().fetchProducts(isRefresh: true);
              },
              child: Consumer<ProductProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && provider.products.isEmpty) {
                    return const ProductGridShimmer();
                  }

                  if (provider.errorMessage != null && provider.products.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            provider.errorMessage!,
                            style: const TextStyle(color: AppTheme.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            child: const Text('Try Again'),
                            onPressed: () => provider.fetchProducts(isRefresh: true),
                          ),
                        ],
                      ),
                    );
                  }

                  if (provider.products.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No products found matching filters.',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    controller: _scrollController,
                    cacheExtent: 600, // Optimize large list render boundaries
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.70,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: provider.products.length + (provider.isPaginationLoading ? 2 : 0),
                    itemBuilder: (context, index) {
                      if (index >= provider.products.length) {
                        return const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ShimmerBox(width: double.infinity, height: double.infinity, borderRadius: 16),
                            ),
                            SizedBox(height: 10),
                            ShimmerBox(width: 100, height: 16),
                          ],
                        );
                      }

                      final product = provider.products[index];
                      return ProductCard(product: product);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(productId: product.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade100, width: 1.5),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cached product image thumbnail
            Expanded(
              child: Stack(
                children: [
                  CustomImageView(
                    imageUrl: product.thumbnail,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  ),
                  
                  // Discount badge
                  if (product.hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '-${product.discountPercentage.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  
                  // Wishlist button overlay
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Consumer<CartProvider>(
                      builder: (context, provider, child) {
                        final isAdded = provider.wishlistProductIds.contains(product.id);
                        return GestureDetector(
                          onTap: () {
                            provider.toggleWishlist(product.id);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isAdded ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: isAdded ? AppTheme.accent : Colors.grey,
                              size: 18,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // Text Details details info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.category.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  
                  // Rating widget
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${product.rating}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Price Tag info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.hasDiscount)
                            Text(
                              '\$${product.originalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      
                      // Add to Cart quick button
                      GestureDetector(
                        onTap: () {
                          context.read<CartProvider>().addToCart(product, 1);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.title} added to cart.'),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                              action: SnackBarAction(
                                label: 'VIEW',
                                textColor: Colors.white,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const CartScreen()),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.add_shopping_cart_rounded,
                            size: 16,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
