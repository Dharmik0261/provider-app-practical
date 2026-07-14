import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/auth_local_data_source.dart';
import '../datasource/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<User> login(String username, String password) async {
    final userModel = await remoteDataSource.login(username, password);
    await localDataSource.cacheToken(userModel.token);
    await localDataSource.cacheUser(userModel);
    return userModel;
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearSession();
  }

  @override
  Future<User?> checkAutoLogin() async {
    final cachedToken = await localDataSource.getCachedToken();
    if (cachedToken != null && cachedToken.isNotEmpty) {
      try {
        // Try fetching user profile from network to confirm session is still valid
        final userModel = await remoteDataSource.getProfile();
        
        // Since /auth/me doesn't return the token, keep the cached token in the model
        final updatedUserModel = UserModel(
          id: userModel.id,
          username: userModel.username,
          email: userModel.email,
          firstName: userModel.firstName,
          lastName: userModel.lastName,
          gender: userModel.gender,
          image: userModel.image,
          token: cachedToken,
        );
        await localDataSource.cacheUser(updatedUserModel);
        return updatedUserModel;
      } catch (_) {
        // If network profile fetch fails (e.g. offline), we fall back to the cached user details
        final localUser = await localDataSource.getCachedUser();
        return localUser;
      }
    }
    return null;
  }
}
