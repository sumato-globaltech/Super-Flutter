import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/meetings/model/district_option_model.dart';
import 'package:super_flutter/data/meetings/sources/remote/meetings_remote_data_source.dart';
import 'package:super_flutter/data/profile/sources/remote/profile_remote_data_source.dart';

import 'meetings_event.dart';
import 'meetings_state.dart';

@injectable
class MeetingsBloc extends Bloc<MeetingsEvent, MeetingsState> {
  MeetingsBloc(this._meetingsRemoteDataSource, this._profileRemoteDataSource)
    : super(const MeetingsState()) {
    on<MeetingsStarted>(_onStarted, transformer: restartable());
    on<MeetingsMoreRequested>(_onMoreRequested, transformer: droppable());
  }

  final MeetingsRemoteDataSource _meetingsRemoteDataSource;
  final ProfileRemoteDataSource _profileRemoteDataSource;

  Future<String?> _ownDistrict(List<DistrictOptionModel> districts) async {
    try {
      final own =
          (await _profileRemoteDataSource.getFarmerProfile())?.district?.id;
      return districts.any((district) => district.id == own) ? own : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _onStarted(
    MeetingsStarted event,
    Emitter<MeetingsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: MeetingsStatus.loading,
        district: event.district,
        clear: event.district != null && event.district != state.district,
      ),
    );
    try {
      var districts = state.districts;
      if (districts.isEmpty) {
        districts = await _meetingsRemoteDataSource.getDistrictList();
        final own = event.farmer ? await _ownDistrict(districts) : null;
        emit(state.copyWith(districts: districts, district: own));
      }
      final district = state.district;
      if (district == null) {
        emit(state.copyWith(status: MeetingsStatus.success));
        return;
      }
      final meetings = await _meetingsRemoteDataSource.getMeetings(
        districtId: district,
        page: 1,
        perPage: Paged.defaultPerPage,
      );
      emit(
        state.copyWith(
          status: MeetingsStatus.success,
          meetings: meetings,
          loadingMore: false,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(status: MeetingsStatus.failure, errorMessage: e.message),
      );
    } catch (_) {
      emit(state.copyWith(status: MeetingsStatus.failure));
    }
  }

  Future<void> _onMoreRequested(
    MeetingsMoreRequested event,
    Emitter<MeetingsState> emit,
  ) async {
    final current = state.meetings;
    final page = current?.nextPage;
    if (current == null ||
        page == null ||
        state.loadingMore ||
        state.status == MeetingsStatus.loading) {
      return;
    }
    emit(state.copyWith(loadingMore: true));
    try {
      final next = await _meetingsRemoteDataSource.getMeetings(
        districtId: state.district,
        page: page,
        perPage: Paged.defaultPerPage,
      );
      // A refresh that finished meanwhile has the newer list.
      if (state.meetings != current) return;
      emit(
        state.copyWith(
          status: MeetingsStatus.success,
          meetings: current.append(next),
          loadingMore: false,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: MeetingsStatus.failure,
          loadingMore: false,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: MeetingsStatus.failure, loadingMore: false));
    }
  }
}
