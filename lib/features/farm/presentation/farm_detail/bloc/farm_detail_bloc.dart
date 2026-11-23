import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/data/farm/sources/remote/farm_remote_data_source.dart';
import 'package:super_flutter/data/iot/model/device_model.dart';
import 'package:super_flutter/data/iot/model/soil_sensor_account_model.dart';
import 'package:super_flutter/data/iot/sources/remote/iot_remote_data_source.dart';

import 'farm_detail_event.dart';
import 'farm_detail_state.dart';

@injectable
class FarmDetailBloc extends Bloc<FarmDetailEvent, FarmDetailState> {
  FarmDetailBloc(this._remoteDataSource, [this._iotRemoteDataSource])
    : super(const FarmDetailState()) {
    on<FarmDetailStarted>(_onStarted, transformer: restartable());
    on<FarmDetailRefreshed>(_onRefreshed, transformer: restartable());
    on<FarmArchiveToggled>(_onArchiveToggled);
    on<FarmDeleted>(_onDeleted);
    on<FarmCropAdded>(_onCropAdded);
    on<FarmCropDeleted>(_onCropDeleted);
    on<FarmTransactionAdded>(_onTransactionAdded);
    on<FarmPhotoUploaded>(_onPhotoUploaded);
    on<FarmPhotoDeleted>(_onPhotoDeleted);
    on<FarmDetailTabChanged>(_onTabChanged);
    on<FarmDevicesSyncRequested>(_onDevicesSyncRequested);
    on<FarmSoilSensorAccountLinked>(_onSoilSensorAccountLinked);
    on<FarmSoilSensorAccountUnlinked>(_onSoilSensorAccountUnlinked);
  }

  final FarmRemoteDataSource _remoteDataSource;
  final IotRemoteDataSource? _iotRemoteDataSource;

  Future<void> _loadAll(
    Emitter<FarmDetailState> emit, {
    required String farmId,
  }) async {
    try {
      final results = await Future.wait([
        _remoteDataSource.getFarm(farmId),
        _remoteDataSource.getFarmCrops(farmId),
        _remoteDataSource.getTransactions(farmId, page: 1),
        _remoteDataSource.getTransactionSummary(farmId),
        _remoteDataSource.getPhotos(farmId),
      ]);

      final farm = results[0];
      final crops = results[1];
      final transactionsPaged = results[2];
      final summary = results[3];
      final photos = results[4];

      if (farm == null) {
        emit(
          state.copyWith(
            status: FarmDetailStatus.failure,
            errorMessage: 'Farm not found',
          ),
        );
        return;
      }

      List<DeviceModel> devices = const [];
      SoilSensorAccountModel? soilSensorAccount;
      if (_iotRemoteDataSource != null) {
        try {
          final iotResults = await Future.wait([
            _iotRemoteDataSource.getFarmDevices(farmId),
            _iotRemoteDataSource.getSoilSensorAccount(farmId),
          ]);
          devices = iotResults[0] as List<DeviceModel>;
          soilSensorAccount = iotResults[1] as SoilSensorAccountModel?;
        } catch (_) {
          // Non-fatal if IoT fails to load
        }
      }

      emit(
        state.copyWith(
          status: FarmDetailStatus.success,
          farmId: farmId,
          farm: farm as dynamic,
          crops: crops != null ? (crops as dynamic) : const [],
          transactions: transactionsPaged != null
              ? (transactionsPaged as dynamic).items
              : const [],
          summary: summary as dynamic,
          photos: photos != null ? (photos as dynamic) : const [],
          devices: devices,
          soilSensorAccount: soilSensorAccount,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FarmDetailStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onStarted(
    FarmDetailStarted event,
    Emitter<FarmDetailState> emit,
  ) async {
    emit(
      state.copyWith(status: FarmDetailStatus.loading, farmId: event.farmId),
    );
    await _loadAll(emit, farmId: event.farmId);
  }

  Future<void> _onRefreshed(
    FarmDetailRefreshed event,
    Emitter<FarmDetailState> emit,
  ) async {
    if (state.farmId.isEmpty) return;
    await _loadAll(emit, farmId: state.farmId);
  }

  void _onTabChanged(
    FarmDetailTabChanged event,
    Emitter<FarmDetailState> emit,
  ) {
    emit(state.copyWith(selectedTab: event.index));
  }

  Future<void> _onArchiveToggled(
    FarmArchiveToggled event,
    Emitter<FarmDetailState> emit,
  ) async {
    if (state.farm == null || state.farmId.isEmpty) return;
    emit(state.copyWith(isActionLoading: true));
    try {
      final updated = state.farm!.isActive
          ? await _remoteDataSource.archiveFarm(state.farmId)
          : await _remoteDataSource.unarchiveFarm(state.farmId);
      if (updated != null) {
        emit(state.copyWith(farm: updated, isActionLoading: false));
      } else {
        emit(state.copyWith(isActionLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(isActionLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleted(
    FarmDeleted event,
    Emitter<FarmDetailState> emit,
  ) async {
    if (state.farmId.isEmpty) return;
    emit(state.copyWith(isActionLoading: true));
    try {
      final success = await _remoteDataSource.deleteFarm(state.farmId);
      if (success) {
        emit(state.copyWith(isDeleted: true, isActionLoading: false));
      } else {
        emit(state.copyWith(isActionLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(isActionLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onCropAdded(
    FarmCropAdded event,
    Emitter<FarmDetailState> emit,
  ) async {
    if (state.farmId.isEmpty) return;
    emit(state.copyWith(isActionLoading: true));
    try {
      final crop = await _remoteDataSource.createFarmCrop(
        state.farmId,
        event.data,
      );
      if (crop != null) {
        emit(
          state.copyWith(crops: [crop, ...state.crops], isActionLoading: false),
        );
      } else {
        emit(state.copyWith(isActionLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(isActionLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onCropDeleted(
    FarmCropDeleted event,
    Emitter<FarmDetailState> emit,
  ) async {
    if (state.farmId.isEmpty) return;
    emit(state.copyWith(isActionLoading: true));
    try {
      final success = await _remoteDataSource.deleteFarmCrop(
        state.farmId,
        event.cropId,
      );
      if (success) {
        emit(
          state.copyWith(
            crops: state.crops.where((c) => c.id != event.cropId).toList(),
            isActionLoading: false,
          ),
        );
      } else {
        emit(state.copyWith(isActionLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(isActionLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onTransactionAdded(
    FarmTransactionAdded event,
    Emitter<FarmDetailState> emit,
  ) async {
    if (state.farmId.isEmpty) return;
    emit(state.copyWith(isActionLoading: true));
    try {
      final transaction = await _remoteDataSource.createTransaction(
        state.farmId,
        event.data,
      );
      if (transaction != null) {
        final summary = await _remoteDataSource.getTransactionSummary(
          state.farmId,
        );
        emit(
          state.copyWith(
            transactions: [transaction, ...state.transactions],
            summary: summary,
            isActionLoading: false,
          ),
        );
      } else {
        emit(state.copyWith(isActionLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(isActionLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onPhotoUploaded(
    FarmPhotoUploaded event,
    Emitter<FarmDetailState> emit,
  ) async {
    if (state.farmId.isEmpty) return;
    emit(state.copyWith(isActionLoading: true));
    try {
      final photo = await _remoteDataSource.uploadPhoto(
        state.farmId,
        event.filePath,
      );
      if (photo != null) {
        emit(
          state.copyWith(
            photos: [photo, ...state.photos],
            isActionLoading: false,
          ),
        );
      } else {
        emit(state.copyWith(isActionLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(isActionLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onPhotoDeleted(
    FarmPhotoDeleted event,
    Emitter<FarmDetailState> emit,
  ) async {
    if (state.farmId.isEmpty) return;
    emit(state.copyWith(isActionLoading: true));
    try {
      final success = await _remoteDataSource.deletePhoto(
        state.farmId,
        event.photoId,
      );
      if (success) {
        emit(
          state.copyWith(
            photos: state.photos.where((p) => p.id != event.photoId).toList(),
            isActionLoading: false,
          ),
        );
      } else {
        emit(state.copyWith(isActionLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(isActionLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onDevicesSyncRequested(
    FarmDevicesSyncRequested event,
    Emitter<FarmDetailState> emit,
  ) async {
    if (state.farmId.isEmpty || _iotRemoteDataSource == null) return;
    emit(state.copyWith(isSyncingDevices: true));
    try {
      await _iotRemoteDataSource.syncFarmDevices(state.farmId);
      final devices = await _iotRemoteDataSource.getFarmDevices(state.farmId);
      emit(
        state.copyWith(
          devices: devices,
          isSyncingDevices: false,
          actionSuccessMessage: 'Sync queued successfully',
        ),
      );
    } catch (e) {
      emit(state.copyWith(isSyncingDevices: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onSoilSensorAccountLinked(
    FarmSoilSensorAccountLinked event,
    Emitter<FarmDetailState> emit,
  ) async {
    if (state.farmId.isEmpty || _iotRemoteDataSource == null) return;
    emit(state.copyWith(isActionLoading: true));
    try {
      final account = await _iotRemoteDataSource.linkSoilSensorAccount(
        state.farmId,
        {'username': event.username, 'password': event.password},
      );
      final devices = await _iotRemoteDataSource.getFarmDevices(state.farmId);
      emit(
        state.copyWith(
          soilSensorAccount: account,
          devices: devices,
          isActionLoading: false,
          actionSuccessMessage: 'Soil sensor account linked',
        ),
      );
    } catch (e) {
      emit(state.copyWith(isActionLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onSoilSensorAccountUnlinked(
    FarmSoilSensorAccountUnlinked event,
    Emitter<FarmDetailState> emit,
  ) async {
    if (state.farmId.isEmpty || _iotRemoteDataSource == null) return;
    emit(state.copyWith(isActionLoading: true));
    try {
      await _iotRemoteDataSource.unlinkSoilSensorAccount(state.farmId);
      emit(
        state.copyWith(
          clearSoilSensorAccount: true,
          devices: const [],
          isActionLoading: false,
          actionSuccessMessage: 'Soil sensor account unlinked',
        ),
      );
    } catch (e) {
      emit(state.copyWith(isActionLoading: false, errorMessage: e.toString()));
    }
  }
}
