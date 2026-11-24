import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/admin_communication/sources/remote/admin_communication_remote_data_source.dart';

import 'admin_notices_event.dart';
import 'admin_notices_state.dart';

@injectable
class AdminNoticesBloc extends Bloc<AdminNoticesEvent, AdminNoticesState> {
  AdminNoticesBloc(this._adminCommunicationRemoteDataSource)
    : super(const AdminNoticesState()) {
    on<AdminNoticesStarted>(_onStarted, transformer: restartable());
    on<AdminNoticesMoreRequested>(_onMoreRequested, transformer: droppable());
    on<AdminNoticeActionSubmitted>(_onActionSubmitted);
  }

  final AdminCommunicationRemoteDataSource _adminCommunicationRemoteDataSource;

  Future<void> _onStarted(
    AdminNoticesStarted event,
    Emitter<AdminNoticesState> emit,
  ) async {
    emit(state.copyWith(status: AdminNoticesStatus.loading));
    try {
      final adminNotices = await _adminCommunicationRemoteDataSource
          .getAdminNotices(page: 1, perPage: Paged.defaultPerPage);
      emit(
        state.copyWith(
          status: AdminNoticesStatus.success,
          adminNotices: adminNotices,
          loadingMore: false,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: AdminNoticesStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: AdminNoticesStatus.failure));
    }
  }

  Future<void> _onMoreRequested(
    AdminNoticesMoreRequested event,
    Emitter<AdminNoticesState> emit,
  ) async {
    final current = state.adminNotices;
    final page = current?.nextPage;
    if (current == null ||
        page == null ||
        state.loadingMore ||
        state.status == AdminNoticesStatus.loading) {
      return;
    }
    emit(state.copyWith(loadingMore: true));
    try {
      final next = await _adminCommunicationRemoteDataSource.getAdminNotices(
        page: page,
        perPage: Paged.defaultPerPage,
      );
      // A refresh that finished meanwhile has the newer list.
      if (state.adminNotices != current) return;
      emit(
        state.copyWith(
          status: AdminNoticesStatus.success,
          adminNotices: current.append(next),
          loadingMore: false,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: AdminNoticesStatus.failure,
          loadingMore: false,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(status: AdminNoticesStatus.failure, loadingMore: false),
      );
    }
  }

  Future<void> _onActionSubmitted(
    AdminNoticeActionSubmitted event,
    Emitter<AdminNoticesState> emit,
  ) async {
    final source = _adminCommunicationRemoteDataSource;
    try {
      switch (event.action) {
        case AdminNoticeAction.publish:
          await source.publishNotice(event.notice);
        case AdminNoticeAction.archive:
          await source.archiveNotice(event.notice);
        case AdminNoticeAction.restore:
          await source.restoreNotice(event.notice);
        case AdminNoticeAction.delete:
          await source.deleteAdminNoticeRemoval(event.notice);
      }
      event.completer.complete();
      if (!isClosed) add(const AdminNoticesStarted());
    } catch (e) {
      event.completer.completeError(e);
    }
  }
}
