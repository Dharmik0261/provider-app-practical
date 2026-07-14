import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_theme.dart';
import 'core/network/dio_client.dart';
import 'data/datasource/auth_local_data_source.dart';
import 'data/datasource/auth_remote_data_source.dart';
import 'data/datasource/cart_local_data_source.dart';
import 'data/datasource/product_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/cart_repository_impl.dart';
import 'data/repositories/product_repository_impl.dart';
import 'domain/usecases/auth_usecases.dart';
import 'domain/usecases/cart_usecases.dart';
import 'domain/usecases/product_usecases.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/cart_provider.dart';
import 'presentation/providers/product_provider.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();

  // Core network client
  final dioClient = DioClient(sharedPreferences);

  // Data sources
  final authRemoteDataSource = AuthRemoteDataSourceImpl(dioClient);
  final authLocalDataSource = AuthLocalDataSourceImpl(sharedPreferences);
  final productRemoteDataSource = ProductRemoteDataSourceImpl(dioClient);
  final cartLocalDataSource = CartLocalDataSourceImpl(sharedPreferences);

  // Repositories
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
    localDataSource: authLocalDataSource,
  );
  final productRepository = ProductRepositoryImpl(
    remoteDataSource: productRemoteDataSource,
  );
  final cartRepository = CartRepositoryImpl(
    localDataSource: cartLocalDataSource,
  );

  // Use cases
  final loginUseCase = LoginUseCase(authRepository);
  final logoutUseCase = LogoutUseCase(authRepository);
  final checkAutoLoginUseCase = CheckAutoLoginUseCase(authRepository);

  final getProductsUseCase = GetProductsUseCase(productRepository);
  final searchProductsUseCase = SearchProductsUseCase(productRepository);
  final getCategoriesUseCase = GetCategoriesUseCase(productRepository);
  final getProductsByCategoryUseCase = GetProductsByCategoryUseCase(
    productRepository,
  );
  final getProductDetailsUseCase = GetProductDetailsUseCase(productRepository);

  final getCartUseCase = GetCartUseCase(cartRepository);
  final addToCartUseCase = AddToCartUseCase(cartRepository);
  final removeFromCartUseCase = RemoveFromCartUseCase(cartRepository);
  final updateCartQuantityUseCase = UpdateCartQuantityUseCase(cartRepository);
  final clearCartUseCase = ClearCartUseCase(cartRepository);

  runApp(
    MyApp(
      dioClient: dioClient,
      sharedPreferences: sharedPreferences,
      loginUseCase: loginUseCase,
      logoutUseCase: logoutUseCase,
      checkAutoLoginUseCase: checkAutoLoginUseCase,
      getProductsUseCase: getProductsUseCase,
      searchProductsUseCase: searchProductsUseCase,
      getCategoriesUseCase: getCategoriesUseCase,
      getProductsByCategoryUseCase: getProductsByCategoryUseCase,
      getProductDetailsUseCase: getProductDetailsUseCase,
      getCartUseCase: getCartUseCase,
      addToCartUseCase: addToCartUseCase,
      removeFromCartUseCase: removeFromCartUseCase,
      updateCartQuantityUseCase: updateCartQuantityUseCase,
      clearCartUseCase: clearCartUseCase,
    ),
  );
}

class MyApp extends StatelessWidget {
  final DioClient dioClient;
  final SharedPreferences sharedPreferences;

  // Auth use cases
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final CheckAutoLoginUseCase checkAutoLoginUseCase;

  // Product use cases
  final GetProductsUseCase getProductsUseCase;
  final SearchProductsUseCase searchProductsUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetProductsByCategoryUseCase getProductsByCategoryUseCase;
  final GetProductDetailsUseCase getProductDetailsUseCase;

  // Cart use cases
  final GetCartUseCase getCartUseCase;
  final AddToCartUseCase addToCartUseCase;
  final RemoveFromCartUseCase removeFromCartUseCase;
  final UpdateCartQuantityUseCase updateCartQuantityUseCase;
  final ClearCartUseCase clearCartUseCase;

  const MyApp({
    super.key,
    required this.dioClient,
    required this.sharedPreferences,
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.checkAutoLoginUseCase,
    required this.getProductsUseCase,
    required this.searchProductsUseCase,
    required this.getCategoriesUseCase,
    required this.getProductsByCategoryUseCase,
    required this.getProductDetailsUseCase,
    required this.getCartUseCase,
    required this.addToCartUseCase,
    required this.removeFromCartUseCase,
    required this.updateCartQuantityUseCase,
    required this.clearCartUseCase,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(
            loginUseCase: loginUseCase,
            logoutUseCase: logoutUseCase,
            checkAutoLoginUseCase: checkAutoLoginUseCase,
            dioClient: dioClient,
          ),
        ),
        ChangeNotifierProvider<ProductProvider>(
          create: (_) => ProductProvider(
            getProductsUseCase: getProductsUseCase,
            searchProductsUseCase: searchProductsUseCase,
            getCategoriesUseCase: getCategoriesUseCase,
            getProductsByCategoryUseCase: getProductsByCategoryUseCase,
            getProductDetailsUseCase: getProductDetailsUseCase,
          ),
        ),
        ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider(
            getCartUseCase: getCartUseCase,
            addToCartUseCase: addToCartUseCase,
            removeFromCartUseCase: removeFromCartUseCase,
            updateCartQuantityUseCase: updateCartQuantityUseCase,
            clearCartUseCase: clearCartUseCase,
            sharedPreferences: sharedPreferences,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Aura E-Commerce',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
