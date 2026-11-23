import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/data/farm/sources/remote/farm_remote_data_source.dart';

import 'farms_event.dart';
import 'farms_state.dart';

@injectable
class FarmsBloc extends Bloc<FarmsEvent, FarmsState> {
  FarmsBloc(this._remoteDataSource) : super(const FarmsState()) {
    on<FarmsStarted>(_onStarted, transformer: restartable());
    on<FarmsStatusFilterChanged>(_onFilterChanged, transformer: restartable());
    on<FarmsRefreshed>(_onRefreshed, transformer: restartable());
    on<FarmsMoreRequested>(_onMoreRequested, transformer: droppable());
  }

  final FarmRemoteDataSource _remoteDataSource;

  Future<void> _fetchPage(
    Emitter<FarmsState> emit, {
    required int page,
    required String status,
  }) async {
    try {
      final paged = await _remoteDataSource.getFarms(
        status: status,
        page: page,
      );
      emit(
        state.copyWith(
          status: FarmsListStatus.success,
          items: page == 1 ? paged.items : [...state.items, ...paged.items],
          page: page,
          hasMore: paged.hasMore,
          loadingMore: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: page == 1 ? FarmsListStatus.failure : FarmsListStatus.success,
          loadingMore: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onStarted(FarmsStarted event, Emitter<FarmsState> emit) async {
    emit(
      state.copyWith(
        status: FarmsListStatus.loading,
        statusFilter: event.status,
      ),
    );
    await _fetchPage(emit, page: 1, status: event.status);
  }

  Future<void> _onFilterChanged(
    FarmsStatusFilterChanged event,
    Emitter<FarmsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: FarmsListStatus.loading,
        statusFilter: event.status,
      ),
    );
    await _fetchPage(emit, page: 1, status: event.status);
  }

  Future<void> _onRefreshed(
    FarmsRefreshed event,
    Emitter<FarmsState> emit,
  ) async {
    await _fetchPage(emit, page: 1, status: state.statusFilter);
  }

  Future<void> _onMoreRequested(
    FarmsMoreRequested event,
    Emitter<FarmsState> emit,
  ) async {
    if (!state.hasMore || state.loadingMore) return;
    emit(state.copyWith(loadingMore: true));
    await _fetchPage(emit, page: state.page + 1, status: state.statusFilter);
  }
}
