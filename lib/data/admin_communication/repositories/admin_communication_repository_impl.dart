import 'package:injectable/injectable.dart';
import 'package:super_flutter/data/admin_communication/sources/local/admin_communication_local_data_source.dart';
import 'package:super_flutter/data/admin_communication/sources/remote/admin_communication_remote_data_source.dart';

@lazySingleton
class AdminCommunicationRepositoryImpl {
  const AdminCommunicationRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
  );

  // ignore: unused_field
  final AdminCommunicationRemoteDataSource _remoteDataSource;
  // ignore: unused_field
  final AdminCommunicationLocalDataSource _localDataSource;
}
