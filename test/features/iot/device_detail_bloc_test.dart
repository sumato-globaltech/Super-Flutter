import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/data/iot/model/device_model.dart';
import 'package:super_flutter/data/iot/model/sensor_history_model.dart';
import 'package:super_flutter/data/iot/sources/remote/iot_remote_data_source.dart';
import 'package:super_flutter/features/iot/presentation/device_detail/bloc/device_detail_bloc.dart';
import 'package:super_flutter/features/iot/presentation/device_detail/bloc/device_detail_event.dart';
import 'package:super_flutter/features/iot/presentation/device_detail/bloc/device_detail_state.dart';

class _MockIotRemoteDataSource extends Mock implements IotRemoteDataSource {}

void main() {
  late _MockIotRemoteDataSource remoteDataSource;

  setUp(() {
    remoteDataSource = _MockIotRemoteDataSource();
  });

  const testDevice = DeviceModel(
    id: 'd1',
    code: 'SS-001',
    name: 'North Field Sensor',
    isOnline: true,
    sensors: [
      DeviceSensorModel(
        id: 's1',
        name: 'Soil Moisture',
        metric: 'soil_moisture',
        unit: '%',
      ),
      DeviceSensorModel(
        id: 's2',
        name: 'Temperature',
        metric: 'temperature',
        unit: '°C',
      ),
    ],
  );

  const testReadings = SensorHistoryModel(
    from: '2026-05-01',
    to: '2026-05-08',
    resolution: 'hourly',
    points: [
      ReadingPointModel(at: '2026-05-01T10:00:00Z', value: 34.5),
      ReadingPointModel(at: '2026-05-02T10:00:00Z', value: 32.1),
    ],
  );

  group('DeviceDetailBloc', () {
    test('initial state has initial status', () {
      final bloc = DeviceDetailBloc(remoteDataSource);
      expect(bloc.state.status, DeviceDetailStatus.initial);
      bloc.close();
    });

    blocTest<DeviceDetailBloc, DeviceDetailState>(
      'loads device and readings for first sensor on DeviceDetailStarted',
      build: () {
        when(() => remoteDataSource.getDevice('d1')).thenAnswer((_) async => testDevice);
        when(() => remoteDataSource.getDeviceReadings(
              'd1',
              sensorId: 's1',
              from: any(named: 'from'),
              to: any(named: 'to'),
            )).thenAnswer((_) async => testReadings);
        return DeviceDetailBloc(remoteDataSource);
      },
      act: (bloc) => bloc.add(const DeviceDetailStarted('d1')),
      expect: () => [
        const DeviceDetailState(
          status: DeviceDetailStatus.loading,
          deviceId: 'd1',
        ),
        const DeviceDetailState(
          status: DeviceDetailStatus.success,
          deviceId: 'd1',
          device: testDevice,
          selectedSensorKey: 's1',
          selectedDays: 7,
        ),
        const DeviceDetailState(
          status: DeviceDetailStatus.success,
          deviceId: 'd1',
          device: testDevice,
          selectedSensorKey: 's1',
          selectedDays: 7,
          isLoadingReadings: true,
        ),
        const DeviceDetailState(
          status: DeviceDetailStatus.success,
          deviceId: 'd1',
          device: testDevice,
          selectedSensorKey: 's1',
          selectedDays: 7,
          isLoadingReadings: false,
          readings: testReadings,
        ),
      ],
    );

    blocTest<DeviceDetailBloc, DeviceDetailState>(
      'loads new readings on DeviceDetailSensorSelected',
      build: () {
        when(() => remoteDataSource.getDeviceReadings(
              'd1',
              sensorId: 's2',
              from: any(named: 'from'),
              to: any(named: 'to'),
            )).thenAnswer((_) async => testReadings);
        return DeviceDetailBloc(remoteDataSource);
      },
      seed: () => const DeviceDetailState(
        status: DeviceDetailStatus.success,
        deviceId: 'd1',
        device: testDevice,
        selectedSensorKey: 's1',
        selectedDays: 7,
      ),
      act: (bloc) => bloc.add(const DeviceDetailSensorSelected('s2')),
      expect: () => [
        const DeviceDetailState(
          status: DeviceDetailStatus.success,
          deviceId: 'd1',
          device: testDevice,
          selectedSensorKey: 's2',
          selectedDays: 7,
        ),
        const DeviceDetailState(
          status: DeviceDetailStatus.success,
          deviceId: 'd1',
          device: testDevice,
          selectedSensorKey: 's2',
          selectedDays: 7,
          isLoadingReadings: true,
        ),
        const DeviceDetailState(
          status: DeviceDetailStatus.success,
          deviceId: 'd1',
          device: testDevice,
          selectedSensorKey: 's2',
          selectedDays: 7,
          isLoadingReadings: false,
          readings: testReadings,
        ),
      ],
    );

    blocTest<DeviceDetailBloc, DeviceDetailState>(
      'loads readings with updated days on DeviceDetailRangeChanged',
      build: () {
        when(() => remoteDataSource.getDeviceReadings(
              'd1',
              sensorId: 's1',
              from: any(named: 'from'),
              to: any(named: 'to'),
            )).thenAnswer((_) async => testReadings);
        return DeviceDetailBloc(remoteDataSource);
      },
      seed: () => const DeviceDetailState(
        status: DeviceDetailStatus.success,
        deviceId: 'd1',
        device: testDevice,
        selectedSensorKey: 's1',
        selectedDays: 7,
      ),
      act: (bloc) => bloc.add(const DeviceDetailRangeChanged(14)),
      expect: () => [
        const DeviceDetailState(
          status: DeviceDetailStatus.success,
          deviceId: 'd1',
          device: testDevice,
          selectedSensorKey: 's1',
          selectedDays: 14,
        ),
        const DeviceDetailState(
          status: DeviceDetailStatus.success,
          deviceId: 'd1',
          device: testDevice,
          selectedSensorKey: 's1',
          selectedDays: 14,
          isLoadingReadings: true,
        ),
        const DeviceDetailState(
          status: DeviceDetailStatus.success,
          deviceId: 'd1',
          device: testDevice,
          selectedSensorKey: 's1',
          selectedDays: 14,
          isLoadingReadings: false,
          readings: testReadings,
        ),
      ],
    );

    blocTest<DeviceDetailBloc, DeviceDetailState>(
      'emits failure when device is null',
      build: () {
        when(() => remoteDataSource.getDevice('d-missing')).thenAnswer((_) async => null);
        return DeviceDetailBloc(remoteDataSource);
      },
      act: (bloc) => bloc.add(const DeviceDetailStarted('d-missing')),
      expect: () => [
        const DeviceDetailState(
          status: DeviceDetailStatus.loading,
          deviceId: 'd-missing',
        ),
        const DeviceDetailState(
          status: DeviceDetailStatus.failure,
          deviceId: 'd-missing',
          errorMessage: 'Device not found',
        ),
      ],
    );
  });
}
