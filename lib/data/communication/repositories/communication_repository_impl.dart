import 'package:injectable/injectable.dart';
import 'package:super_flutter/data/communication/sources/local/communication_local_data_source.dart';
import 'package:super_flutter/data/communication/sources/remote/communication_remote_data_source.dart';

@lazySingleton
class CommunicationRepositoryImpl {
  const CommunicationRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
  );

  // ignore: unused_field
  final CommunicationRemoteDataSource _remoteDataSource;
  // ignore: unused_field
  final CommunicationLocalDataSource _localDataSource;
}
