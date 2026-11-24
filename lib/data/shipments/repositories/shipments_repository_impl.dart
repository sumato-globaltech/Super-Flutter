import 'package:injectable/injectable.dart';
import 'package:super_flutter/data/shipments/sources/local/shipments_local_data_source.dart';
import 'package:super_flutter/data/shipments/sources/remote/shipments_remote_data_source.dart';

@lazySingleton
class ShipmentsRepositoryImpl {
  const ShipmentsRepositoryImpl(this._remoteDataSource, this._localDataSource);

  // ignore: unused_field
  final ShipmentsRemoteDataSource _remoteDataSource;
  // ignore: unused_field
  final ShipmentsLocalDataSource _localDataSource;
}
