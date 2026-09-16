import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/domain/auth/use_cases/check_auth_status.dart';
import 'package:super_flutter/features/auth/session/bloc/auth_cubit.dart';
import 'package:super_flutter/features/auth/session/bloc/auth_state.dart';

class MockCheckAuthStatus extends Mock implements CheckAuthStatus {}

void main() {
  late MockCheckAuthStatus checkAuthStatus;
  late AuthCubit cubit;

  setUp(() {
    checkAuthStatus = MockCheckAuthStatus();
    cubit = AuthCubit(checkAuthStatus);
  });

  tearDown(() => cubit.close());

  test('initial state is unknown', () {
    expect(cubit.state.status, AuthStatus.unknown);
  });

  blocTest<AuthCubit, AuthState>(
    'emits authenticated when session exists',
    build: () {
      when(() => checkAuthStatus()).thenAnswer((_) async => true);
      return cubit;
    },
    act: (c) => c.initialize(),
    expect: () => [const AuthState(status: AuthStatus.authenticated)],
  );

  blocTest<AuthCubit, AuthState>(
    'emits unauthenticated when no session',
    build: () {
      when(() => checkAuthStatus()).thenAnswer((_) async => false);
      return cubit;
    },
    act: (c) => c.initialize(),
    expect: () => [const AuthState(status: AuthStatus.unauthenticated)],
  );

  blocTest<AuthCubit, AuthState>(
    'authenticated() reflects an externally completed sign-in',
    build: () => cubit,
    act: (c) => c.authenticated(),
    expect: () => [const AuthState(status: AuthStatus.authenticated)],
  );

  blocTest<AuthCubit, AuthState>(
    'unauthenticated() reflects sign-out or session expiry',
    build: () => cubit,
    act: (c) => c.unauthenticated(),
    expect: () => [const AuthState(status: AuthStatus.unauthenticated)],
  );
}
