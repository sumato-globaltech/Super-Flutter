import 'package:injectable/injectable.dart';
import 'package:super_flutter/data/vistaar/sources/local/vistaar_local_data_source.dart';
import 'package:super_flutter/data/vistaar/sources/remote/vistaar_remote_data_source.dart';

@lazySingleton
class VistaarRepositoryImpl {
  const VistaarRepositoryImpl(this._remoteDataSource, this._localDataSource);

  // ignore: unused_field
  final VistaarRemoteDataSource _remoteDataSource;
  // ignore: unused_field
  final VistaarLocalDataSource _localDataSource;
}
