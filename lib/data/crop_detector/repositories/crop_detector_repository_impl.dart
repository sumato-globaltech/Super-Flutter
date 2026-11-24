import 'package:injectable/injectable.dart';
import 'package:super_flutter/data/crop_detector/sources/local/crop_detector_local_data_source.dart';
import 'package:super_flutter/data/crop_detector/sources/remote/crop_detector_remote_data_source.dart';

@lazySingleton
class CropDetectorRepositoryImpl {
  const CropDetectorRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
  );

  // ignore: unused_field
  final CropDetectorRemoteDataSource _remoteDataSource;
  // ignore: unused_field
  final CropDetectorLocalDataSource _localDataSource;
}
