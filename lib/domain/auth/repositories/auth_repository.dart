import '../entities/auth_session.dart';
import '../entities/auth_status.dart';
import '../entities/user.dart';

abstract interface class AuthRepository {
  Stream<AuthStatus> get status;

  Future<bool> hasSession();

  Future<AuthSession> login({required String email, required String password});

  Future<User?> getCachedUser();

  Future<void> logout();
}
