import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/communication/sources/remote/communication_remote_data_source.dart';

import 'alerts_event.dart';
import 'alerts_state.dart';

@injectable
class AlertsBloc extends Bloc<AlertsEvent, AlertsState> {
  AlertsBloc(this._communicationRemoteDataSource)
    : super(const AlertsState()) {
    on<AlertsStarted>(_onStarted, transformer: restartable());
    on<AlertsMoreRequested>(_onMoreRequested, transformer: droppable());
  }

  final CommunicationRemoteDataSource _communicationRemoteDataSource;

  Future<void> _onStarted(
    AlertsStarted event,
    Emitter<AlertsState> emit,
  ) async {
    emit(state.copyWith(status: AlertsStatus.loading, loadingMore: false));
    try {
      final result = await _communicationRemoteDataSource.getAlerts(
        page: 1,
        perPage: Paged.defaultPerPage,
      );
      emit(state.copyWith(status: AlertsStatus.loaded, alerts: result));
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: AlertsStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AlertsStatus.failure,
          errorMessage: 'Could not load alerts.',
        ),
      );
    }
  }

  Future<void> _onMoreRequested(
    AlertsMoreRequested event,
    Emitter<AlertsState> emit,
  ) async {
    final current = state.alerts;
    if (current == null || !current.hasMore || state.loadingMore) return;
    emit(state.copyWith(loadingMore: true));
    try {
      final next = await _communicationRemoteDataSource.getAlerts(
        page: current.page + 1,
        perPage: Paged.defaultPerPage,
      );
      // Drop a stale page (e.g. after a refresh changed the current page).
      if (next.page <= (state.alerts?.page ?? 0)) return;
      emit(
        state.copyWith(
          alerts: current.append(next),
          loadingMore: false,
        ),
      );
    } on AppException catch (e) {
      emit(state.copyWith(loadingMore: false, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(loadingMore: false));
    }
  }
}
