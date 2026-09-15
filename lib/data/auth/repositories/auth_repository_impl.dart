import 'package:injectable/injectable.dart';
import 'package:starter/data/auth/sources/local/auth_local_data_source.dart';
import 'package:starter/data/auth/sources/remote/auth_remote_data_source.dart';
import 'package:starter/domain/auth/entities/user.dart';

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
  Future<User> login({required String email, required String password}) async {
    // The dummyjson backend treats the login identifier as `username`;
    // the domain interface keeps the generic `email` name.
    final result = await _remoteDataSource.login(
      username: email,
      password: password,
    );
    await _localDataSource.saveTokens(
      accessToken: result.tokens.accessToken,
      refreshToken: result.tokens.refreshToken,
    );
    return result.user.toEntity();
  }

  @override
  Future<void> logout() async {
    _localDataSource.clearSession();
  }
}
