import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/data/auth/model/login_model.dart';
import 'package:super_flutter/data/auth/model/user_model.dart';
import 'package:super_flutter/data/auth/repositories/auth_repository_impl.dart';
import 'package:super_flutter/data/auth/sources/local/auth_local_data_source.dart';
import 'package:super_flutter/data/auth/sources/remote/auth_remote_data_source.dart';
import 'package:super_flutter/domain/auth/entities/auth_token.dart';

class MockRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  late MockRemoteDataSource remote;
  late MockLocalDataSource local;
  late AuthRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(const AuthTokens(accessToken: ''));
    registerFallbackValue(UserModel());
  });

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

  test('parses login response from API json', () {
    final model = LoginModel.fromJson({
      'token_type': 'Bearer',
      'access_token': '4|abc',
      'expires_at': '2026-12-14T13:03:59+05:30',
      'password_change_required': false,
      'user': {
        'id': '01m6k41mv7h46g9hq3t0by14ae',
        'name': 'Deepjyoti Baishya',
        'email': 'd@test.com',
        'phone': '8811899999',
        'designation': null,
        'role': {'value': 'farmer', 'label': 'Farmer'},
        'photo_url': 'data:image/svg+xml;base64,AAA',
        'email_verified': false,
        'password_change_required': false,
        'created_at': '2026-11-04T16:40:28+05:30',
      },
    });

    expect(model.accessToken, '4|abc');
    expect(model.expiresAt, DateTime.parse('2026-12-14T13:03:59+05:30'));
    expect(model.user?.role?.label, 'Farmer');
    expect(model.user?.designation, isNull);
  });

  test('login persists token + user and returns session', () async {
    final response = LoginModel(
      tokenType: 'Bearer',
      accessToken: 'a',
      user: UserModel(id: 'u1', name: 'Emily', email: 'emily@test.com'),
    );
    when(
      () => remote.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => response);
    when(() => local.saveTokens(any())).thenAnswer((_) async {});
    when(() => local.saveUser(any())).thenAnswer((_) async {});

    final session = await repository.login(
      email: 'emily@test.com',
      password: 'secret',
    );

    expect(session.user.email, 'emily@test.com');
    expect(session.tokens.accessToken, 'a');
    verify(
      () => remote.login(email: 'emily@test.com', password: 'secret'),
    ).called(1);
    verify(() => local.saveTokens(const AuthTokens(accessToken: 'a'))).called(1);
    verify(() => local.saveUser(response.user!)).called(1);
  });

  test('logout clears local session', () async {
    when(() => local.clearSession()).thenAnswer((_) async {});

    await repository.logout();

    verify(() => local.clearSession()).called(1);
  });
}
