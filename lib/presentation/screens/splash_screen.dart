import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_theme.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'product_list_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late AuthProvider _authProvider;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();

    _authProvider = context.read<AuthProvider>();
    _authProvider.addListener(_authListener);

    // Trigger auth state check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authProvider.checkSession();
    });
  }

  @override
  void dispose() {
    _authProvider.removeListener(_authListener);
    _animationController.dispose();
    super.dispose();
  }

  void _authListener() {
    if (!_authProvider.isLoading && !_navigated) {
      _navigated = true;
      final navigator = Navigator.of(context);
      
      // Ensure splash displays for at least 2.0 seconds for a premium brand feel
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (!mounted) return;
        if (_authProvider.isAuthenticated) {
          navigator.pushReplacement(
            MaterialPageRoute(builder: (_) => const ProductListScreen()),
          );
        } else {
          navigator.pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          size: 72,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'AURA SHOP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Elevate Your Shopping Experience',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
