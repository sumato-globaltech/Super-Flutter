import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/error/exceptions/validation_exception.dart';
import 'package:super_flutter/domain/auth/use_cases/login.dart';
import 'package:super_flutter/features/auth/session/bloc/auth_cubit.dart';

import 'login_event.dart';
import 'login_state.dart';

@injectable
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(this._login, this._authCubit) : super(const LoginState()) {
    on<LoginPasswordVisibilityToggled>(_onPasswordVisibilityToggled);
    on<LoginSubmitted>(_onSubmitted);
  }

  final Login _login;
  final AuthCubit _authCubit;

  void _onPasswordVisibilityToggled(
    LoginPasswordVisibilityToggled event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (state.isSubmitting) return;
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
    emit(state.copyWith(status: LoginStatus.submitting, fieldErrors: const {}));
    try {
      final session = await _login(email: email, password: event.password);
      _authCubit.authenticated();
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
