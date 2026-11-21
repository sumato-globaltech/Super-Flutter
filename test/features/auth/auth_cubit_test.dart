import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/domain/auth/entities/access_policy.dart';
import 'package:super_flutter/domain/auth/entities/user.dart';
import 'package:super_flutter/domain/auth/use_cases/check_auth_status.dart';
import 'package:super_flutter/domain/auth/use_cases/get_current_user.dart';
import 'package:super_flutter/domain/auth/use_cases/watch_auth_status.dart';
import 'package:super_flutter/features/auth/session/bloc/auth_cubit.dart';
import 'package:super_flutter/features/auth/session/bloc/auth_state.dart';

class MockCheckAuthStatus extends Mock implements CheckAuthStatus {}

class MockGetCurrentUser extends Mock implements GetCurrentUser {}

class MockWatchAuthStatus extends Mock implements WatchAuthStatus {}

const _farmer = User(
  id: '1',
  name: 'Farmer',
  email: 'farmer@example.test',
  role: UserRole(value: Roles.farmer, label: 'Farmer'),
  permissions: {Permissions.shipmentsRequest},
  profileActive: true,
);

void main() {
  late MockCheckAuthStatus checkAuthStatus;
  late MockGetCurrentUser getCurrentUser;
  late MockWatchAuthStatus watchAuthStatus;
  late StreamController<AuthStatus> status;

  setUp(() {
    checkAuthStatus = MockCheckAuthStatus();
    getCurrentUser = MockGetCurrentUser();
    watchAuthStatus = MockWatchAuthStatus();
    status = StreamController<AuthStatus>.broadcast();
    when(() => watchAuthStatus()).thenAnswer((_) => status.stream);
    when(() => getCurrentUser()).thenAnswer((_) async => _farmer);
  });

  tearDown(() => status.close());

  AuthCubit build() =>
      AuthCubit(checkAuthStatus, getCurrentUser, watchAuthStatus);

  test('initial state is unknown with guest access', () {
    final cubit = build();
    expect(cubit.state.status, AuthStatus.unknown);
    expect(cubit.state.access, AccessPolicy.guest);
    cubit.close();
  });

  blocTest<AuthCubit, AuthState>(
    'emits authenticated with the user when a session exists',
    build: () {
      when(() => checkAuthStatus()).thenAnswer((_) async => true);
      return build();
    },
    act: (c) => c.initialize(),
    expect: () => [
      const AuthState(status: AuthStatus.authenticated, user: _farmer),
    ],
    verify: (c) {
      expect(c.state.access.role, Roles.farmer);
      expect(c.state.access.can(Permissions.shipmentsRequest), isTrue);
    },
  );

  blocTest<AuthCubit, AuthState>(
    'emits unauthenticated without loading a user',
    build: () {
      when(() => checkAuthStatus()).thenAnswer((_) async => false);
      return build();
    },
    act: (c) => c.initialize(),
    expect: () => [const AuthState(status: AuthStatus.unauthenticated)],
    verify: (_) => verifyNever(() => getCurrentUser()),
  );

  blocTest<AuthCubit, AuthState>(
    'stays signed in with basic access when the user cannot be read',
    build: () {
      when(() => checkAuthStatus()).thenAnswer((_) async => true);
      when(() => getCurrentUser()).thenThrow(Exception('cache'));
      return build();
    },
    act: (c) => c.initialize(),
    expect: () => [const AuthState(status: AuthStatus.authenticated)],
    verify: (c) => expect(c.state.access, AccessPolicy.signedInWithoutDetails),
  );

  blocTest<AuthCubit, AuthState>(
    'follows the repository auth status stream',
    build: build,
    act: (_) async {
      status.add(AuthStatus.authenticated);
      await Future<void>.delayed(Duration.zero);
      status.add(AuthStatus.unauthenticated);
    },
    expect: () => [
      const AuthState(status: AuthStatus.authenticated, user: _farmer),
      const AuthState(status: AuthStatus.unauthenticated),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'refreshUser picks up changed access',
    build: () {
      when(() => checkAuthStatus()).thenAnswer((_) async => true);
      return build();
    },
    act: (c) async {
      await c.initialize();
      when(() => getCurrentUser()).thenAnswer(
        (_) async => const User(
          id: '1',
          name: 'Farmer',
          email: 'farmer@example.test',
          role: UserRole(value: Roles.farmer, label: 'Farmer'),
        ),
      );
      await c.refreshUser();
    },
    expect: () => [
      const AuthState(status: AuthStatus.authenticated, user: _farmer),
      isA<AuthState>().having(
        (s) => s.access.profileActive,
        'profileActive',
        isFalse,
      ),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'refreshUser does nothing when signed out',
    build: build,
    act: (c) => c.refreshUser(),
    expect: () => const <AuthState>[],
  );
}
