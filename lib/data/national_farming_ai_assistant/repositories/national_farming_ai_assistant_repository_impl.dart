import 'package:injectable/injectable.dart';
import 'package:super_flutter/data/national_farming_ai_assistant/sources/local/national_farming_ai_assistant_local_data_source.dart';
import 'package:super_flutter/data/national_farming_ai_assistant/sources/remote/national_farming_ai_assistant_remote_data_source.dart';

@lazySingleton
class NationalFarmingAiAssistantRepositoryImpl {
  const NationalFarmingAiAssistantRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
  );

  // ignore: unused_field
  final NationalFarmingAiAssistantRemoteDataSource _remoteDataSource;
  // ignore: unused_field
  final NationalFarmingAiAssistantLocalDataSource _localDataSource;
}
