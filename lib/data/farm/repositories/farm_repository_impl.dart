import 'package:injectable/injectable.dart';
import 'package:super_flutter/data/farm/sources/remote/farm_remote_data_source.dart';

@lazySingleton
class FarmRepositoryImpl {
  const FarmRepositoryImpl(this._remoteDataSource);

  // ignore: unused_field
  final FarmRemoteDataSource _remoteDataSource;
}
