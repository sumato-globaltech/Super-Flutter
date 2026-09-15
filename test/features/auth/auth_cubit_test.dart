import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:starter/domain/auth/use_cases/check_auth_status.dart';
import 'package:starter/domain/auth/use_cases/logout.dart';
import 'package:starter/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:starter/features/auth/presentation/bloc/auth_state.dart';

class MockCheckAuthStatus extends Mock implements CheckAuthStatus {}

class MockLogout extends Mock implements Logout {}

void main() {
  late MockCheckAuthStatus checkAuthStatus;
  late MockLogout logout;
  late AuthCubit cubit;

  setUp(() {
    checkAuthStatus = MockCheckAuthStatus();
    logout = MockLogout();
    when(() => logout()).thenAnswer((_) async {});
    cubit = AuthCubit(checkAuthStatus, logout);
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
    'logout calls use-case then emits unauthenticated',
    build: () => cubit,
    act: (c) => c.logout(),
    expect: () => [const AuthState(status: AuthStatus.unauthenticated)],
    verify: (_) => verify(() => logout()).called(1),
  );
}
