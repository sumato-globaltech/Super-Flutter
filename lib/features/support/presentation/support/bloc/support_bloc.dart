import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/support/sources/remote/support_remote_data_source.dart';

import 'support_event.dart';
import 'support_state.dart';

@injectable
class SupportBloc extends Bloc<SupportEvent, SupportState> {
  SupportBloc(this._supportRemoteDataSource) : super(const SupportState()) {
    on<SupportStarted>(_onStarted, transformer: restartable());
    on<SupportMoreRequested>(_onMoreRequested, transformer: droppable());
    on<SupportCallBackRequested>(_onCallBackRequested);
  }

  final SupportRemoteDataSource _supportRemoteDataSource;

  Future<void> _onStarted(
    SupportStarted event,
    Emitter<SupportState> emit,
  ) async {
    emit(state.copyWith(status: SupportStatus.loading));
    try {
      // The tickets still show when the call center can't be loaded.
      final callCenter = _supportRemoteDataSource.getCallCenter().then(
        (value) => value,
        onError: (Object _) => null,
      );
      final tickets = await _supportRemoteDataSource.getTickets(
        page: 1,
        perPage: Paged.defaultPerPage,
      );
      emit(
        state.copyWith(
          status: SupportStatus.success,
          tickets: tickets,
          callCenter: await callCenter,
          loadingMore: false,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(status: SupportStatus.failure, errorMessage: e.message),
      );
    } catch (_) {
      emit(state.copyWith(status: SupportStatus.failure));
    }
  }

  Future<void> _onMoreRequested(
    SupportMoreRequested event,
    Emitter<SupportState> emit,
  ) async {
    final current = state.tickets;
    final page = current?.nextPage;
    if (current == null ||
        page == null ||
        state.loadingMore ||
        state.status == SupportStatus.loading) {
      return;
    }
    emit(state.copyWith(loadingMore: true));
    try {
      final next = await _supportRemoteDataSource.getTickets(
        page: page,
        perPage: Paged.defaultPerPage,
      );
      // A refresh that finished meanwhile has the newer list.
      if (state.tickets != current) return;
      emit(
        state.copyWith(
          status: SupportStatus.success,
          tickets: current.append(next),
          loadingMore: false,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: SupportStatus.failure,
          loadingMore: false,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: SupportStatus.failure, loadingMore: false));
    }
  }

  Future<void> _onCallBackRequested(
    SupportCallBackRequested event,
    Emitter<SupportState> emit,
  ) async {
    try {
      await _supportRemoteDataSource.createCallBack(question: event.question);
      event.completer.complete();
      if (!isClosed) add(const SupportStarted());
    } catch (e) {
      event.completer.completeError(e);
    }
  }
}
