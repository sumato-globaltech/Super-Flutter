import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/core/error/exceptions/unauthorized_exception.dart';
import 'package:super_flutter/core/error/exceptions/validation_exception.dart';
import 'package:super_flutter/domain/auth/entities/auth_session.dart';
import 'package:super_flutter/domain/auth/entities/auth_token.dart';
import 'package:super_flutter/domain/auth/entities/user.dart';
import 'package:super_flutter/domain/auth/use_cases/login.dart';
import 'package:super_flutter/features/auth/session/bloc/auth_cubit.dart';
import 'package:super_flutter/features/auth/presentation/login/bloc/login_bloc.dart';
import 'package:super_flutter/features/auth/presentation/login/bloc/login_event.dart';
import 'package:super_flutter/features/auth/presentation/login/bloc/login_state.dart';

class MockLogin extends Mock implements Login {}

class MockAuthCubit extends Mock implements AuthCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockLogin login;
  late MockAuthCubit authCubit;

  const session = AuthSession(
    user: User(id: 'u1', name: 'Emily', email: 'emily@test.com'),
    tokens: AuthTokens(accessToken: 'a'),
  );

  setUp(() {
    login = MockLogin();
    authCubit = MockAuthCubit();
    when(() => authCubit.authenticated()).thenReturn(null);
  });

  blocTest<LoginBloc, LoginState>(
    'stores field changes and stays initial',
    build: () => LoginBloc(login, authCubit),
    act: (b) => b
      ..add(const LoginEmailChanged('emily@test.com'))
      ..add(const LoginPasswordChanged('emilyspass')),
    expect: () => [
      const LoginState(email: 'emily@test.com'),
      const LoginState(email: 'emily@test.com', password: 'emilyspass'),
    ],
  );

  blocTest<LoginBloc, LoginState>(
    'emits failure when submitting blank form',
    build: () => LoginBloc(login, authCubit),
    act: (b) => b.add(const LoginSubmitted()),
    expect: () => [
      const LoginState(
        status: LoginStatus.failure,
        errorMessage: 'Please enter your email and password.',
      ),
    ],
    verify: (_) => verifyNever(
      () => login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ),
  );

  blocTest<LoginBloc, LoginState>(
    'emits submitting then success and marks session authenticated',
    build: () {
      when(
        () => login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => session);
      return LoginBloc(login, authCubit);
    },
    seed: () =>
        const LoginState(email: 'emily@test.com', password: 'emilyspass'),
    act: (b) => b.add(const LoginSubmitted()),
    expect: () => [
      const LoginState(
        email: 'emily@test.com',
        password: 'emilyspass',
        status: LoginStatus.submitting,
      ),
      const LoginState(
        email: 'emily@test.com',
        password: 'emilyspass',
        status: LoginStatus.success,
      ),
    ],
    verify: (_) {
      verify(() => login(email: 'emily@test.com', password: 'emilyspass'))
          .called(1);
      verify(() => authCubit.authenticated()).called(1);
    },
  );

  blocTest<LoginBloc, LoginState>(
    'emits failure with exception message on AppException',
    build: () {
      when(
        () => login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const UnauthorizedException('Invalid credentials.'));
      return LoginBloc(login, authCubit);
    },
    seed: () => const LoginState(email: 'emily@test.com', password: 'wrong'),
    act: (b) => b.add(const LoginSubmitted()),
    expect: () => [
      const LoginState(
        email: 'emily@test.com',
        password: 'wrong',
        status: LoginStatus.submitting,
      ),
      const LoginState(
        email: 'emily@test.com',
        password: 'wrong',
        status: LoginStatus.failure,
        errorMessage: 'Invalid credentials.',
      ),
    ],
    verify: (_) => verifyNever(() => authCubit.authenticated()),
  );

  blocTest<LoginBloc, LoginState>(
    'maps server field errors and clears email error when typing',
    build: () {
      when(
        () => login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(
        const ValidationException(
          'These credentials do not match our records.',
          fieldErrors: {'email': 'These credentials do not match our records.'},
        ),
      );
      return LoginBloc(login, authCubit);
    },
    seed: () => const LoginState(email: 'a@b.com', password: 'wrong'),
    act: (b) async {
      b.add(const LoginSubmitted());
      await Future<void>.delayed(Duration.zero);
      b.add(const LoginEmailChanged('a@b.co'));
    },
    skip: 1,
    expect: () => [
      const LoginState(
        email: 'a@b.com',
        password: 'wrong',
        status: LoginStatus.failure,
        errorMessage: 'These credentials do not match our records.',
        fieldErrors: {'email': 'These credentials do not match our records.'},
      ),
      const LoginState(email: 'a@b.co', password: 'wrong'),
    ],
  );
}
