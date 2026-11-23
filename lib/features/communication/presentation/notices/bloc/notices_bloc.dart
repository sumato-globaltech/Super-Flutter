import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/communication/sources/remote/communication_remote_data_source.dart';

import 'notices_event.dart';
import 'notices_state.dart';

@injectable
class NoticesBloc extends Bloc<NoticesEvent, NoticesState> {
  NoticesBloc(this._communicationRemoteDataSource)
    : super(const NoticesState()) {
    on<NoticesStarted>(_onStarted, transformer: restartable());
    on<NoticesMoreRequested>(_onMoreRequested, transformer: droppable());
  }

  final CommunicationRemoteDataSource _communicationRemoteDataSource;

  Future<void> _onStarted(
    NoticesStarted event,
    Emitter<NoticesState> emit,
  ) async {
    emit(state.copyWith(status: NoticesStatus.loading, loadingMore: false));
    try {
      final result = await _communicationRemoteDataSource.getNotices(
        page: 1,
        perPage: Paged.defaultPerPage,
      );
      emit(state.copyWith(status: NoticesStatus.loaded, notices: result));
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: NoticesStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: NoticesStatus.failure,
          errorMessage: 'Could not load notices.',
        ),
      );
    }
  }

  Future<void> _onMoreRequested(
    NoticesMoreRequested event,
    Emitter<NoticesState> emit,
  ) async {
    final current = state.notices;
    if (current == null || !current.hasMore || state.loadingMore) return;
    emit(state.copyWith(loadingMore: true));
    try {
      final next = await _communicationRemoteDataSource.getNotices(
        page: current.page + 1,
        perPage: Paged.defaultPerPage,
      );
      // Drop a stale page (e.g. after a refresh changed the current page).
      if (next.page <= (state.notices?.page ?? 0)) return;
      emit(
        state.copyWith(
          notices: current.append(next),
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
