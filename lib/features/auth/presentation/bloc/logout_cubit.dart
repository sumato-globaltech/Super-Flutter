import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:starter/domain/auth/use_cases/logout.dart';
import 'package:starter/features/auth/presentation/bloc/auth_cubit.dart';

import 'logout_state.dart';

/// Owns the sign-out *operation*. On completion (even on failure, since local
/// session is cleared) it reflects the new status via [AuthCubit].
@injectable
class LogoutCubit extends Cubit<LogoutState> {
  LogoutCubit(this._logout, this._authCubit) : super(const LogoutState());

  final Logout _logout;
  final AuthCubit _authCubit;

  Future<void> submit() async {
    if (state.isSubmitting) return;
    emit(state.copyWith(status: LogoutStatus.submitting));
    try {
      await _logout();
    } finally {
      _authCubit.unauthenticated();
      emit(state.copyWith(status: LogoutStatus.success));
    }
  }
}
