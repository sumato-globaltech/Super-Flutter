import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:super_flutter/data/iot/sources/remote/iot_remote_data_source.dart';

import 'device_detail_event.dart';
import 'device_detail_state.dart';

@injectable
class DeviceDetailBloc extends Bloc<DeviceDetailEvent, DeviceDetailState> {
  final IotRemoteDataSource _remoteDataSource;

  DeviceDetailBloc(this._remoteDataSource) : super(const DeviceDetailState()) {
    on<DeviceDetailStarted>(_onStarted, transformer: restartable());
    on<DeviceDetailRefreshed>(_onRefreshed, transformer: restartable());
    on<DeviceDetailSensorSelected>(_onSensorSelected, transformer: restartable());
    on<DeviceDetailRangeChanged>(_onRangeChanged, transformer: restartable());
  }

  Future<void> _onStarted(
    DeviceDetailStarted event,
    Emitter<DeviceDetailState> emit,
  ) async {
    emit(
      state.copyWith(
        status: DeviceDetailStatus.loading,
        deviceId: event.deviceId,
      ),
    );
    try {
      final device = await _remoteDataSource.getDevice(event.deviceId);
      if (device == null) {
        emit(
          state.copyWith(
            status: DeviceDetailStatus.failure,
            errorMessage: 'Device not found',
          ),
        );
        return;
      }

      final initialSensor = device.sensors.isNotEmpty
          ? (device.sensors.first.id ?? device.sensors.first.metric)
          : null;

      emit(
        state.copyWith(
          status: DeviceDetailStatus.success,
          device: device,
          selectedSensorKey: initialSensor,
        ),
      );

      if (initialSensor != null) {
        await _fetchReadings(emit, sensorKey: initialSensor, days: state.selectedDays);
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: DeviceDetailStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onRefreshed(
    DeviceDetailRefreshed event,
    Emitter<DeviceDetailState> emit,
  ) async {
    if (state.deviceId.isEmpty) return;
    try {
      final device = await _remoteDataSource.getDevice(state.deviceId);
      if (device == null) return;
      emit(state.copyWith(device: device));
      if (state.selectedSensorKey != null) {
        await _fetchReadings(
          emit,
          sensorKey: state.selectedSensorKey!,
          days: state.selectedDays,
        );
      }
    } catch (e) {
      // Keep existing data on refresh error
    }
  }

  Future<void> _onSensorSelected(
    DeviceDetailSensorSelected event,
    Emitter<DeviceDetailState> emit,
  ) async {
    if (event.sensorKey == state.selectedSensorKey) return;
    emit(state.copyWith(selectedSensorKey: event.sensorKey));
    await _fetchReadings(emit, sensorKey: event.sensorKey, days: state.selectedDays);
  }

  Future<void> _onRangeChanged(
    DeviceDetailRangeChanged event,
    Emitter<DeviceDetailState> emit,
  ) async {
    if (event.days == state.selectedDays) return;
    emit(state.copyWith(selectedDays: event.days));
    if (state.selectedSensorKey != null) {
      await _fetchReadings(
        emit,
        sensorKey: state.selectedSensorKey!,
        days: event.days,
      );
    }
  }

  Future<void> _fetchReadings(
    Emitter<DeviceDetailState> emit, {
    required String sensorKey,
    required int days,
  }) async {
    emit(state.copyWith(isLoadingReadings: true));
    try {
      final now = DateTime.now();
      final fromDate = now.subtract(Duration(days: days));
      final formatter = DateFormat('yyyy-MM-dd');
      final readings = await _remoteDataSource.getDeviceReadings(
        state.deviceId,
        sensorId: sensorKey,
        from: formatter.format(fromDate),
        to: formatter.format(now),
      );
      emit(
        state.copyWith(
          readings: readings,
          isLoadingReadings: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingReadings: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
