import '../entities/user.dart';

abstract interface class AuthRepository {
  Future<bool> hasSession();

  Future<User> login({required String email, required String password});

  Future<void> logout();
}
