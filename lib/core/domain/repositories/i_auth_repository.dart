abstract class IAuthRepository {
  Future<String?> checkSession();
  Future<String?> login(String username, String password);
  Future<void> logout();
  Map<String, dynamic>? get currentUser;
}
