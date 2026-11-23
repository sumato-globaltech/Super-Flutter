import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/error/exceptions/validation_exception.dart';
import 'package:super_flutter/data/auth/sources/remote/auth_remote_data_source.dart';
import 'package:super_flutter/domain/auth/use_cases/logout.dart';
import 'package:super_flutter/domain/auth/use_cases/password_changed.dart';

import 'change_password_event.dart';
import 'change_password_state.dart';

@injectable
class ChangePasswordBloc
    extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  ChangePasswordBloc(
    this._authRemoteDataSource,
    this._passwordChanged,
    this._logout,
  ) : super(const ChangePasswordState()) {
    on<ChangePasswordStarted>(_onStarted);
    on<ChangePasswordCurrentPasswordVisibilityToggled>(
      _onCurrentPasswordVisibilityToggled,
    );
    on<ChangePasswordPasswordVisibilityToggled>(_onPasswordVisibilityToggled);
    on<ChangePasswordPasswordConfirmationVisibilityToggled>(
      _onPasswordConfirmationVisibilityToggled,
    );
    on<ChangePasswordFieldErrorCleared>(_onFieldErrorCleared);
    on<ChangePasswordSubmitted>(_onSubmitted, transformer: droppable());
    on<ChangePasswordSignOutRequested>(
      (event, emit) => _logout(),
      transformer: droppable(),
    );
  }

  final AuthRemoteDataSource _authRemoteDataSource;
  final PasswordChanged _passwordChanged;
  final Logout _logout;

  Future<void> _onStarted(
    ChangePasswordStarted event,
    Emitter<ChangePasswordState> emit,
  ) async {}

  void _onCurrentPasswordVisibilityToggled(
    ChangePasswordCurrentPasswordVisibilityToggled event,
    Emitter<ChangePasswordState> emit,
  ) {
    emit(state.copyWith(obscureCurrentPassword: !state.obscureCurrentPassword));
  }

  void _onPasswordVisibilityToggled(
    ChangePasswordPasswordVisibilityToggled event,
    Emitter<ChangePasswordState> emit,
  ) {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  void _onPasswordConfirmationVisibilityToggled(
    ChangePasswordPasswordConfirmationVisibilityToggled event,
    Emitter<ChangePasswordState> emit,
  ) {
    emit(
      state.copyWith(
        obscurePasswordConfirmation: !state.obscurePasswordConfirmation,
      ),
    );
  }

  void _onFieldErrorCleared(
    ChangePasswordFieldErrorCleared event,
    Emitter<ChangePasswordState> emit,
  ) {
    if (!state.fieldErrors.containsKey(event.field)) return;
    emit(
      state.copyWith(
        fieldErrors: Map.of(state.fieldErrors)..remove(event.field),
      ),
    );
  }

  Future<void> _onSubmitted(
    ChangePasswordSubmitted event,
    Emitter<ChangePasswordState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ChangePasswordStatus.submitting,
        fieldErrors: const {},
      ),
    );
    try {
      final ok = await _authRemoteDataSource.changePassword(
        currentPassword: event.currentPassword,
        password: event.password,
        passwordConfirmation: event.passwordConfirmation,
      );
      if (!ok) {
        emit(state.copyWith(status: ChangePasswordStatus.failure));
        return;
      }
      emit(state.copyWith(status: ChangePasswordStatus.success));
      // The session learns the password is current, and lets the user go on.
      await _passwordChanged();
    } on ValidationException catch (e) {
      emit(
        state.copyWith(
          status: ChangePasswordStatus.failure,
          errorMessage: e.message,
          fieldErrors: e.fieldErrors,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: ChangePasswordStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: ChangePasswordStatus.failure));
    }
  }
}
