import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/data/profile/sources/remote/profile_remote_data_source.dart';

import 'profile_event.dart';
import 'profile_state.dart';

@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(this._profileRemoteDataSource) : super(const ProfileState()) {
    on<ProfileStarted>(_onStarted, transformer: restartable());
  }

  final ProfileRemoteDataSource _profileRemoteDataSource;

  Future<void> _onStarted(
    ProfileStarted event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final profile = await _profileRemoteDataSource.getFarmerProfile();
      emit(state.copyWith(status: ProfileStatus.success, profile: profile));
    } on AppException catch (e) {
      emit(
        state.copyWith(status: ProfileStatus.failure, errorMessage: e.message),
      );
    } catch (_) {
      emit(state.copyWith(status: ProfileStatus.failure));
    }
  }
}
