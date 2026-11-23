import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/core/network/session_manager.dart';
import 'package:super_flutter/data/auth/model/login_model.dart';
import 'package:super_flutter/data/auth/model/user_model.dart';
import 'package:super_flutter/data/auth/repositories/auth_repository_impl.dart';
import 'package:super_flutter/data/auth/sources/local/auth_local_data_source.dart';
import 'package:super_flutter/data/auth/sources/remote/auth_remote_data_source.dart';
import 'package:super_flutter/domain/auth/entities/auth_status.dart';
import 'package:super_flutter/domain/auth/entities/auth_token.dart';

class MockRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockSessionManager extends Mock implements SessionManager {}

void main() {
  late MockRemoteDataSource remote;
  late MockLocalDataSource local;
  late MockSessionManager sessionManager;
  late StreamController<void> expired;
  late StreamController<void> passwordRequired;
  late AuthRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(const AuthTokens(accessToken: ''));
    registerFallbackValue(UserModel());
  });

  setUp(() {
    remote = MockRemoteDataSource();
    local = MockLocalDataSource();
    sessionManager = MockSessionManager();
    expired = StreamController<void>.broadcast();
    passwordRequired = StreamController<void>.broadcast();
    when(() => sessionManager.expired).thenAnswer((_) => expired.stream);
    when(() => sessionManager.passwordChangeRequired)
        .thenAnswer((_) => passwordRequired.stream);
    repository = AuthRepositoryImpl(remote, local, sessionManager);
  });

  tearDown(() async {
    await repository.dispose();
    await expired.close();
    await passwordRequired.close();
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

    final statuses = expectLater(
      repository.status,
      emits(AuthStatus.authenticated),
    );

    final session = await repository.login(
      email: 'emily@test.com',
      password: 'secret',
    );

    expect(session.user.email, 'emily@test.com');
    expect(session.tokens.accessToken, 'a');
    verify(() => remote.login(email: 'emily@test.com', password: 'secret'))
        .called(1);
    verify(() => local.saveTokens(const AuthTokens(accessToken: 'a')))
        .called(1);
    verify(() => local.saveUser(response.user!)).called(1);
    await statuses;
  });

  test('verifyOtp starts the session like login', () async {
    final response = LoginModel(
      accessToken: 'b',
      passwordChangeRequired: true,
      user: UserModel(id: 'u2', name: 'Ramesh', email: '', phone: '9876543210'),
    );
    when(
      () => remote.verifyOtp(
        phone: any(named: 'phone'),
        otp: any(named: 'otp'),
      ),
    ).thenAnswer((_) async => response);
    when(() => local.saveTokens(any())).thenAnswer((_) async {});
    when(() => local.saveUser(any())).thenAnswer((_) async {});
    final statuses = expectLater(
      repository.status,
      emits(AuthStatus.authenticated),
    );

    final session = await repository.verifyOtp(
      phone: '9876543210',
      otp: '123456',
    );

    expect(session.user.phone, '9876543210');
    expect(session.passwordChangeRequired, isTrue);
    verify(() => local.saveTokens(const AuthTokens(accessToken: 'b')))
        .called(1);
    verify(() => local.saveUser(response.user!)).called(1);
    await statuses;
  });

  test('requestOtp returns how long the code is valid', () async {
    when(() => remote.requestOtp(phone: any(named: 'phone')))
        .thenAnswer((_) async => 300);

    expect(await repository.requestOtp(phone: '9876543210'), 300);
  });

  test('refreshUser loads /me and caches it', () async {
    final me = UserModel(
      id: 'u1',
      name: 'Emily',
      email: 'emily@test.com',
      permissions: ['markets.view'],
    );
    when(() => remote.getMe()).thenAnswer((_) async => me);
    when(() => local.saveUser(any())).thenAnswer((_) async {});

    final user = await repository.refreshUser();

    expect(user.permissions, {'markets.view'});
    verify(() => local.saveUser(me)).called(1);
  });

  group('logout', () {
    setUp(() {
      when(() => local.clearSession()).thenAnswer((_) async {});
      when(() => local.hasSession).thenReturn(true);
    });

    test('ends the session on the server, then here', () async {
      when(() => remote.logout()).thenAnswer((_) async => true);
      final statuses = expectLater(
        repository.status,
        emits(AuthStatus.unauthenticated),
      );

      await repository.logout();
      await statuses;

      verify(() => remote.logout()).called(1);
      verifyNever(() => remote.logoutAll());
      verify(() => local.clearSession()).called(1);
    });

    test('on every device', () async {
      when(() => remote.logoutAll()).thenAnswer((_) async => true);

      await repository.logout(allDevices: true);

      verify(() => remote.logoutAll()).called(1);
      verifyNever(() => remote.logout());
      verify(() => local.clearSession()).called(1);
    });

    test('offline still ends the session here', () async {
      when(() => remote.logout()).thenThrow(Exception('offline'));
      final statuses = expectLater(
        repository.status,
        emits(AuthStatus.unauthenticated),
      );

      await repository.logout();
      await statuses;

      verify(() => local.clearSession()).called(1);
    });

    test('without a session nothing is sent', () async {
      when(() => local.hasSession).thenReturn(false);

      await repository.logout();

      verifyNever(() => remote.logout());
      verify(() => local.clearSession()).called(1);
    });
  });

  test('session expiry is reported as unauthenticated', () async {
    final statuses = expectLater(
      repository.status,
      emits(AuthStatus.unauthenticated),
    );

    expired.add(null);

    await statuses;
  });

  group('password change', () {
    test('a refused request marks the cached user and re-announces', () async {
      final cached = UserModel(id: 'u1', name: 'Emily', email: 'e@test.com');
      when(() => local.getUser()).thenAnswer((_) async => cached);
      when(() => local.saveUser(any())).thenAnswer((_) async {});
      final statuses = expectLater(
        repository.status,
        emits(AuthStatus.authenticated),
      );

      passwordRequired.add(null);
      await statuses;

      expect(cached.passwordChangeRequired, isTrue);
      verify(() => local.saveUser(cached)).called(1);
    });

    test('a second refusal changes nothing', () async {
      final cached = UserModel(id: 'u1', passwordChangeRequired: true);
      when(() => local.getUser()).thenAnswer((_) async => cached);

      passwordRequired.add(null);
      await Future<void>.delayed(Duration.zero);

      verifyNever(() => local.saveUser(any()));
    });

    test('once changed, /me is loaded again', () async {
      final me = UserModel(id: 'u1', passwordChangeRequired: false);
      when(() => remote.getMe()).thenAnswer((_) async => me);
      when(() => local.saveUser(any())).thenAnswer((_) async {});
      final statuses = expectLater(
        repository.status,
        emits(AuthStatus.authenticated),
      );

      await repository.passwordChanged();
      await statuses;

      verify(() => local.saveUser(me)).called(1);
    });

    test('once changed but offline, the cached user is let go', () async {
      final cached = UserModel(id: 'u1', passwordChangeRequired: true);
      when(() => remote.getMe()).thenThrow(Exception('offline'));
      when(() => local.getUser()).thenAnswer((_) async => cached);
      when(() => local.saveUser(any())).thenAnswer((_) async {});

      await repository.passwordChanged();

      expect(cached.passwordChangeRequired, isFalse);
      verify(() => local.saveUser(cached)).called(1);
    });
  });
}
