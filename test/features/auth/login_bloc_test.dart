import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:starter/core/error/exceptions/unauthorized_exception.dart';
import 'package:starter/domain/auth/entities/user.dart';
import 'package:starter/domain/auth/use_cases/login.dart';
import 'package:starter/features/auth/session/bloc/auth_cubit.dart';
import 'package:starter/features/auth/presentation/login/bloc/login_bloc.dart';
import 'package:starter/features/auth/presentation/login/bloc/login_event.dart';
import 'package:starter/features/auth/presentation/login/bloc/login_state.dart';

class MockLogin extends Mock implements Login {}

class MockAuthCubit extends Mock implements AuthCubit {}

void main() {
  late MockLogin login;
  late MockAuthCubit authCubit;

  const user = User(id: 1, username: 'emilys', email: 'emily@test.com');

  setUp(() {
    login = MockLogin();
    authCubit = MockAuthCubit();
    when(() => authCubit.authenticated()).thenReturn(null);
  });

  blocTest<LoginBloc, LoginState>(
    'stores field changes and stays initial',
    build: () => LoginBloc(login, authCubit),
    act: (b) => b
      ..add(const LoginUsernameChanged('emilys'))
      ..add(const LoginPasswordChanged('emilyspass')),
    expect: () => [
      const LoginState(username: 'emilys'),
      const LoginState(username: 'emilys', password: 'emilyspass'),
    ],
  );

  blocTest<LoginBloc, LoginState>(
    'emits failure when submitting blank form',
    build: () => LoginBloc(login, authCubit),
    act: (b) => b.add(const LoginSubmitted()),
    expect: () => [
      const LoginState(
        status: LoginStatus.failure,
        errorMessage: 'Please enter your username and password.',
      ),
    ],
    verify: (_) => verifyNever(
      () => login(email: any(named: 'email'), password: any(named: 'password')),
    ),
  );

  blocTest<LoginBloc, LoginState>(
    'emits submitting then success and marks session authenticated',
    build: () {
      when(
        () =>
            login(email: any(named: 'email'), password: any(named: 'password')),
      ).thenAnswer((_) async => user);
      return LoginBloc(login, authCubit);
    },
    seed: () => const LoginState(username: 'emilys', password: 'emilyspass'),
    act: (b) => b.add(const LoginSubmitted()),
    expect: () => [
      const LoginState(
        username: 'emilys',
        password: 'emilyspass',
        status: LoginStatus.submitting,
      ),
      const LoginState(
        username: 'emilys',
        password: 'emilyspass',
        status: LoginStatus.success,
      ),
    ],
    verify: (_) {
      verify(() => login(email: 'emilys', password: 'emilyspass')).called(1);
      verify(() => authCubit.authenticated()).called(1);
    },
  );

  blocTest<LoginBloc, LoginState>(
    'emits failure with exception message on AppException',
    build: () {
      when(
        () =>
            login(email: any(named: 'email'), password: any(named: 'password')),
      ).thenThrow(const UnauthorizedException('Invalid credentials.'));
      return LoginBloc(login, authCubit);
    },
    seed: () => const LoginState(username: 'emilys', password: 'wrong'),
    act: (b) => b.add(const LoginSubmitted()),
    expect: () => [
      const LoginState(
        username: 'emilys',
        password: 'wrong',
        status: LoginStatus.submitting,
      ),
      const LoginState(
        username: 'emilys',
        password: 'wrong',
        status: LoginStatus.failure,
        errorMessage: 'Invalid credentials.',
      ),
    ],
    verify: (_) => verifyNever(() => authCubit.authenticated()),
  );
}
