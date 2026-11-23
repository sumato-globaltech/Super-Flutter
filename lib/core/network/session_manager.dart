import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/storage/storage_service.dart';

abstract interface class SessionManager {
  Stream<void> get expired;

  /// The server refused a request until the password is changed.
  Stream<void> get passwordChangeRequired;

  Future<void> onSessionExpired();

  void onPasswordChangeRequired();
}

@LazySingleton(as: SessionManager)
class SessionManagerImpl implements SessionManager {
  SessionManagerImpl({required this._storageService});

  final StorageService _storageService;
  final _expired = StreamController<void>.broadcast();
  final _passwordChangeRequired = StreamController<void>.broadcast();

  @override
  Stream<void> get expired => _expired.stream;

  @override
  Stream<void> get passwordChangeRequired => _passwordChangeRequired.stream;

  @override
  Future<void> onSessionExpired() async {
    await _storageService.clearSession();
    _expired.add(null);
  }

  @override
  void onPasswordChangeRequired() => _passwordChangeRequired.add(null);
}
