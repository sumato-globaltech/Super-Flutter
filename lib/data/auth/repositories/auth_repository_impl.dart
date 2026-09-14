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
  Future<User> login({required String email, required String password}) {
    // TODO: implement login
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {
    _localDataSource.clearSession();
  }
}
