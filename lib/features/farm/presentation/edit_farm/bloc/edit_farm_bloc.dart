import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/error/exceptions/validation_exception.dart';
import 'package:super_flutter/data/farm/sources/remote/farm_remote_data_source.dart';

import 'edit_farm_event.dart';
import 'edit_farm_state.dart';

@injectable
class EditFarmBloc extends Bloc<EditFarmEvent, EditFarmState> {
  EditFarmBloc(this._farmRemoteDataSource) : super(const EditFarmState()) {
    on<EditFarmStarted>(_onStarted);
    on<EditFarmFieldErrorCleared>(_onFieldErrorCleared);
    on<EditFarmSubmitted>(_onSubmitted, transformer: droppable());
  }

  final FarmRemoteDataSource _farmRemoteDataSource;

  Future<void> _onStarted(
    EditFarmStarted event,
    Emitter<EditFarmState> emit,
  ) async {
    emit(state.copyWith(loadingOptions: true));
    try {
      final blockOptions = await _farmRemoteDataSource.getBlocks();
      final soilTypeOptions = await _farmRemoteDataSource.getSoilTypes();
      final irrigationTypeOptions = await _farmRemoteDataSource
          .getIrrigationMethods();
      final ownershipOptions = await _farmRemoteDataSource.getLandOwnerships();
      emit(
        state.copyWith(
          loadingOptions: false,
          blockOptions: blockOptions,
          soilTypeOptions: soilTypeOptions,
          irrigationTypeOptions: irrigationTypeOptions,
          ownershipOptions: ownershipOptions,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          loadingOptions: false,
          status: EditFarmStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(loadingOptions: false, status: EditFarmStatus.failure),
      );
    }
  }

  void _onFieldErrorCleared(
    EditFarmFieldErrorCleared event,
    Emitter<EditFarmState> emit,
  ) {
    if (!state.fieldErrors.containsKey(event.field)) return;
    emit(
      state.copyWith(
        fieldErrors: Map.of(state.fieldErrors)..remove(event.field),
      ),
    );
  }

  Future<void> _onSubmitted(
    EditFarmSubmitted event,
    Emitter<EditFarmState> emit,
  ) async {
    emit(
      state.copyWith(status: EditFarmStatus.submitting, fieldErrors: const {}),
    );
    try {
      final ok = await _farmRemoteDataSource.updateFarmDetail(
        event.farm,
        name: event.name,
        areaHa: event.areaHa,
        blockId: event.blockId,
        village: event.village,
        address: event.address,
        soilType: event.soilType,
        irrigationType: event.irrigationType,
        ownership: event.ownership,
        latitude: event.latitude,
        longitude: event.longitude,
      );
      if (!ok) {
        emit(state.copyWith(status: EditFarmStatus.failure));
        return;
      }
      emit(state.copyWith(status: EditFarmStatus.success));
    } on ValidationException catch (e) {
      emit(
        state.copyWith(
          status: EditFarmStatus.failure,
          errorMessage: e.message,
          fieldErrors: e.fieldErrors,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(status: EditFarmStatus.failure, errorMessage: e.message),
      );
    } catch (_) {
      emit(state.copyWith(status: EditFarmStatus.failure));
    }
  }
}
