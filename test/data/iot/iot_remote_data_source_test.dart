import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/core/network/dio_client.dart';
import 'package:super_flutter/core/network/network_exception_mapper.dart';
import 'package:super_flutter/data/iot/sources/remote/iot_remote_data_source.dart';

class _MockDio extends Mock implements Dio {}

class _MockDioClient extends Mock implements DioClient {}

void main() {
  late _MockDio dio;
  late _MockDioClient dioClient;
  late IotRemoteDataSource dataSource;

  setUp(() {
    dio = _MockDio();
    dioClient = _MockDioClient();
    when(() => dioClient.dio).thenReturn(dio);
    dataSource = IotRemoteDataSource(dioClient);
  });

  group('IotRemoteDataSource', () {
    test('getFarmDevices parses list of devices with sensors', () async {
      when(() => dio.get('/api/v1/farms/f1/devices')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/v1/farms/f1/devices'),
          statusCode: 200,
          data: {
            'success': true,
            'data': [
              {
                'id': 'd1',
                'code': 'DEV-001',
                'name': 'North Soil Sensor',
                'type': 'soil_sensor',
                'type_label': 'Soil Sensor',
                'provider': 'soilsens',
                'farm_id': 'f1',
                'latitude': 25.6751,
                'longitude': 94.1086,
                'is_online': true,
                'installed_at': '2026-10-01T00:00:00Z',
                'last_reading_at': '2026-11-23T10:00:00Z',
                'sensors': [
                  {
                    'id': 's1',
                    'name': 'Soil Moisture',
                    'metric': 'moisture',
                    'unit': '%',
                    'latest_reading': {
                      'value': 32.5,
                      'quality': 'good',
                      'recorded_at': '2026-11-23T10:00:00Z',
                    },
                  },
                ],
              },
            ],
          },
        ),
      );

      final devices = await dataSource.getFarmDevices('f1');
      expect(devices.length, 1);
      expect(devices.first.id, 'd1');
      expect(devices.first.name, 'North Soil Sensor');
      expect(devices.first.isOnline, true);
      expect(devices.first.sensors.length, 1);
      expect(devices.first.sensors.first.metric, 'moisture');
      expect(devices.first.sensors.first.latestReading?.value, 32.5);
    });

    test('getFarmDevices throws NetworkException on DioException', () async {
      when(() => dio.get('/api/v1/farms/f1/devices')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/v1/farms/f1/devices'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/v1/farms/f1/devices'),
            statusCode: 500,
          ),
        ),
      );

      expect(() => dataSource.getFarmDevices('f1'), throwsA(isA<NetworkException>()));
    });

    test('syncFarmDevices requests sync and parses IntegrationRunModel', () async {
      when(() => dio.post('/api/v1/farms/f1/devices/sync')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/v1/farms/f1/devices/sync'),
          statusCode: 202,
          data: {
            'success': true,
            'message': 'Sync requested.',
            'data': {
              'id': 'run1',
              'status': 'queued',
              'queued_at': '2026-11-23T10:00:00Z',
            },
          },
        ),
      );

      final run = await dataSource.syncFarmDevices('f1');
      expect(run, isNotNull);
      expect(run!.id, 'run1');
      expect(run.status, 'queued');
    });

    test('getSoilSensorAccount returns account model when linked', () async {
      when(() => dio.get('/api/v1/farms/f1/soil-sensor-account')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/v1/farms/f1/soil-sensor-account'),
          statusCode: 200,
          data: {
            'success': true,
            'data': {
              'provider': 'soilsens',
              'username': 'farmer_john',
              'is_active': true,
              'linked_at': '2026-10-01T00:00:00Z',
              'last_synced_at': '2026-11-23T08:00:00Z',
            },
          },
        ),
      );

      final account = await dataSource.getSoilSensorAccount('f1');
      expect(account, isNotNull);
      expect(account!.username, 'farmer_john');
      expect(account.isActive, true);
    });

    test('getSoilSensorAccount returns null when data is null', () async {
      when(() => dio.get('/api/v1/farms/f1/soil-sensor-account')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/v1/farms/f1/soil-sensor-account'),
          statusCode: 200,
          data: {
            'success': true,
            'data': null,
          },
        ),
      );

      final account = await dataSource.getSoilSensorAccount('f1');
      expect(account, isNull);
    });

    test('linkSoilSensorAccount puts credentials and parses updated account', () async {
      when(
        () => dio.put(
          '/api/v1/farms/f1/soil-sensor-account',
          data: {'username': 'new_user', 'password': 'secret'},
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/v1/farms/f1/soil-sensor-account'),
          statusCode: 200,
          data: {
            'success': true,
            'data': {
              'provider': 'soilsens',
              'username': 'new_user',
              'is_active': true,
              'linked_at': '2026-11-23T10:00:00Z',
            },
          },
        ),
      );

      final account = await dataSource.linkSoilSensorAccount(
        'f1',
        {'username': 'new_user', 'password': 'secret'},
      );
      expect(account, isNotNull);
      expect(account!.username, 'new_user');
    });

    test('unlinkSoilSensorAccount deletes credential and returns true', () async {
      when(() => dio.delete('/api/v1/farms/f1/soil-sensor-account')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/v1/farms/f1/soil-sensor-account'),
          statusCode: 200,
          data: {'success': true},
        ),
      );

      final result = await dataSource.unlinkSoilSensorAccount('f1');
      expect(result, true);
    });

    test('getDevice parses single device with sensors', () async {
      when(() => dio.get('/api/v1/devices/d1')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/v1/devices/d1'),
          statusCode: 200,
          data: {
            'success': true,
            'data': {
              'id': 'd1',
              'name': 'North Soil Sensor',
              'code': 'DEV-001',
              'is_online': true,
              'sensors': [
                {
                  'id': 's1',
                  'name': 'Moisture',
                  'metric': 'moisture',
                  'unit': '%',
                },
              ],
            },
          },
        ),
      );

      final device = await dataSource.getDevice('d1');
      expect(device, isNotNull);
      expect(device!.name, 'North Soil Sensor');
      expect(device.sensors.length, 1);
    });

    test('getDeviceReadings sends query and parses SensorHistoryModel', () async {
      when(
        () => dio.get(
          '/api/v1/devices/d1/readings',
          queryParameters: {
            'sensor': 's1',
            'from': '2026-11-16',
            'to': '2026-11-23',
          },
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/v1/devices/d1/readings'),
          statusCode: 200,
          data: {
            'success': true,
            'data': {
              'sensor': {
                'id': 's1',
                'name': 'Soil Moisture',
                'metric': 'moisture',
                'unit': '%',
              },
              'from': '2026-11-16',
              'to': '2026-11-23',
              'resolution': 'day',
              'points': [
                {'at': '2026-11-16T00:00:00Z', 'value': 28.4},
                {'at': '2026-11-17T00:00:00Z', 'value': 29.1},
                {'at': '2026-11-18T00:00:00Z', 'value': 30.5},
              ],
            },
          },
        ),
      );

      final history = await dataSource.getDeviceReadings(
        'd1',
        sensorId: 's1',
        from: '2026-11-16',
        to: '2026-11-23',
      );

      expect(history, isNotNull);
      expect(history!.resolution, 'day');
      expect(history.points.length, 3);
      expect(history.points.first.value, 28.4);
    });
  });
}
