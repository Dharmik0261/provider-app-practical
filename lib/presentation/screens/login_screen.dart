import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_theme.dart';
import '../providers/auth_provider.dart';
import 'product_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: 'emilys');
  final _passwordController = TextEditingController(text: 'emilyspass');
  bool _obscurePassword = true;
  late AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = context.read<AuthProvider>();
    _authProvider.addListener(_authListener);
  }

  @override
  void dispose() {
    _authProvider.removeListener(_authListener);
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _authListener() {
    if (!mounted) return;
    if (_authProvider.isAuthenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ProductListScreen()),
      );
    } else if (_authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_authProvider.errorMessage!),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      _authProvider.clearError(); // Reset error message to prevent loop
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _authProvider.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, provider, child) {
          final isLoading = provider.isLoading;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium Visual Header Gradient
                Container(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.lock_outline_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Welcome Back',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign in to explore custom curated products.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 10),
                        // Username Field
                        Text(
                          'Username',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _usernameController,
                          enabled: !isLoading,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person_outline_rounded),
                            hintText: 'Enter your username',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Username is required';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),
                        // Password Field
                        Text(
                          'Password',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          enabled: !isLoading,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.key_outlined),
                            hintText: 'Enter your password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppTheme.textSecondary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 36),
                        // Submit Button
                        ElevatedButton(
                          onPressed: isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            backgroundColor: AppTheme.primary,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'SIGN IN',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                        ),

                        const SizedBox(height: 24),
                        // Assessment note block
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: AppTheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Test Credentials auto-filled for your convenience (DummyJSON standard user).',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
