import 'package:injectable/injectable.dart';
import 'package:super_flutter/data/profile/sources/local/profile_local_data_source.dart';
import 'package:super_flutter/data/profile/sources/remote/profile_remote_data_source.dart';

@lazySingleton
class ProfileRepositoryImpl {
  const ProfileRepositoryImpl(this._remoteDataSource, this._localDataSource);

  // ignore: unused_field
  final ProfileRemoteDataSource _remoteDataSource;
  // ignore: unused_field
  final ProfileLocalDataSource _localDataSource;
}
