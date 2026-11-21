import 'package:injectable/injectable.dart';
import 'package:super_flutter/data/new_post_feature_dep/sources/local/new_post_feature_dep_local_data_source.dart';
import 'package:super_flutter/data/new_post_feature_dep/sources/remote/new_post_feature_dep_remote_data_source.dart';

@lazySingleton
class NewPostFeatureDepRepositoryImpl {
  const NewPostFeatureDepRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
  );

  final NewPostFeatureDepRemoteDataSource _remoteDataSource;
  final NewPostFeatureDepLocalDataSource _localDataSource;
}
