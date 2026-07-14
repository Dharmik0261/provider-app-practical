import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/product_usecases.dart';

class ProductProvider extends ChangeNotifier {
  final GetProductsUseCase getProductsUseCase;
  final SearchProductsUseCase searchProductsUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetProductsByCategoryUseCase getProductsByCategoryUseCase;
  final GetProductDetailsUseCase getProductDetailsUseCase;

  List<Product> _products = [];
  List<String> _categories = [];
  String? _selectedCategory;
  String _searchQuery = '';
  String _sortBy = '';
  String _sortOrder = 'asc';
  bool _hasReachedMax = false;
  bool _isLoading = false;
  bool _isPaginationLoading = false;
  String? _errorMessage;
  int _skip = 0;

  static const int _limit = 10;

  ProductProvider({
    required this.getProductsUseCase,
    required this.searchProductsUseCase,
    required this.getCategoriesUseCase,
    required this.getProductsByCategoryUseCase,
    required this.getProductDetailsUseCase,
  });

  // Getters
  List<Product> get products => _products;
  List<String> get categories => _categories;
  String? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  String get sortOrder => _sortOrder;
  bool get hasReachedMax => _hasReachedMax;
  bool get isLoading => _isLoading;
  bool get isPaginationLoading => _isPaginationLoading;
  String? get errorMessage => _errorMessage;
  int get skip => _skip;

  Future<void> fetchCategories() async {
    try {
      _categories = await getCategoriesUseCase.execute();
      notifyListeners();
    } catch (_) {
      // Non-fatal, category bar will just display empty or default
    }
  }

  Future<void> fetchProducts({bool isRefresh = false}) async {
    if (_isLoading || _isPaginationLoading) return;
    if (!isRefresh && _hasReachedMax) return;

    final bool isInitial = isRefresh || _products.isEmpty;
    final int nextSkip = isRefresh ? 0 : _skip;

    if (isInitial) {
      _isLoading = true;
      _products = [];
      _skip = 0;
      _hasReachedMax = false;
      _errorMessage = null;
      notifyListeners();
    } else {
      _isPaginationLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      List<Product> newProducts = [];

      // Check filters to route to correct API call
      if (_selectedCategory != null) {
        newProducts = await getProductsByCategoryUseCase.execute(
          _selectedCategory!,
          limit: _limit,
          skip: nextSkip,
        );
      } else if (_searchQuery.isNotEmpty) {
        newProducts = await searchProductsUseCase.execute(
          _searchQuery,
          limit: _limit,
          skip: nextSkip,
        );
      } else {
        newProducts = await getProductsUseCase.execute(
          limit: _limit,
          skip: nextSkip,
          sortBy: _sortBy.isNotEmpty ? _sortBy : null,
          order: _sortBy.isNotEmpty ? _sortOrder : null,
        );
      }

      // Client-side sorting for category/search where DummyJSON lacks support
      if (_sortBy.isNotEmpty && (_selectedCategory != null || _searchQuery.isNotEmpty)) {
        _sortProducts(newProducts);
      }

      _products = isRefresh ? newProducts : [..._products, ...newProducts];
      _hasReachedMax = newProducts.length < _limit;
      _skip = nextSkip + newProducts.length;
    } catch (e) {
      _errorMessage = 'Failed to load products. Check your connection.';
    } finally {
      _isLoading = false;
      _isPaginationLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(String? category) {
    if (_selectedCategory == category) return;
    
    _selectedCategory = category;
    _searchQuery = ''; // Category filter resets search
    fetchProducts(isRefresh: true);
  }

  void search(String query) {
    if (_searchQuery == query) return;

    _searchQuery = query;
    _selectedCategory = null; // Search resets category selection
    fetchProducts(isRefresh: true);
  }

  void setSort(String field, String order) {
    _sortBy = field;
    _sortOrder = order;
    fetchProducts(isRefresh: true);
  }

  void _sortProducts(List<Product> list) {
    if (_sortBy == 'price') {
      if (_sortOrder == 'asc') {
        list.sort((a, b) => a.price.compareTo(b.price));
      } else {
        list.sort((a, b) => b.price.compareTo(a.price));
      }
    } else if (_sortBy == 'title') {
      if (_sortOrder == 'asc') {
        list.sort((a, b) => a.title.compareTo(b.title));
      } else {
        list.sort((a, b) => b.title.compareTo(a.title));
      }
    }
  }

  Future<Product?> getDetails(int id) async {
    try {
      return await getProductDetailsUseCase.execute(id);
    } catch (_) {
      return null;
    }
  }
}
