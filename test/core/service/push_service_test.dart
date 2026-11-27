import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/core/error/exceptions/unknown_exception.dart';
import 'package:super_flutter/core/logging/app_logger.dart';
import 'package:super_flutter/core/service/device_info_service.dart';
import 'package:super_flutter/core/service/push_messaging.dart';
import 'package:super_flutter/core/service/push_service.dart';
import 'package:super_flutter/data/communication/sources/remote/communication_remote_data_source.dart';
import 'package:super_flutter/domain/auth/entities/user.dart';
import 'package:super_flutter/domain/auth/repositories/auth_repository.dart';
import 'package:super_flutter/domain/auth/use_cases/logout.dart';
import 'package:super_flutter/features/auth/session/bloc/auth_cubit.dart';
import 'package:super_flutter/features/auth/session/bloc/auth_state.dart';

class _Messaging extends Mock implements PushMessaging {}

class _Auth extends MockCubit<AuthState> implements AuthCubit {}

class _Source extends Mock implements CommunicationRemoteDataSource {}

class _DeviceInfo extends Mock implements DeviceInfoService {}

class _Logger extends Mock implements AppLogger {}

class _Repository extends Mock implements AuthRepository {}

AuthState _signedIn(String id, {bool mustChange = false}) => AuthState(
  status: AuthStatus.authenticated,
  user: User(
    id: id,
    name: 'Vizo',
    email: '',
    passwordChangeRequired: mustChange,
  ),
);

void main() {
  late _Messaging messaging;
  late _Auth auth;
  late _Source source;
  late PushService push;
  late StreamController<AuthState> states;
  late StreamController<String> tokens;
  final created = <(String, String, String?)>[];
  final removed = <String>[];

  setUp(() {
    created.clear();
    removed.clear();
    messaging = _Messaging();
    auth = _Auth();
    source = _Source();
    states = StreamController.broadcast();
    tokens = StreamController.broadcast();
    final info = _DeviceInfo();
    when(info.deviceName).thenAnswer((_) async => 'Google Pixel');
    when(() => messaging.platform).thenReturn('android');
    when(messaging.askPermission).thenAnswer((_) async => true);
    when(messaging.token).thenAnswer((_) async => 'token-1');
    when(messaging.deleteToken).thenAnswer((_) async {});
    when(() => messaging.tokenRefreshed).thenAnswer((_) => tokens.stream);
    when(
      () => source.createDevice(
        token: any(named: 'token'),
        platform: any(named: 'platform'),
        deviceName: any(named: 'deviceName'),
      ),
    ).thenAnswer((call) async {
      created.add((
        call.namedArguments[#token] as String,
        call.namedArguments[#platform] as String,
        call.namedArguments[#deviceName] as String?,
      ));
      return true;
    });
    when(() => source.deleteDevice(token: any(named: 'token'))).thenAnswer((
      call,
    ) async {
      removed.add(call.namedArguments[#token] as String);
      return true;
    });
    push = PushService(messaging, auth, source, info, _Logger());
  });

  Future<void> emit(AuthState state) async {
    when(() => auth.state).thenReturn(state);
    states.add(state);
    await pumpEventQueue();
  }

  Future<void> start(AuthState state) async {
    whenListen(auth, states.stream, initialState: state);
    when(() => auth.state).thenReturn(state);
    push.start();
    await pumpEventQueue();
  }

  test('a signed-in device is registered once', () async {
    await start(_signedIn('u1'));
    await emit(_signedIn('u1'));
    push.start();
    await pumpEventQueue();
    expect(created, [('token-1', 'android', 'Google Pixel')]);
  });

  test('nothing happens without Firebase or on other platforms', () async {
    when(() => messaging.platform).thenReturn(null);
    await start(_signedIn('u1'));
    await push.removeDevice();
    verifyNever(messaging.askPermission);
    expect(created, isEmpty);
    expect(removed, isEmpty);
  });

  test('it waits for a sign-in and for the password to be changed', () async {
    await start(const AuthState());
    await emit(_signedIn('u1', mustChange: true));
    verifyNever(messaging.askPermission);
    await emit(_signedIn('u1'));
    expect(created, hasLength(1));
  });

  test('refusing notifications registers nothing', () async {
    when(messaging.askPermission).thenAnswer((_) async => false);
    await start(_signedIn('u1'));
    expect(created, isEmpty);
    verifyNever(messaging.token);
  });

  test('a new token and a new user are registered again', () async {
    await start(_signedIn('u1'));
    when(messaging.token).thenAnswer((_) async => 'token-2');
    tokens.add('token-2');
    await pumpEventQueue();
    await emit(_signedIn('u2'));
    expect(created.map((call) => call.$1), ['token-1', 'token-2', 'token-2']);
  });

  test('a failed registration is tried again later', () async {
    when(
      () => source.createDevice(
        token: any(named: 'token'),
        platform: any(named: 'platform'),
        deviceName: any(named: 'deviceName'),
      ),
    ).thenThrow(const UnknownException('Offline'));
    await start(_signedIn('u1'));
    await push.removeDevice();
    expect(removed, isEmpty);

    when(
      () => source.createDevice(
        token: any(named: 'token'),
        platform: any(named: 'platform'),
        deviceName: any(named: 'deviceName'),
      ),
    ).thenAnswer((_) async => true);
    await emit(_signedIn('u1'));
    await push.removeDevice();
    expect(removed, ['token-1']);
  });

  test('signing out removes the device first, then its token', () async {
    final repository = _Repository();
    when(() => repository.logout(allDevices: true)).thenAnswer((_) async {
      expect(removed, ['token-1']);
    });
    await start(_signedIn('u1'));
    await Logout(repository, push)(allDevices: true);
    verify(() => repository.logout(allDevices: true)).called(1);
    verifyNever(messaging.deleteToken);

    await emit(const AuthState(status: AuthStatus.unauthenticated));
    verify(messaging.deleteToken).called(1);
    expect(removed, hasLength(1));
  });

  test('signing out works when the device can not be removed', () async {
    final repository = _Repository();
    when(
      () => repository.logout(allDevices: any(named: 'allDevices')),
    ).thenAnswer((_) async {});
    when(
      () => source.deleteDevice(token: any(named: 'token')),
    ).thenThrow(const UnknownException('Offline'));
    await start(_signedIn('u1'));
    await Logout(repository, push)();
    verify(() => repository.logout()).called(1);
  });

  test('an expired session stops the messages', () async {
    await start(_signedIn('u1'));
    await emit(const AuthState(status: AuthStatus.unauthenticated));
    verify(messaging.deleteToken).called(1);
    await emit(_signedIn('u1'));
    expect(created, hasLength(2));
  });
}
