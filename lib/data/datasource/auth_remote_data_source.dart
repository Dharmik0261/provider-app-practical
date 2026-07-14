import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String username, String password);
  Future<UserModel> getProfile();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl(this.dioClient);

  @override
  Future<UserModel> login(String username, String password) async {
    final response = await dioClient.post(
      ApiConstants.login,
      data: {
        'username': username,
        'password': password,
      },
    );
    return UserModel.fromJson(response.data);
  }

  @override
  Future<UserModel> getProfile() async {
    final response = await dioClient.get(ApiConstants.profile);
    return UserModel.fromJson(response.data);
  }
}
