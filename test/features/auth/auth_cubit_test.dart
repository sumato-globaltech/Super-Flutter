import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/domain/auth/use_cases/check_auth_status.dart';
import 'package:super_flutter/domain/auth/use_cases/watch_auth_status.dart';
import 'package:super_flutter/features/auth/session/bloc/auth_cubit.dart';
import 'package:super_flutter/features/auth/session/bloc/auth_state.dart';

class MockCheckAuthStatus extends Mock implements CheckAuthStatus {}

class MockWatchAuthStatus extends Mock implements WatchAuthStatus {}

void main() {
  late MockCheckAuthStatus checkAuthStatus;
  late MockWatchAuthStatus watchAuthStatus;
  late StreamController<AuthStatus> status;

  setUp(() {
    checkAuthStatus = MockCheckAuthStatus();
    watchAuthStatus = MockWatchAuthStatus();
    status = StreamController<AuthStatus>.broadcast();
    when(() => watchAuthStatus()).thenAnswer((_) => status.stream);
  });

  tearDown(() => status.close());

  AuthCubit build() => AuthCubit(checkAuthStatus, watchAuthStatus);

  test('initial state is unknown', () {
    final cubit = build();
    expect(cubit.state.status, AuthStatus.unknown);
    cubit.close();
  });

  blocTest<AuthCubit, AuthState>(
    'emits authenticated when session exists',
    build: () {
      when(() => checkAuthStatus()).thenAnswer((_) async => true);
      return build();
    },
    act: (c) => c.initialize(),
    expect: () => [const AuthState(status: AuthStatus.authenticated)],
  );

  blocTest<AuthCubit, AuthState>(
    'emits unauthenticated when no session',
    build: () {
      when(() => checkAuthStatus()).thenAnswer((_) async => false);
      return build();
    },
    act: (c) => c.initialize(),
    expect: () => [const AuthState(status: AuthStatus.unauthenticated)],
  );

  blocTest<AuthCubit, AuthState>(
    'follows the repository auth status stream',
    build: build,
    act: (_) {
      status
        ..add(AuthStatus.authenticated)
        ..add(AuthStatus.unauthenticated);
    },
    expect: () => [
      const AuthState(status: AuthStatus.authenticated),
      const AuthState(status: AuthStatus.unauthenticated),
    ],
  );
}
