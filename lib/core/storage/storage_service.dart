import '../error/exceptions/cache_exception.dart';
import 'local_storage.dart';
import 'secure_storage.dart';
import 'storage_keys.dart';

class StorageService {
  const StorageService({
    required this._secureStorage,
    required this._database,
  });
  final SecureStorage _secureStorage;
  final LocalDatabase _database;

  SecureStorage get secure => _secureStorage;

  LocalDatabase get database => _database;

  String? get accessToken => _secureStorage.accessToken;

  String? get refreshToken => _secureStorage.refreshToken;

  bool get hasSession => _secureStorage.hasSession;

  Future<void> restoreSession() async {
    try {
      await _secureStorage.restore();
    } on CacheException {
      await _secureStorage.clearTokens();
    }
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) => _secureStorage.saveTokens(
    accessToken: accessToken,
    refreshToken: refreshToken,
  );

  Future<String?> getSetting(String key) => _database.readSetting(key);

  Future<void> setSetting(String key, String value) =>
      _database.writeSetting(key, value);

  Future<bool> getFlag(String key, {bool defaultValue = false}) async {
    final raw = await _database.readSetting(key);
    if (raw == null) return defaultValue;
    return raw.toLowerCase() == 'true';
  }

  Future<void> setFlag(String key, {required bool value}) =>
      _database.writeSetting(key, '$value');

  Future<String?> get themeMode => getSetting(StorageKeys.themeMode);

  Future<void> setThemeMode(String mode) =>
      setSetting(StorageKeys.themeMode, mode);

  Future<void> clearSession() async {
    await _secureStorage.clearTokens();
    await _database.clearUserData();
  }
}
