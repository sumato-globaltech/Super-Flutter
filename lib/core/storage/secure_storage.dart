import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../error/exceptions/cache_exception.dart';
import 'storage_keys.dart';

class SecureStorage {
  SecureStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? _defaultStorage;

  static const _defaultStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      resetOnError: true,
      storageNamespace: StorageKeys.secureNamespace,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  final FlutterSecureStorage _storage;

  String? _accessToken;
  String? _refreshToken;
  DateTime? _expiresAt;

  String? get accessToken => _accessToken;

  String? get refreshToken => _refreshToken;

  DateTime? get expiresAt => _expiresAt;

  bool get isTokenExpired =>
      _expiresAt != null && !DateTime.now().isBefore(_expiresAt!);

  bool get hasSession =>
      _accessToken != null && _accessToken!.isNotEmpty && !isTokenExpired;

  Future<void> restore() async {
    try {
      _accessToken = await _storage.read(key: StorageKeys.accessToken);
      _refreshToken = await _storage.read(key: StorageKeys.refreshToken);
      final rawExpiry = await _storage.read(key: StorageKeys.tokenExpiresAt);
      _expiresAt = rawExpiry == null ? null : DateTime.tryParse(rawExpiry);
    } on Object catch (error) {
      _accessToken = null;
      _refreshToken = null;
      _expiresAt = null;
      throw CacheException('Could not read the stored session.', error);
    }
  }

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
    DateTime? expiresAt,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _expiresAt = expiresAt;
    await Future.wait([
      _storage.write(key: StorageKeys.accessToken, value: accessToken),
      _writeOrDelete(StorageKeys.refreshToken, refreshToken),
      _writeOrDelete(StorageKeys.tokenExpiresAt, expiresAt?.toIso8601String()),
    ]);
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    _expiresAt = null;
    await Future.wait([
      _storage.delete(key: StorageKeys.accessToken),
      _storage.delete(key: StorageKeys.refreshToken),
      _storage.delete(key: StorageKeys.tokenExpiresAt),
    ]);
  }

  Future<void> _writeOrDelete(String key, String? value) => value == null
      ? _storage.delete(key: key)
      : _storage.write(key: key, value: value);

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<void> delete(String key) => _storage.delete(key: key);

  Future<void> clearAll() async {
    _accessToken = null;
    _refreshToken = null;
    _expiresAt = null;
    await _storage.deleteAll();
  }
}
