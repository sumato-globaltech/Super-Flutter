import 'package:injectable/injectable.dart';
import 'package:starter/core/storage/storage_keys.dart';

import '../storage/local_storage.dart';
import '../storage/secure_storage.dart';
import '../storage/storage_service.dart';

@module
abstract class StorageModule {
  @lazySingleton
  SecureStorage secureStorage() => SecureStorage();

  @lazySingleton
  LocalDatabase localDatabase() =>
      LocalDatabase(name: StorageKeys.localDatabase);

  @lazySingleton
  StorageService storageService(
    SecureStorage secureStorage,
    LocalDatabase database,
  ) {
    return StorageService(secureStorage: secureStorage, database: database);
  }
}
