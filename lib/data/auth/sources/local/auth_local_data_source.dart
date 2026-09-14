import 'package:injectable/injectable.dart';

import '../../../../core/storage/storage_service.dart';

@lazySingleton
class AuthLocalDataSource {
  const AuthLocalDataSource(this._storage);

  final StorageService _storage;

  bool get hasSession => _storage.hasSession;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) {
    return _storage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  Future<void> clearSession() {
    return _storage.clearSession();
  }

  String? get accessToken => _storage.accessToken;

  String? get refreshToken => _storage.refreshToken;
}
