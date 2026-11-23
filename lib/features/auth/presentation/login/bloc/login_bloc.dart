import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/error/exceptions/validation_exception.dart';
import 'package:super_flutter/domain/auth/entities/auth_session.dart';
import 'package:super_flutter/domain/auth/use_cases/login.dart';
import 'package:super_flutter/domain/auth/use_cases/request_otp.dart';
import 'package:super_flutter/domain/auth/use_cases/verify_otp.dart';

import 'login_event.dart';
import 'login_state.dart';

@injectable
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(this._login, this._requestOtp, this._verifyOtp)
    : super(const LoginState()) {
    on<LoginPasswordVisibilityToggled>(_onPasswordVisibilityToggled);
    on<LoginFieldErrorCleared>(_onFieldErrorCleared);
    on<LoginSubmitted>(_onSubmitted, transformer: droppable());
    on<LoginMethodChanged>(_onMethodChanged);
    on<LoginOtpRequested>(_onOtpRequested, transformer: droppable());
    on<LoginOtpSubmitted>(_onOtpSubmitted, transformer: droppable());
    on<LoginOtpNumberChanged>(_onOtpNumberChanged);
    on<LoginOtpTimerStarted>(_onOtpTimerStarted, transformer: restartable());
  }

  final Login _login;
  final RequestOtp _requestOtp;
  final VerifyOtp _verifyOtp;

  void _onPasswordVisibilityToggled(
    LoginPasswordVisibilityToggled event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  void _onFieldErrorCleared(
    LoginFieldErrorCleared event,
    Emitter<LoginState> emit,
  ) {
    if (!state.fieldErrors.containsKey(event.field)) return;
    emit(
      state.copyWith(
        fieldErrors: Map.of(state.fieldErrors)..remove(event.field),
      ),
    );
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    final email = event.email.trim();
    if (email.isEmpty || event.password.isEmpty) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'Please enter your email and password.',
        ),
      );
      return;
    }
    await _signIn(emit, () => _login(email: email, password: event.password));
  }

  void _onMethodChanged(LoginMethodChanged event, Emitter<LoginState> emit) {
    if (event.method == state.method) return;
    emit(state.copyWith(method: event.method, fieldErrors: const {}));
  }

  Future<void> _onOtpRequested(
    LoginOtpRequested event,
    Emitter<LoginState> emit,
  ) async {
    final phone = event.phone.trim();
    emit(state.copyWith(status: LoginStatus.submitting, fieldErrors: const {}));
    try {
      final seconds = await _requestOtp(phone: phone);
      emit(
        state.copyWith(
          status: LoginStatus.initial,
          otpPhone: () => phone,
          otpSecondsLeft: seconds,
        ),
      );
      add(LoginOtpTimerStarted(seconds));
    } on ValidationException catch (e) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: e.message,
          fieldErrors: e.fieldErrors,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(status: LoginStatus.failure, errorMessage: e.message),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'The code could not be sent. Please try again.',
        ),
      );
    }
  }

  Future<void> _onOtpSubmitted(
    LoginOtpSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    final phone = state.otpPhone;
    if (phone == null) return;
    await _signIn(emit, () => _verifyOtp(phone: phone, otp: event.otp));
  }

  void _onOtpNumberChanged(
    LoginOtpNumberChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(
      state.copyWith(
        otpPhone: () => null,
        otpSecondsLeft: 0,
        fieldErrors: const {},
      ),
    );
    add(const LoginOtpTimerStarted(0));
  }

  /// Counts the code's validity down a second at a time; a new code
  /// restarts it.
  Future<void> _onOtpTimerStarted(
    LoginOtpTimerStarted event,
    Emitter<LoginState> emit,
  ) {
    return emit.forEach<int>(
      Stream.periodic(
        const Duration(seconds: 1),
        (tick) => event.seconds - tick - 1,
      ).take(event.seconds),
      onData: (left) => state.copyWith(
        status: state.status,
        errorMessage: state.errorMessage,
        otpSecondsLeft: left,
      ),
    );
  }

  Future<void> _signIn(
    Emitter<LoginState> emit,
    Future<AuthSession> Function() signIn,
  ) async {
    emit(state.copyWith(status: LoginStatus.submitting, fieldErrors: const {}));
    try {
      final session = await signIn();
      emit(
        state.copyWith(
          status: LoginStatus.success,
          passwordChangeRequired: session.passwordChangeRequired,
        ),
      );
    } on ValidationException catch (e) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: e.message,
          fieldErrors: e.fieldErrors,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(status: LoginStatus.failure, errorMessage: e.message),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'Sign in failed. Please try again.',
        ),
      );
    }
  }
}
