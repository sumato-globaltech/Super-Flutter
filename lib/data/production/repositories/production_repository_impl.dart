import 'package:injectable/injectable.dart';
import 'package:super_flutter/data/production/sources/local/production_local_data_source.dart';
import 'package:super_flutter/data/production/sources/remote/production_remote_data_source.dart';

@lazySingleton
class ProductionRepositoryImpl {
  const ProductionRepositoryImpl(this._remoteDataSource, this._localDataSource);

  // ignore: unused_field
  final ProductionRemoteDataSource _remoteDataSource;
  // ignore: unused_field
  final ProductionLocalDataSource _localDataSource;
}
