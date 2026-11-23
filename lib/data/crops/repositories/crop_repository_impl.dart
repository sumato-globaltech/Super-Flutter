import 'package:injectable/injectable.dart';
import 'package:super_flutter/data/crops/sources/remote/crop_remote_data_source.dart';

@lazySingleton
class CropRepositoryImpl {
  const CropRepositoryImpl(this._remoteDataSource);

  // ignore: unused_field
  final CropRemoteDataSource _remoteDataSource;
}
