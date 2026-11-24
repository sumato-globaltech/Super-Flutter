import 'package:injectable/injectable.dart';
import 'package:super_flutter/data/facilities/sources/local/facilities_local_data_source.dart';
import 'package:super_flutter/data/facilities/sources/remote/facilities_remote_data_source.dart';

@lazySingleton
class FacilitiesRepositoryImpl {
  const FacilitiesRepositoryImpl(this._remoteDataSource, this._localDataSource);

  // ignore: unused_field
  final FacilitiesRemoteDataSource _remoteDataSource;
  // ignore: unused_field
  final FacilitiesLocalDataSource _localDataSource;
}
