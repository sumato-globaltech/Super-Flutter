import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/error/exceptions/validation_exception.dart';
import 'package:super_flutter/data/farm/sources/remote/farm_remote_data_source.dart';
import 'package:super_flutter/data/profile/sources/remote/profile_remote_data_source.dart';

import 'edit_profile_event.dart';
import 'edit_profile_state.dart';

@injectable
class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  EditProfileBloc(this._profileRemoteDataSource, this._farmRemoteDataSource)
    : super(const EditProfileState()) {
    on<EditProfileStarted>(_onStarted);
    on<EditProfileFieldErrorCleared>(_onFieldErrorCleared);
    on<EditProfileSubmitted>(_onSubmitted, transformer: droppable());
  }

  final ProfileRemoteDataSource _profileRemoteDataSource;
  final FarmRemoteDataSource _farmRemoteDataSource;

  Future<void> _onStarted(
    EditProfileStarted event,
    Emitter<EditProfileState> emit,
  ) async {
    emit(state.copyWith(loadingOptions: true));
    try {
      final blockOptions = await _farmRemoteDataSource.getBlocks();
      final genderOptions = await _profileRemoteDataSource.getGenders();
      final landOwnershipOptions = await _profileRemoteDataSource
          .getLandOwnerships();
      emit(
        state.copyWith(
          loadingOptions: false,
          blockOptions: blockOptions,
          genderOptions: genderOptions,
          landOwnershipOptions: landOwnershipOptions,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          loadingOptions: false,
          status: EditProfileStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          loadingOptions: false,
          status: EditProfileStatus.failure,
        ),
      );
    }
  }

  void _onFieldErrorCleared(
    EditProfileFieldErrorCleared event,
    Emitter<EditProfileState> emit,
  ) {
    if (!state.fieldErrors.containsKey(event.field)) return;
    emit(
      state.copyWith(
        fieldErrors: Map.of(state.fieldErrors)..remove(event.field),
      ),
    );
  }

  Future<void> _onSubmitted(
    EditProfileSubmitted event,
    Emitter<EditProfileState> emit,
  ) async {
    emit(
      state.copyWith(
        status: EditProfileStatus.submitting,
        fieldErrors: const {},
      ),
    );
    try {
      final ok = await _profileRemoteDataSource.updateEditProfile(
        name: event.name,
        email: event.email,
        gender: event.gender,
        dateOfBirth: event.dateOfBirth,
        village: event.village,
        address: event.address,
        landAreaHa: event.landAreaHa,
        landOwnership: event.landOwnership,
        blockIds: event.blockIds,
      );
      if (!ok) {
        emit(state.copyWith(status: EditProfileStatus.failure));
        return;
      }
      emit(state.copyWith(status: EditProfileStatus.success));
    } on ValidationException catch (e) {
      emit(
        state.copyWith(
          status: EditProfileStatus.failure,
          errorMessage: e.message,
          fieldErrors: e.fieldErrors,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: EditProfileStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: EditProfileStatus.failure));
    }
  }
}
