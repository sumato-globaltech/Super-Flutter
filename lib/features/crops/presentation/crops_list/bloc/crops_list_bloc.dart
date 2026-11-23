import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/data/crops/sources/remote/crop_remote_data_source.dart';

import 'crops_list_event.dart';
import 'crops_list_state.dart';

@injectable
class CropsListBloc extends Bloc<CropsListEvent, CropsListState> {
  CropsListBloc(this._remoteDataSource) : super(const CropsListState()) {
    on<CropsListStarted>(_onStarted, transformer: restartable());
    on<CropsListSearchChanged>(_onSearchChanged, transformer: restartable());
    on<CropsListTypeSelected>(_onTypeSelected, transformer: restartable());
    on<CropsListRefreshed>(_onRefreshed, transformer: restartable());
    on<CropsListMoreRequested>(_onMoreRequested, transformer: droppable());
  }

  final CropRemoteDataSource _remoteDataSource;

  Future<void> _fetchPage(
    Emitter<CropsListState> emit, {
    required int page,
    required String search,
    required String? type,
  }) async {
    try {
      final paged = await _remoteDataSource.getCrops(
        search: search.trim().isEmpty ? null : search.trim(),
        type: type,
        page: page,
      );
      emit(
        state.copyWith(
          status: CropsListStatus.success,
          items: page == 1 ? paged.items : [...state.items, ...paged.items],
          page: page,
          hasMore: paged.hasMore,
          loadingMore: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: page == 1 ? CropsListStatus.failure : CropsListStatus.success,
          loadingMore: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onStarted(
    CropsListStarted event,
    Emitter<CropsListState> emit,
  ) async {
    emit(
      state.copyWith(
        status: CropsListStatus.loading,
        search: event.search ?? state.search,
        selectedType: () => event.type ?? state.selectedType,
      ),
    );
    await _fetchPage(
      emit,
      page: 1,
      search: event.search ?? state.search,
      type: event.type ?? state.selectedType,
    );
  }

  Future<void> _onSearchChanged(
    CropsListSearchChanged event,
    Emitter<CropsListState> emit,
  ) async {
    emit(
      state.copyWith(
        status: CropsListStatus.loading,
        search: event.search,
      ),
    );
    await _fetchPage(
      emit,
      page: 1,
      search: event.search,
      type: state.selectedType,
    );
  }

  Future<void> _onTypeSelected(
    CropsListTypeSelected event,
    Emitter<CropsListState> emit,
  ) async {
    emit(
      state.copyWith(
        status: CropsListStatus.loading,
        selectedType: () => event.type,
      ),
    );
    await _fetchPage(
      emit,
      page: 1,
      search: state.search,
      type: event.type,
    );
  }

  Future<void> _onRefreshed(
    CropsListRefreshed event,
    Emitter<CropsListState> emit,
  ) async {
    await _fetchPage(
      emit,
      page: 1,
      search: state.search,
      type: state.selectedType,
    );
  }

  Future<void> _onMoreRequested(
    CropsListMoreRequested event,
    Emitter<CropsListState> emit,
  ) async {
    if (!state.hasMore || state.loadingMore) return;
    emit(state.copyWith(loadingMore: true));
    await _fetchPage(
      emit,
      page: state.page + 1,
      search: state.search,
      type: state.selectedType,
    );
  }
}
