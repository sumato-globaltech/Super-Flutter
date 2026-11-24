import 'package:injectable/injectable.dart';
import 'package:super_flutter/data/help_desk/sources/local/help_desk_local_data_source.dart';
import 'package:super_flutter/data/help_desk/sources/remote/help_desk_remote_data_source.dart';

@lazySingleton
class HelpDeskRepositoryImpl {
  const HelpDeskRepositoryImpl(this._remoteDataSource, this._localDataSource);

  // ignore: unused_field
  final HelpDeskRemoteDataSource _remoteDataSource;
  // ignore: unused_field
  final HelpDeskLocalDataSource _localDataSource;
}
