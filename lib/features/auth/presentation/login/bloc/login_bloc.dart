import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/domain/auth/use_cases/login.dart';
import 'package:super_flutter/features/auth/session/bloc/auth_cubit.dart';

import 'login_event.dart';
import 'login_state.dart';

/// Form + submission Bloc for [LoginScreen].
///
/// Owns the form key and text controllers so the screen stays stateless.
/// Keeps [AuthCubit] status-only: on success it reflects the new session via
/// `authenticated()`.
@injectable
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(this._login, this._authCubit) : super(const LoginState()) {
    on<LoginUsernameChanged>(_onUsernameChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginPasswordVisibilityToggled>(_onPasswordVisibilityToggled);
    on<LoginSubmitted>(_onSubmitted);
    on<LoginReset>(_onReset);

    emailController.addListener(_emailListener);
    passwordController.addListener(_passwordListener);
  }

  final Login _login;
  final AuthCubit _authCubit;

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void _emailListener() {
    if (emailController.text != state.username) {
      add(LoginUsernameChanged(emailController.text));
    }
  }

  void _passwordListener() {
    if (passwordController.text != state.password) {
      add(LoginPasswordChanged(passwordController.text));
    }
  }

  void _onUsernameChanged(
    LoginUsernameChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(username: event.username, status: LoginStatus.initial));
  }

  void _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(password: event.password, status: LoginStatus.initial));
  }

  void _onPasswordVisibilityToggled(
    LoginPasswordVisibilityToggled event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  void _onReset(LoginReset event, Emitter<LoginState> emit) {
    emailController.clear();
    passwordController.clear();
    formKey.currentState?.reset();
    emit(const LoginState());
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (state.isSubmitting) return;

    // Field-level errors are shown by the form validators when mounted.
    final formValid = formKey.currentState?.validate() ?? true;
    if (!formValid) return;

    if (!state.isValid) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'Please enter your username and password.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: LoginStatus.submitting));
    try {
      await _login(email: state.username.trim(), password: state.password);
      _authCubit.authenticated();
      emit(state.copyWith(status: LoginStatus.success));
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

  @override
  Future<void> close() {
    emailController
      ..removeListener(_emailListener)
      ..dispose();
    passwordController
      ..removeListener(_passwordListener)
      ..dispose();
    return super.close();
  }
}
