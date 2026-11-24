import 'package:injectable/injectable.dart';
import 'package:super_flutter/data/schemes/sources/local/schemes_local_data_source.dart';
import 'package:super_flutter/data/schemes/sources/remote/schemes_remote_data_source.dart';

@lazySingleton
class SchemesRepositoryImpl {
  const SchemesRepositoryImpl(this._remoteDataSource, this._localDataSource);

  // ignore: unused_field
  final SchemesRemoteDataSource _remoteDataSource;
  // ignore: unused_field
  final SchemesLocalDataSource _localDataSource;
}
