import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:starter/core/error/app_exception.dart';
import 'package:starter/domain/auth/use_cases/login.dart';
import 'package:starter/features/auth/session/bloc/auth_cubit.dart';

import 'login_event.dart';
import 'login_state.dart';

/// Form + submission Bloc for [LoginScreen]. Keeps [AuthCubit] status-only:
/// on success it reflects the new session via `authenticated()`.
@injectable
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(this._login, this._authCubit) : super(const LoginState()) {
    on<LoginUsernameChanged>(_onUsernameChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onSubmitted);
    on<LoginReset>((event, emit) => emit(const LoginState()));
  }

  final Login _login;
  final AuthCubit _authCubit;

  void _onUsernameChanged(LoginUsernameChanged event, Emitter<LoginState> emit) {
    emit(
      state.copyWith(
        username: event.username,
        status: LoginStatus.initial,
      ),
    );
  }

  void _onPasswordChanged(LoginPasswordChanged event, Emitter<LoginState> emit) {
    emit(
      state.copyWith(
        password: event.password,
        status: LoginStatus.initial,
      ),
    );
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (state.isSubmitting) return;
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
      emit(state.copyWith(status: LoginStatus.failure, errorMessage: e.message));
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
