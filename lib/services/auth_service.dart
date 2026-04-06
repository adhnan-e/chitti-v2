import 'package:chitt/core/di/service_locator.dart';
import 'package:chitt/core/domain/repositories/i_auth_repository.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  IAuthRepository get _repo => getIt<IAuthRepository>();

  Map<String, dynamic>? get currentUser => _repo.currentUser;

  Future<String?> checkSession() => _repo.checkSession();

  Future<String?> login(String username, String password) =>
      _repo.login(username, password);

  Future<void> logout() => _repo.logout();
}
