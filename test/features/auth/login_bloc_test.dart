import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/core/error/exceptions/unauthorized_exception.dart';
import 'package:super_flutter/core/error/exceptions/validation_exception.dart';
import 'package:super_flutter/domain/auth/entities/auth_session.dart';
import 'package:super_flutter/domain/auth/entities/auth_token.dart';
import 'package:super_flutter/domain/auth/entities/user.dart';
import 'package:super_flutter/domain/auth/use_cases/login.dart';
import 'package:super_flutter/domain/auth/use_cases/request_otp.dart';
import 'package:super_flutter/domain/auth/use_cases/verify_otp.dart';
import 'package:super_flutter/features/auth/presentation/login/bloc/login_bloc.dart';
import 'package:super_flutter/features/auth/presentation/login/bloc/login_event.dart';
import 'package:super_flutter/features/auth/presentation/login/bloc/login_state.dart';

class MockLogin extends Mock implements Login {}

class MockRequestOtp extends Mock implements RequestOtp {}

class MockVerifyOtp extends Mock implements VerifyOtp {}

void main() {
  late MockLogin login;
  late MockRequestOtp requestOtp;
  late MockVerifyOtp verifyOtp;

  const session = AuthSession(
    user: User(id: 'u1', name: 'Emily', email: 'emily@test.com'),
    tokens: AuthTokens(accessToken: 'a'),
  );

  setUp(() {
    login = MockLogin();
    requestOtp = MockRequestOtp();
    verifyOtp = MockVerifyOtp();
  });

  const submitted = LoginSubmitted(
    email: ' emily@test.com ',
    password: 'emilyspass',
  );

  blocTest<LoginBloc, LoginState>(
    'emits failure when submitting blank form',
    build: () => LoginBloc(login, requestOtp, verifyOtp),
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
    'sends trimmed event values to login',
    build: () {
      when(
        () => login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => session);
      return LoginBloc(login, requestOtp, verifyOtp);
    },
    act: (b) => b.add(submitted),
    expect: () => [
      const LoginState(status: LoginStatus.submitting),
      const LoginState(status: LoginStatus.success),
    ],
    verify: (_) {
      verify(() => login(email: 'emily@test.com', password: 'emilyspass'))
          .called(1);
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
      return LoginBloc(login, requestOtp, verifyOtp);
    },
    act: (b) => b.add(submitted),
    expect: () => [
      const LoginState(status: LoginStatus.submitting),
      const LoginState(
        status: LoginStatus.failure,
        errorMessage: 'Invalid credentials.',
      ),
    ],
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
      return LoginBloc(login, requestOtp, verifyOtp);
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

  blocTest<LoginBloc, LoginState>(
    'editing a field clears only that field server error',
    build: () => LoginBloc(login, requestOtp, verifyOtp),
    seed: () => const LoginState(
      status: LoginStatus.failure,
      fieldErrors: {'email': 'Bad email', 'password': 'Bad password'},
    ),
    act: (b) => b
      ..add(const LoginFieldErrorCleared('email'))
      ..add(const LoginFieldErrorCleared('email')),
    expect: () => [
      const LoginState(
        status: LoginStatus.failure,
        fieldErrors: {'password': 'Bad password'},
      ),
    ],
  );

  group('phone OTP', () {
    blocTest<LoginBloc, LoginState>(
      'a sent code shows the number and starts the countdown',
      setUp: () =>
          when(() => requestOtp(phone: any(named: 'phone')))
              .thenAnswer((_) async => 300),
      build: () => LoginBloc(login, requestOtp, verifyOtp),
      seed: () => const LoginState(method: LoginMethod.phone),
      act: (bloc) => bloc.add(const LoginOtpRequested(' 9876543210 ')),
      expect: () => [
        const LoginState(
          method: LoginMethod.phone,
          status: LoginStatus.submitting,
        ),
        const LoginState(
          method: LoginMethod.phone,
          otpPhone: '9876543210',
          otpSecondsLeft: 300,
        ),
      ],
      verify: (_) => verify(() => requestOtp(phone: '9876543210')).called(1),
    );

    blocTest<LoginBloc, LoginState>(
      'a field error on phone stays on the phone step',
      setUp: () => when(() => requestOtp(phone: any(named: 'phone'))).thenThrow(
        const ValidationException(
          'The phone field must be 10 digits.',
          fieldErrors: {'phone': 'The phone field must be 10 digits.'},
        ),
      ),
      build: () => LoginBloc(login, requestOtp, verifyOtp),
      act: (bloc) => bloc.add(const LoginOtpRequested('98765')),
      skip: 1,
      expect: () => [
        const LoginState(
          status: LoginStatus.failure,
          errorMessage: 'The phone field must be 10 digits.',
          fieldErrors: {'phone': 'The phone field must be 10 digits.'},
        ),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'the code signs in to the number it was sent to',
      setUp: () => when(
        () => verifyOtp(
          phone: any(named: 'phone'),
          otp: any(named: 'otp'),
        ),
      ).thenAnswer((_) async => session),
      build: () => LoginBloc(login, requestOtp, verifyOtp),
      seed: () => const LoginState(
        method: LoginMethod.phone,
        otpPhone: '9876543210',
        otpSecondsLeft: 120,
      ),
      act: (bloc) => bloc.add(const LoginOtpSubmitted('123456')),
      expect: () => [
        const LoginState(
          method: LoginMethod.phone,
          otpPhone: '9876543210',
          otpSecondsLeft: 120,
          status: LoginStatus.submitting,
        ),
        const LoginState(
          method: LoginMethod.phone,
          otpPhone: '9876543210',
          otpSecondsLeft: 120,
          status: LoginStatus.success,
        ),
      ],
      verify: (_) =>
          verify(() => verifyOtp(phone: '9876543210', otp: '123456')).called(1),
    );

    blocTest<LoginBloc, LoginState>(
      'a wrong code is an error on the code',
      setUp: () =>
          when(
            () => verifyOtp(
              phone: any(named: 'phone'),
              otp: any(named: 'otp'),
            ),
          ).thenThrow(
            const ValidationException(
              'The OTP is invalid or has expired.',
              fieldErrors: {'otp': 'The OTP is invalid or has expired.'},
            ),
          ),
      build: () => LoginBloc(login, requestOtp, verifyOtp),
      seed: () => const LoginState(
        method: LoginMethod.phone,
        otpPhone: '9876543210',
        otpSecondsLeft: 60,
      ),
      act: (bloc) => bloc.add(const LoginOtpSubmitted('000000')),
      skip: 1,
      expect: () => [
        const LoginState(
          method: LoginMethod.phone,
          otpPhone: '9876543210',
          otpSecondsLeft: 60,
          status: LoginStatus.failure,
          errorMessage: 'The OTP is invalid or has expired.',
          fieldErrors: {'otp': 'The OTP is invalid or has expired.'},
        ),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'changing the number goes back to the phone step',
      build: () => LoginBloc(login, requestOtp, verifyOtp),
      seed: () => const LoginState(
        method: LoginMethod.phone,
        otpPhone: '9876543210',
        otpSecondsLeft: 60,
        fieldErrors: {'otp': 'wrong'},
      ),
      act: (bloc) => bloc.add(const LoginOtpNumberChanged()),
      expect: () => [const LoginState(method: LoginMethod.phone)],
    );

    blocTest<LoginBloc, LoginState>(
      'switching method clears field errors',
      build: () => LoginBloc(login, requestOtp, verifyOtp),
      seed: () => const LoginState(fieldErrors: {'email': 'bad'}),
      act: (bloc) => bloc.add(const LoginMethodChanged(LoginMethod.phone)),
      expect: () => [const LoginState(method: LoginMethod.phone)],
    );
  });
}
