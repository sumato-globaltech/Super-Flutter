import 'package:injectable/injectable.dart';
import 'package:super_flutter/data/meetings/sources/local/meetings_local_data_source.dart';
import 'package:super_flutter/data/meetings/sources/remote/meetings_remote_data_source.dart';

@lazySingleton
class MeetingsRepositoryImpl {
  const MeetingsRepositoryImpl(this._remoteDataSource, this._localDataSource);

  // ignore: unused_field
  final MeetingsRemoteDataSource _remoteDataSource;
  // ignore: unused_field
  final MeetingsLocalDataSource _localDataSource;
}
