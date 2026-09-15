import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:starter/core/error/app_exception.dart';
import 'package:starter/domain/auth/use_cases/login.dart';
import 'package:starter/features/auth/presentation/bloc/auth_cubit.dart';

import 'login_state.dart';

@injectable
class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._login, this._authCubit) : super(const LoginState());

  final Login _login;
  final AuthCubit _authCubit;

  Future<void> submit({
    required String username,
    required String password,
  }) async {
    if (state.isSubmitting) return;
    if (username.trim().isEmpty || password.isEmpty) {
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
      await _login(email: username.trim(), password: password);
      _authCubit.authenticated();
      emit(state.copyWith(status: LoginStatus.success));
    } on AppException catch (e) {
      emit(
        state.copyWith(status: LoginStatus.failure, errorMessage: e.message),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'Sign in failed. Please try again.',
        ),
      );
    }
  }

  void reset() => emit(const LoginState());
}
