import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/facilities/sources/remote/facilities_remote_data_source.dart';
import 'package:super_flutter/data/meetings/sources/remote/meetings_remote_data_source.dart';

import 'facilities_event.dart';
import 'facilities_state.dart';

@injectable
class FacilitiesBloc extends Bloc<FacilitiesEvent, FacilitiesState> {
  FacilitiesBloc(
    this._facilitiesRemoteDataSource,
    this._meetingsRemoteDataSource,
  ) : super(const FacilitiesState()) {
    on<FacilitiesStarted>(_onStarted, transformer: restartable());
    on<FacilitiesMoreRequested>(_onMoreRequested, transformer: droppable());
  }

  final FacilitiesRemoteDataSource _facilitiesRemoteDataSource;
  final MeetingsRemoteDataSource _meetingsRemoteDataSource;

  /// The list still shows when a filter's choices can't be loaded.
  Future<List<T>> _options<T>(
    List<T> loaded,
    Future<List<T>> Function() load,
  ) async {
    if (loaded.isNotEmpty) return loaded;
    try {
      return await load();
    } catch (_) {
      return <T>[];
    }
  }

  Future<void> _onStarted(
    FacilitiesStarted event,
    Emitter<FacilitiesState> emit,
  ) async {
    final filter = event.filter ?? state.filter;
    emit(
      state.copyWith(
        status: FacilitiesStatus.loading,
        filter: filter,
        clear: filter != state.filter,
      ),
    );
    try {
      final categories = await _options(
        state.categories,
        _facilitiesRemoteDataSource.getFacilityTypes,
      );
      final districts = await _options(
        state.districts,
        _meetingsRemoteDataSource.getDistrictList,
      );
      final facilities = await _facilitiesRemoteDataSource.getFacilities(
        categoryId: filter.category,
        districtId: filter.district,
        page: 1,
        perPage: Paged.defaultPerPage,
      );
      emit(
        state.copyWith(
          status: FacilitiesStatus.success,
          facilities: facilities,
          categories: categories,
          districts: districts,
          loadingMore: false,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: FacilitiesStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: FacilitiesStatus.failure));
    }
  }

  Future<void> _onMoreRequested(
    FacilitiesMoreRequested event,
    Emitter<FacilitiesState> emit,
  ) async {
    final current = state.facilities;
    final page = current?.nextPage;
    if (current == null ||
        page == null ||
        state.loadingMore ||
        state.status == FacilitiesStatus.loading) {
      return;
    }
    emit(state.copyWith(loadingMore: true));
    try {
      final next = await _facilitiesRemoteDataSource.getFacilities(
        categoryId: state.filter.category,
        districtId: state.filter.district,
        page: page,
        perPage: Paged.defaultPerPage,
      );
      // A refresh that finished meanwhile has the newer list.
      if (state.facilities != current) return;
      emit(
        state.copyWith(
          status: FacilitiesStatus.success,
          facilities: current.append(next),
          loadingMore: false,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: FacilitiesStatus.failure,
          loadingMore: false,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(status: FacilitiesStatus.failure, loadingMore: false),
      );
    }
  }
}
