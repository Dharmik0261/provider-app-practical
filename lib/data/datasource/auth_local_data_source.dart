import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../../core/errors/exceptions.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheToken(String token);
  Future<String?> getCachedToken();
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl(this.sharedPreferences);

  static const String _tokenKey = 'jwt_token';
  static const String _userKey = 'user_data';

  @override
  Future<void> cacheToken(String token) async {
    try {
      await sharedPreferences.setString(_tokenKey, token);
    } catch (e) {
      throw CacheException(message: 'Failed to save login token');
    }
  }

  @override
  Future<String?> getCachedToken() async {
    return sharedPreferences.getString(_tokenKey);
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await sharedPreferences.setString(_userKey, userJson);
    } catch (e) {
      throw CacheException(message: 'Failed to cache user profile');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final userJson = sharedPreferences.getString(_userKey);
    if (userJson != null) {
      try {
        final decoded = jsonDecode(userJson) as Map<String, dynamic>;
        return UserModel.fromJson(decoded);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> clearSession() async {
    try {
      await sharedPreferences.remove(_tokenKey);
      await sharedPreferences.remove(_userKey);
    } catch (e) {
      throw CacheException(message: 'Failed to clear local session');
    }
  }
}
