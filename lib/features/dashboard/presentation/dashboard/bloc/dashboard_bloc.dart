import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/data/communication/sources/remote/communication_remote_data_source.dart';
import 'package:super_flutter/domain/auth/use_cases/logout.dart';

import 'dashboard_event.dart';
import 'dashboard_state.dart';

@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc(this._logout, this._communicationRemoteDataSource)
    : super(const DashboardState()) {
    on<DashboardSignOutRequested>(
      _onSignOutRequested,
      transformer: droppable(),
    );
    on<DashboardStarted>(_onStarted, transformer: restartable());
  }

  static const homeAlerts = 5;
  static const homeNotices = 3;
  static const bannerPlacement = 'home';

  final Logout _logout;
  final CommunicationRemoteDataSource _communicationRemoteDataSource;

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

  Future<void> _onStarted(
    DashboardStarted event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(homeStatus: DashboardHomeStatus.loading));
    String? error;
    // One section failing hides that section, not the home.
    Future<T?> attempt<T>(Future<T> call) async {
      try {
        return await call;
      } on AppException catch (e) {
        error ??= e.message;
      } catch (_) {}
      return null;
    }

    final (banners, alerts, notices) = await (
      attempt(
        _communicationRemoteDataSource.getBanners(placement: bannerPlacement),
      ),
      attempt(
        _communicationRemoteDataSource.getAlerts(
          districtId: event.districtId,
          page: 1,
          perPage: homeAlerts,
        ),
      ),
      attempt(
        _communicationRemoteDataSource.getNotices(
          page: 1,
          perPage: homeNotices,
        ),
      ),
    ).wait;
    final failed = banners == null && alerts == null && notices == null;
    emit(
      state.copyWith(
        homeStatus: failed
            ? DashboardHomeStatus.failure
            : DashboardHomeStatus.success,
        errorMessage: failed ? error : null,
        banners: banners ?? state.banners,
        alerts: alerts?.items ?? state.alerts,
        notices: notices?.items ?? state.notices,
      ),
    );
  }
}
