import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../domain/auth/use_cases/check_auth_status.dart';
import 'auth_state.dart';

/// Single source of truth for session *status*, consumed by the app router.
///
/// Status-only: [initialize] resolves the current session once at startup,
/// [authenticated]/[unauthenticated] reflect status changes owned by other
/// operations (login, logout, session expiry). It performs no I/O itself
/// beyond [CheckAuthStatus].
@lazySingleton
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._checkAuthStatus) : super(const AuthState());

  final CheckAuthStatus _checkAuthStatus;

  Future<void> initialize() async {
    try {
      final isAuthenticated = await _checkAuthStatus();

      emit(
        AuthState(
          status: isAuthenticated
              ? AuthStatus.authenticated
              : AuthStatus.unauthenticated,
        ),
      );
    } catch (_) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  /// Reflects a completed sign-in. Called by [LoginBloc] on success.
  void authenticated() {
    emit(const AuthState(status: AuthStatus.authenticated));
  }

  /// Reflects a completed sign-out or expired session. Called by
  /// [DashboardBloc] and [SessionManager] — never performs I/O itself.
  void unauthenticated() {
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
