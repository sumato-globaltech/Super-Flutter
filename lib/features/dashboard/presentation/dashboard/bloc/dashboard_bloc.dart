import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/domain/auth/use_cases/logout.dart';

import 'dashboard_event.dart';
import 'dashboard_state.dart';

@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc(this._logout) : super(const DashboardState()) {
    on<DashboardSignOutRequested>(
      _onSignOutRequested,
      transformer: droppable(),
    );
  }

  final Logout _logout;

  Future<void> _onSignOutRequested(
    DashboardSignOutRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.submitting));
    try {
      await _logout(allDevices: event.allDevices);
    } finally {
      emit(state.copyWith(status: DashboardStatus.success));
    }
  }
}
