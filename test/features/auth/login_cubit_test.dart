import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:starter/core/error/exceptions/unauthorized_exception.dart';
import 'package:starter/domain/auth/entities/user.dart';
import 'package:starter/domain/auth/use_cases/login.dart';
import 'package:starter/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:starter/features/auth/presentation/bloc/login_cubit.dart';
import 'package:starter/features/auth/presentation/bloc/login_state.dart';

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

  blocTest<LoginCubit, LoginState>(
    'emits submitting then success and marks session authenticated',
    build: () {
      when(
        () => login(email: any(named: 'email'), password: any(named: 'password')),
      ).thenAnswer((_) async => user);
      return LoginCubit(login, authCubit);
    },
    act: (c) => c.submit(username: 'emilys', password: 'emilyspass'),
    expect: () => [
      const LoginState(status: LoginStatus.submitting),
      const LoginState(status: LoginStatus.success),
    ],
    verify: (_) {
      verify(
        () => login(email: 'emilys', password: 'emilyspass'),
      ).called(1);
      verify(() => authCubit.authenticated()).called(1);
    },
  );

  blocTest<LoginCubit, LoginState>(
    'emits failure when credentials are blank',
    build: () => LoginCubit(login, authCubit),
    act: (c) => c.submit(username: '  ', password: ''),
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

  blocTest<LoginCubit, LoginState>(
    'emits failure with exception message on AppException',
    build: () {
      when(
        () => login(email: any(named: 'email'), password: any(named: 'password')),
      ).thenThrow(const UnauthorizedException('Invalid credentials.'));
      return LoginCubit(login, authCubit);
    },
    act: (c) => c.submit(username: 'emilys', password: 'wrong'),
    expect: () => [
      const LoginState(status: LoginStatus.submitting),
      const LoginState(
        status: LoginStatus.failure,
        errorMessage: 'Invalid credentials.',
      ),
    ],
    verify: (_) => verifyNever(() => authCubit.authenticated()),
  );
}
