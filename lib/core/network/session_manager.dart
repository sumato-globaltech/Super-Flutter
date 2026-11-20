import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/storage/storage_service.dart';

abstract interface class SessionManager {
  Stream<void> get expired;

  Future<void> onSessionExpired();
}

@LazySingleton(as: SessionManager)
class SessionManagerImpl implements SessionManager {
  SessionManagerImpl({required this._storageService});

  final StorageService _storageService;
  final _expired = StreamController<void>.broadcast();

  @override
  Stream<void> get expired => _expired.stream;

  @override
  Future<void> onSessionExpired() async {
    await _storageService.clearSession();
    _expired.add(null);
  }
}
