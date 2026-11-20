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

  const submitted = LoginSubmitted(
    email: ' emily@test.com ',
    password: 'emilyspass',
  );

  blocTest<LoginBloc, LoginState>(
    'emits failure when submitting blank form',
    build: () => LoginBloc(login, authCubit),
    act: (b) => b.add(const LoginSubmitted(email: '  ', password: '')),
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
    'sends trimmed event values to login and marks session authenticated',
    build: () {
      when(
        () => login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => session);
      return LoginBloc(login, authCubit);
    },
    act: (b) => b.add(submitted),
    expect: () => [
      const LoginState(status: LoginStatus.submitting),
      const LoginState(status: LoginStatus.success),
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
    act: (b) => b.add(submitted),
    expect: () => [
      const LoginState(status: LoginStatus.submitting),
      const LoginState(
        status: LoginStatus.failure,
        errorMessage: 'Invalid credentials.',
      ),
    ],
    verify: (_) => verifyNever(() => authCubit.authenticated()),
  );

  blocTest<LoginBloc, LoginState>(
    'maps server field errors and clears them on the next submit',
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
    act: (b) async {
      b.add(submitted);
      await Future<void>.delayed(Duration.zero);
      b.add(submitted);
    },
    expect: () => [
      const LoginState(status: LoginStatus.submitting),
      const LoginState(
        status: LoginStatus.failure,
        errorMessage: 'These credentials do not match our records.',
        fieldErrors: {'email': 'These credentials do not match our records.'},
      ),
      const LoginState(status: LoginStatus.submitting),
      const LoginState(
        status: LoginStatus.failure,
        errorMessage: 'These credentials do not match our records.',
        fieldErrors: {'email': 'These credentials do not match our records.'},
      ),
    ],
  );
}
