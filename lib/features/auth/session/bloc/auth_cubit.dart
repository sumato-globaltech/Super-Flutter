import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../domain/auth/use_cases/check_auth_status.dart';
import '../../../../domain/auth/use_cases/watch_auth_status.dart';
import 'auth_state.dart';

@lazySingleton
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._checkAuthStatus, WatchAuthStatus watchAuthStatus)
    : super(const AuthState()) {
    _statusSubscription = watchAuthStatus().listen(
      (status) => emit(AuthState(status: status)),
    );
  }

  final CheckAuthStatus _checkAuthStatus;
  late final StreamSubscription<AuthStatus> _statusSubscription;

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

  @override
  Future<void> close() {
    _statusSubscription.cancel();
    return super.close();
  }
}
