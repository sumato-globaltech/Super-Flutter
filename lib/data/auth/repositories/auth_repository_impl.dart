import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/network/session_manager.dart';
import 'package:super_flutter/data/auth/mappers/auth_mappers.dart';
import 'package:super_flutter/data/auth/model/login_model.dart';
import 'package:super_flutter/data/auth/sources/local/auth_local_data_source.dart';
import 'package:super_flutter/data/auth/sources/remote/auth_remote_data_source.dart';
import 'package:super_flutter/domain/auth/entities/auth_session.dart';
import 'package:super_flutter/domain/auth/entities/auth_status.dart';
import 'package:super_flutter/domain/auth/entities/user.dart';

import '../../../domain/auth/repositories/auth_repository.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    SessionManager sessionManager,
  ) {
    _expiredSubscription = sessionManager.expired.listen(
      (_) => _status.add(AuthStatus.unauthenticated),
    );
  }

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final _status = StreamController<AuthStatus>.broadcast();
  late final StreamSubscription<void> _expiredSubscription;

  @override
  Stream<AuthStatus> get status => _status.stream;

  @override
  Future<bool> hasSession() async {
    return _localDataSource.hasSession;
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final result = await _remoteDataSource.login(
      email: email,
      password: password,
    );
    return _start(result);
  }

  @override
  Future<int> requestOtp({required String phone}) {
    return _remoteDataSource.requestOtp(phone: phone);
  }

  @override
  Future<AuthSession> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final result = await _remoteDataSource.verifyOtp(phone: phone, otp: otp);
    return _start(result);
  }

  Future<AuthSession> _start(LoginModel result) async {
    await _localDataSource.saveTokens(result.toTokens());
    await _localDataSource.saveUser(result.user!);
    _status.add(AuthStatus.authenticated);
    return result.toEntity();
  }

  @override
  Future<User?> getCachedUser() async {
    final model = await _localDataSource.getUser();
    return model?.toEntity();
  }

  @override
  Future<User> refreshUser() async {
    final model = await _remoteDataSource.getMe();
    await _localDataSource.saveUser(model);
    return model.toEntity();
  }

  @override
  Future<void> logout({bool allDevices = false}) async {
    try {
      if (_localDataSource.hasSession) {
        allDevices
            ? await _remoteDataSource.logoutAll()
            : await _remoteDataSource.logout();
      }
    } on Object {
      // Offline or already expired: the session still ends here.
    } finally {
      try {
        await _localDataSource.clearSession();
      } finally {
        _status.add(AuthStatus.unauthenticated);
      }
    }
  }

  Future<void> dispose() async {
    await _expiredSubscription.cancel();
    await _status.close();
  }
}
