import 'package:injectable/injectable.dart';
import 'package:super_flutter/data/support/sources/local/support_local_data_source.dart';
import 'package:super_flutter/data/support/sources/remote/support_remote_data_source.dart';

@lazySingleton
class SupportRepositoryImpl {
  const SupportRepositoryImpl(this._remoteDataSource, this._localDataSource);

  // ignore: unused_field
  final SupportRemoteDataSource _remoteDataSource;
  // ignore: unused_field
  final SupportLocalDataSource _localDataSource;
}
