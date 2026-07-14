import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth_usecases.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final CheckAutoLoginUseCase checkAutoLoginUseCase;
  final DioClient dioClient;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _authExpiredSubscription;

  AuthProvider({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.checkAutoLoginUseCase,
    required this.dioClient,
  }) {
    // Listen to token expiry stream from Dio client
    _authExpiredSubscription = dioClient.authExpiredStream.listen((_) {
      _user = null;
      _errorMessage = 'Session expired. Please log in again.';
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  Future<void> checkSession() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final sessionUser = await checkAutoLoginUseCase.execute();
      _user = sessionUser;
    } catch (_) {
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await loginUseCase.execute(username, password);
    } on ServerException catch (e) {
      _errorMessage = e.message;
    } on NetworkException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'An unexpected login error occurred.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await logoutUseCase.execute();
      _user = null;
    } catch (e) {
      _errorMessage = 'Failed to log out safely.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authExpiredSubscription?.cancel();
    super.dispose();
  }
}
