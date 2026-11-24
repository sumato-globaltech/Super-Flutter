import 'package:injectable/injectable.dart';
import 'package:super_flutter/data/publications/sources/local/publications_local_data_source.dart';
import 'package:super_flutter/data/publications/sources/remote/publications_remote_data_source.dart';

@lazySingleton
class PublicationsRepositoryImpl {
  const PublicationsRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
  );

  // ignore: unused_field
  final PublicationsRemoteDataSource _remoteDataSource;
  // ignore: unused_field
  final PublicationsLocalDataSource _localDataSource;
}
