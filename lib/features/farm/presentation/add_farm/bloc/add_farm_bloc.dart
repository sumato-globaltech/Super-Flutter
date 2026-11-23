import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/error/exceptions/validation_exception.dart';
import 'package:super_flutter/data/farm/sources/remote/farm_remote_data_source.dart';

import 'add_farm_event.dart';
import 'add_farm_state.dart';

@injectable
class AddFarmBloc extends Bloc<AddFarmEvent, AddFarmState> {
  AddFarmBloc(this._farmRemoteDataSource) : super(const AddFarmState()) {
    on<AddFarmStarted>(_onStarted);
    on<AddFarmFieldErrorCleared>(_onFieldErrorCleared);
    on<AddFarmSubmitted>(_onSubmitted, transformer: droppable());
  }

  final FarmRemoteDataSource _farmRemoteDataSource;

  Future<void> _onStarted(
    AddFarmStarted event,
    Emitter<AddFarmState> emit,
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
          status: AddFarmStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(loadingOptions: false, status: AddFarmStatus.failure),
      );
    }
  }

  void _onFieldErrorCleared(
    AddFarmFieldErrorCleared event,
    Emitter<AddFarmState> emit,
  ) {
    if (!state.fieldErrors.containsKey(event.field)) return;
    emit(
      state.copyWith(
        fieldErrors: Map.of(state.fieldErrors)..remove(event.field),
      ),
    );
  }

  Future<void> _onSubmitted(
    AddFarmSubmitted event,
    Emitter<AddFarmState> emit,
  ) async {
    emit(
      state.copyWith(status: AddFarmStatus.submitting, fieldErrors: const {}),
    );
    try {
      final ok = await _farmRemoteDataSource.createFarm(
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
        emit(state.copyWith(status: AddFarmStatus.failure));
        return;
      }
      emit(state.copyWith(status: AddFarmStatus.success));
    } on ValidationException catch (e) {
      emit(
        state.copyWith(
          status: AddFarmStatus.failure,
          errorMessage: e.message,
          fieldErrors: e.fieldErrors,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(status: AddFarmStatus.failure, errorMessage: e.message),
      );
    } catch (_) {
      emit(state.copyWith(status: AddFarmStatus.failure));
    }
  }
}
