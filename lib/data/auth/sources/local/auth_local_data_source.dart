import 'dart:convert';

import 'package:injectable/injectable.dart';

import '../../../../core/storage/storage_keys.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../domain/auth/entities/auth_token.dart';
import '../../model/user_model.dart';

@lazySingleton
class AuthLocalDataSource {
  const AuthLocalDataSource(this._storage);

  final StorageService _storage;

  bool get hasSession => _storage.hasSession;

  String? get accessToken => _storage.accessToken;

  Future<void> saveTokens(AuthTokens tokens) {
    return _storage.saveTokens(
      accessToken: tokens.accessToken,
      expiresAt: tokens.expiresAt,
    );
  }

  Future<void> saveUser(UserModel user) {
    return _storage.setSetting(
      StorageKeys.cachedUser,
      jsonEncode(user.toJson()),
    );
  }

  Future<UserModel?> getUser() async {
    final raw = await _storage.getSetting(StorageKeys.cachedUser);
    if (raw == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object {
      return null;
    }
  }

  Future<void> clearSession() {
    return _storage.clearSession();
  }
}
