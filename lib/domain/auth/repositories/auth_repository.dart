import '../entities/auth_session.dart';
import '../entities/auth_status.dart';
import '../entities/user.dart';

abstract interface class AuthRepository {
  Stream<AuthStatus> get status;

  Future<bool> hasSession();

  Future<AuthSession> login({required String email, required String password});

  /// Sends a code to the phone; returns the seconds it stays valid.
  Future<int> requestOtp({required String phone});

  Future<AuthSession> verifyOtp({required String phone, required String otp});

  Future<User?> getCachedUser();

  /// Loads the signed-in user from `/me` and caches it.
  Future<User> refreshUser();

  /// The password was changed: reloads the user, who may now continue.
  Future<void> passwordChanged();

  /// Ends the session here, or on every device with [allDevices]. The local
  /// session is cleared even when the server cannot be reached.
  Future<void> logout({bool allDevices = false});
}
