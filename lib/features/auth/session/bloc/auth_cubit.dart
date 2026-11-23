import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../domain/auth/entities/user.dart';
import '../../../../domain/auth/use_cases/check_auth_status.dart';
import '../../../../domain/auth/use_cases/get_current_user.dart';
import '../../../../domain/auth/use_cases/refresh_user.dart';
import '../../../../domain/auth/use_cases/watch_auth_status.dart';
import 'auth_state.dart';

@lazySingleton
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(
    this._checkAuthStatus,
    this._getCurrentUser,
    WatchAuthStatus watchAuthStatus,
    this._refreshUser,
  ) : super(const AuthState()) {
    _statusSubscription = watchAuthStatus().listen(_apply);
  }

  final CheckAuthStatus _checkAuthStatus;
  final GetCurrentUser _getCurrentUser;
  final RefreshUser _refreshUser;
  late final StreamSubscription<AuthStatus> _statusSubscription;

  Future<void> initialize() async {
    try {
      final isAuthenticated = await _checkAuthStatus();
      await _apply(
        isAuthenticated ? AuthStatus.authenticated : AuthStatus.unauthenticated,
      );
    } catch (_) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
      return;
    }
    // The cached user opens the app at once; /me then brings its roles
    // and permissions up to date.
    if (state.isAuthenticated) unawaited(syncUser());
  }

  /// Loads the user from the server; offline, the cached one stays.
  Future<void> syncUser() async {
    try {
      await _refreshUser();
    } catch (_) {
      return;
    }
    if (!isClosed) await refreshUser();
  }

  /// Reloads the signed-in user, for example after `/me` refreshed it.
  Future<void> refreshUser() async {
    if (state.isAuthenticated) await _apply(AuthStatus.authenticated);
  }

  Future<void> _apply(AuthStatus status) async {
    if (status != AuthStatus.authenticated) {
      emit(AuthState(status: status));
      return;
    }
    User? user;
    try {
      user = await _getCurrentUser();
    } catch (_) {
      user = null;
    }
    if (isClosed) return;
    emit(AuthState(status: status, user: user));
  }

  @override
  Future<void> close() {
    _statusSubscription.cancel();
    return super.close();
  }
}
