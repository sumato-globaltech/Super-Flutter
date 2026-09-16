import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/domain/auth/use_cases/logout.dart';
import 'package:super_flutter/features/auth/session/bloc/auth_cubit.dart';

import 'dashboard_event.dart';
import 'dashboard_state.dart';

/// Screen Bloc for [DashboardScreen]. Owns the sign-out *operation*; on
/// completion it reflects the new status via status-only [AuthCubit].
@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc(this._logout, this._authCubit)
    : super(const DashboardState()) {
    on<DashboardSignOutRequested>(_onSignOutRequested);
  }

  final Logout _logout;
  final AuthCubit _authCubit;

  Future<void> _onSignOutRequested(
    DashboardSignOutRequested event,
    Emitter<DashboardState> emit,
  ) async {
    if (state.isSubmitting) return;
    emit(state.copyWith(status: DashboardStatus.submitting));
    try {
      await _logout();
    } finally {
      _authCubit.unauthenticated();
      emit(state.copyWith(status: DashboardStatus.success));
    }
  }
}
