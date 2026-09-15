import 'package:injectable/injectable.dart' hide Environment;
import 'package:starter/app/config/environment.dart';

import '../storage/local_storage.dart';
import '../storage/secure_storage.dart';
import '../storage/storage_service.dart';

@module
abstract class StorageModule {
  @lazySingleton
  SecureStorage secureStorage() => SecureStorage();

  @lazySingleton
  LocalDatabase localDatabase(Environment environment) =>
      LocalDatabase(name: environment.databaseName);

  @lazySingleton
  StorageService storageService(
    SecureStorage secureStorage,
    LocalDatabase database,
  ) {
    return StorageService(secureStorage: secureStorage, database: database);
  }
}
