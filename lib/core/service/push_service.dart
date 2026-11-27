import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/logging/app_logger.dart';
import 'package:super_flutter/core/service/device_info_service.dart';
import 'package:super_flutter/core/service/push_messaging.dart';
import 'package:super_flutter/data/communication/sources/remote/communication_remote_data_source.dart';
import 'package:super_flutter/features/auth/session/bloc/auth_cubit.dart';
import 'package:super_flutter/features/auth/session/bloc/auth_state.dart';

/// Keeps dam's list of this user's devices right: registered while signed
/// in, removed on sign-out.
@lazySingleton
class PushService {
  PushService(
    this._messaging,
    this._authCubit,
    this._communicationRemoteDataSource,
    this._deviceInfo,
    this._logger,
  );

  static const _removeTimeout = Duration(seconds: 5);

  final PushMessaging _messaging;
  final AuthCubit _authCubit;
  final CommunicationRemoteDataSource _communicationRemoteDataSource;
  final DeviceInfoService _deviceInfo;
  final AppLogger _logger;

  final _subscriptions = <StreamSubscription<void>>[];
  Future<void> _last = Future.value();
  bool _started = false;

  /// The user and token dam already knows.
  (String, String)? _registered;

  void start() {
    if (_started || _messaging.platform == null) return;
    _started = true;
    _subscriptions
      ..add(_authCubit.stream.listen((_) => _sync()))
      ..add(_messaging.tokenRefreshed.listen((_) => _sync()));
    _sync();
  }

  /// Called while still signed in, so the server accepts it.
  Future<void> removeDevice() async {
    if (!_started) return;
    // A slow registration must not hold up signing out.
    await _last.timeout(_removeTimeout, onTimeout: () {});
    final token = _registered?.$2;
    _registered = null;
    if (token == null) return;
    try {
      await _communicationRemoteDataSource
          .deleteDevice(token: token)
          .timeout(_removeTimeout);
    } on Object catch (error) {
      // Dropping the token below stops the messages anyway.
      _logger.warning('This device could not be removed: $error');
    }
  }

  /// One at a time, so a sign-out never overtakes a registration.
  void _sync() => _last = _last.then((_) => _update());

  Future<void> _update() async {
    final auth = _authCubit.state;
    try {
      if (auth.status == AuthStatus.unauthenticated) {
        _registered = null;
        await _messaging.deleteToken();
        return;
      }
      final user = auth.user?.id;
      if (!auth.isAuthenticated || auth.mustChangePassword || user == null) {
        return;
      }
      if (!await _messaging.askPermission()) return;
      final token = await _messaging.token();
      if (token == null || _registered == (user, token)) return;
      final saved = await _communicationRemoteDataSource.createDevice(
        token: token,
        platform: _messaging.platform!,
        deviceName: await _deviceInfo.deviceName(),
      );
      if (saved) _registered = (user, token);
    } on Object catch (error) {
      _logger.warning('This device could not be registered: $error');
    }
  }

  Future<void> dispose() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
  }
}
