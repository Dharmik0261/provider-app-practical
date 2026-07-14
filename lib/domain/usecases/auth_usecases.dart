import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<User> execute(String username, String password) {
    return repository.login(username, password);
  }
}

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<void> execute() {
    return repository.logout();
  }
}

class CheckAutoLoginUseCase {
  final AuthRepository repository;

  CheckAutoLoginUseCase(this.repository);

  Future<User?> execute() {
    return repository.checkAutoLogin();
  }
}
