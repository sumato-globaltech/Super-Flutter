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

  String? get accessToken => _accessToken;

  String? get refreshToken => _refreshToken;

  bool get hasSession => _accessToken != null && _refreshToken != null;

  Future<void> restore() async {
    try {
      _accessToken = await _storage.read(key: StorageKeys.accessToken);
      _refreshToken = await _storage.read(key: StorageKeys.refreshToken);
    } on Object catch (error) {
      _accessToken = null;
      _refreshToken = null;
      throw CacheException('Could not read the stored session.', error);
    }
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    await Future.wait([
      _storage.write(key: StorageKeys.accessToken, value: accessToken),
      _storage.write(key: StorageKeys.refreshToken, value: refreshToken),
    ]);
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    await Future.wait([
      _storage.delete(key: StorageKeys.accessToken),
      _storage.delete(key: StorageKeys.refreshToken),
    ]);
  }

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<void> delete(String key) => _storage.delete(key: key);

  Future<void> clearAll() async {
    _accessToken = null;
    _refreshToken = null;
    await _storage.deleteAll();
  }
}
