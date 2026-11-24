import 'package:injectable/injectable.dart';
import 'package:super_flutter/data/farming_assistant/sources/local/farming_assistant_local_data_source.dart';
import 'package:super_flutter/data/farming_assistant/sources/remote/farming_assistant_remote_data_source.dart';

@lazySingleton
class FarmingAssistantRepositoryImpl {
  const FarmingAssistantRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
  );

  // ignore: unused_field
  final FarmingAssistantRemoteDataSource _remoteDataSource;
  // ignore: unused_field
  final FarmingAssistantLocalDataSource _localDataSource;
}
