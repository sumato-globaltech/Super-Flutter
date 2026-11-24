import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/admin_communication/sources/remote/admin_communication_remote_data_source.dart';

import 'admin_alerts_event.dart';
import 'admin_alerts_state.dart';

@injectable
class AdminAlertsBloc extends Bloc<AdminAlertsEvent, AdminAlertsState> {
  AdminAlertsBloc(this._adminCommunicationRemoteDataSource)
    : super(const AdminAlertsState()) {
    on<AdminAlertsStarted>(_onStarted, transformer: restartable());
    on<AdminAlertsMoreRequested>(_onMoreRequested, transformer: droppable());
    on<AdminAlertActionSubmitted>(_onActionSubmitted);
  }

  final AdminCommunicationRemoteDataSource _adminCommunicationRemoteDataSource;

  Future<void> _onStarted(
    AdminAlertsStarted event,
    Emitter<AdminAlertsState> emit,
  ) async {
    emit(state.copyWith(status: AdminAlertsStatus.loading));
    try {
      final adminAlerts = await _adminCommunicationRemoteDataSource
          .getAdminAlerts(page: 1, perPage: Paged.defaultPerPage);
      emit(
        state.copyWith(
          status: AdminAlertsStatus.success,
          adminAlerts: adminAlerts,
          loadingMore: false,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: AdminAlertsStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: AdminAlertsStatus.failure));
    }
  }

  Future<void> _onMoreRequested(
    AdminAlertsMoreRequested event,
    Emitter<AdminAlertsState> emit,
  ) async {
    final current = state.adminAlerts;
    final page = current?.nextPage;
    if (current == null ||
        page == null ||
        state.loadingMore ||
        state.status == AdminAlertsStatus.loading) {
      return;
    }
    emit(state.copyWith(loadingMore: true));
    try {
      final next = await _adminCommunicationRemoteDataSource.getAdminAlerts(
        page: page,
        perPage: Paged.defaultPerPage,
      );
      // A refresh that finished meanwhile has the newer list.
      if (state.adminAlerts != current) return;
      emit(
        state.copyWith(
          status: AdminAlertsStatus.success,
          adminAlerts: current.append(next),
          loadingMore: false,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: AdminAlertsStatus.failure,
          loadingMore: false,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(status: AdminAlertsStatus.failure, loadingMore: false),
      );
    }
  }

  Future<void> _onActionSubmitted(
    AdminAlertActionSubmitted event,
    Emitter<AdminAlertsState> emit,
  ) async {
    final source = _adminCommunicationRemoteDataSource;
    try {
      switch (event.action) {
        case AdminAlertAction.activate:
          await source.activateAlert(event.alert);
        case AdminAlertAction.cancel:
          await source.cancelAlert(event.alert);
        case AdminAlertAction.delete:
          await source.deleteAdminAlertRemoval(event.alert);
      }
      event.completer.complete();
      if (!isClosed) add(const AdminAlertsStarted());
    } catch (e) {
      event.completer.completeError(e);
    }
  }
}
