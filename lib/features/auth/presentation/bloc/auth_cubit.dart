import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../domain/auth/use_cases/check_auth_status.dart';
import '../../../../domain/auth/use_cases/logout.dart';
import 'auth_state.dart';

@lazySingleton
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._checkAuthStatus, this._logout) : super(const AuthState());

  final CheckAuthStatus _checkAuthStatus;
  final Logout _logout;

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

  Future<void> logout() async {
    try {
      await _logout();
    } finally {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  void authenticated() {
    emit(const AuthState(status: AuthStatus.authenticated));
  }

  void unauthenticated() {
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
