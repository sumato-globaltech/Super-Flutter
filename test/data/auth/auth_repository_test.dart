import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/core/network/dio_client.dart';
import 'package:super_flutter/data/auth/model/user_model.dart';
import 'package:super_flutter/data/auth/repositories/auth_repository_impl.dart';
import 'package:super_flutter/data/auth/sources/local/auth_local_data_source.dart';
import 'package:super_flutter/data/auth/sources/remote/auth_remote_data_source.dart';
import 'package:super_flutter/domain/auth/entities/auth_token.dart';

class MockRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockDioClient extends Mock implements DioClient {}

void main() {
  late MockRemoteDataSource remote;
  late MockLocalDataSource local;
  late AuthRepositoryImpl repository;

  setUp(() {
    remote = MockRemoteDataSource();
    local = MockLocalDataSource();
    repository = AuthRepositoryImpl(remote, local);
  });

  test('hasSession delegates to local data source', () async {
    when(() => local.hasSession).thenReturn(true);

    expect(await repository.hasSession(), true);
    verify(() => local.hasSession).called(1);
  });

  test('login persists tokens and returns user entity', () async {
    const model = UserModel(
      id: 1,
      username: 'emilys',
      email: 'emily@test.com',
    );
    const tokens = AuthTokens(accessToken: 'a', refreshToken: 'r');
    when(
      () => remote.login(username: any(named: 'username'), password: any(named: 'password')),
    ).thenAnswer((_) async => const LoginResult(user: model, tokens: tokens));
    when(
      () => local.saveTokens(accessToken: any(named: 'accessToken'), refreshToken: any(named: 'refreshToken')),
    ).thenAnswer((_) async {});

    final user = await repository.login(email: 'emilys', password: 'emilyspass');

    expect(user.username, 'emilys');
    verify(() => remote.login(username: 'emilys', password: 'emilyspass')).called(1);
    verify(() => local.saveTokens(accessToken: 'a', refreshToken: 'r')).called(1);
  });

  test('logout clears local session', () async {
    when(() => local.clearSession()).thenAnswer((_) async {});

    await repository.logout();

    verify(() => local.clearSession()).called(1);
  });
}
