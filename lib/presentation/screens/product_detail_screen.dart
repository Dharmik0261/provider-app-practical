import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_theme.dart';
import '../../domain/entities/product.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/custom_image_view.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  int _quantity = 1;
  
  Product? _product;
  List<Product> _similarProducts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProductDetails();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadProductDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final productProvider = context.read<ProductProvider>();
      final fetchedProduct = await productProvider.getDetails(widget.productId);
      
      if (fetchedProduct != null) {
        // Fetch similar products in same category
        final similar = await productProvider.getProductsByCategoryUseCase.execute(
          fetchedProduct.category,
          limit: 6,
          skip: 0,
        );

        if (mounted) {
          setState(() {
            _product = fetchedProduct;
            _similarProducts = similar.where((p) => p.id != widget.productId).toList();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Could not load product specifications.';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Network error fetching details.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    if (_errorMessage != null || _product == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 64, color: AppTheme.error),
              const SizedBox(height: 16),
              Text(_errorMessage ?? 'An error occurred', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _loadProductDetails,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    final product = _product!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppTheme.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          // Wishlist Action overlay
          Consumer<CartProvider>(
            builder: (context, provider, child) {
              final isLiked = provider.wishlistProductIds.contains(product.id);
              return Container(
                margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isLiked ? AppTheme.accent : AppTheme.textPrimary,
                    size: 20,
                  ),
                  onPressed: () {
                    provider.toggleWishlist(product.id);
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Carousel Image Header
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: product.images.isNotEmpty ? product.images.length : 1,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final imageUrl = product.images.isNotEmpty ? product.images[index] : product.thumbnail;
                      return CustomImageView(
                        imageUrl: imageUrl,
                        fit: BoxFit.contain,
                        width: double.infinity,
                      );
                    },
                  ),
                ),
                // Indicator dots
                if (product.images.length > 1)
                  Positioned(
                    bottom: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          product.images.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == index
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Product Details card
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.category.toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      // Stock status tag
                      if (product.stock > 0)
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(color: AppTheme.success, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'In Stock (${product.stock})',
                              style: const TextStyle(color: AppTheme.success, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      else
                        const Text(
                          'Out of Stock',
                          style: TextStyle(color: AppTheme.error, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Product Name
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (product.brand != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Brand: ${product.brand}',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                    ),
                  ],
                  const SizedBox(height: 12),

                  // Rating Block
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '${product.rating}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Verified Reviews',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  const Divider(),
                  const SizedBox(height: 12),

                  // Price tags
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (product.hasDiscount) ...[
                        const SizedBox(width: 12),
                        Text(
                          '\$${product.originalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.textSecondary,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Save ${product.discountPercentage.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: AppTheme.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Product Description
                  const Text(
                    'About this Product',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Similar Products Horizontal Section
                  if (_similarProducts.isNotEmpty) ...[
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text(
                      'Similar Products',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _similarProducts.length,
                        itemBuilder: (context, index) {
                          final simProduct = _similarProducts[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailScreen(productId: simProduct.id),
                                ),
                              );
                            },
                            child: Container(
                              width: 120,
                              margin: const EdgeInsets.only(right: 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: CustomImageView(
                                      imageUrl: simProduct.thumbnail,
                                      borderRadius: BorderRadius.circular(12),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    simProduct.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '\$${simProduct.price.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      
      // Bottom persistent Add to Cart Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Quantity adjust button selector
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18),
                      onPressed: () {
                        if (_quantity > 1) {
                          setState(() {
                            _quantity--;
                          });
                        }
                      },
                    ),
                    Text(
                      '$_quantity',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: () {
                        setState(() {
                          _quantity++;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              
              // Add to Cart Button
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.read<CartProvider>().addToCart(product, _quantity);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added $_quantity ${product.title} to cart.'),
                        behavior: SnackBarBehavior.floating,
                        action: SnackBarAction(
                          label: 'VIEW CART',
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'ADD TO CART',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
