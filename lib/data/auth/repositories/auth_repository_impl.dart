import 'package:injectable/injectable.dart';
import 'package:super_flutter/data/auth/mappers/auth_mappers.dart';
import 'package:super_flutter/data/auth/sources/local/auth_local_data_source.dart';
import 'package:super_flutter/data/auth/sources/remote/auth_remote_data_source.dart';
import 'package:super_flutter/domain/auth/entities/auth_session.dart';
import 'package:super_flutter/domain/auth/entities/user.dart';

import '../../../domain/auth/repositories/auth_repository.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource, this._localDataSource);

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

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
    await _localDataSource.saveTokens(result.toTokens());
    await _localDataSource.saveUser(result.user!);
    return result.toEntity();
  }

  @override
  Future<User?> getCachedUser() async {
    final model = await _localDataSource.getUser();
    return model?.toEntity();
  }

  @override
  Future<void> logout() async {
    await _localDataSource.clearSession();
  }
}
