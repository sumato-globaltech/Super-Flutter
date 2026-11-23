import 'package:injectable/injectable.dart';
import 'package:super_flutter/data/market/sources/remote/market_remote_data_source.dart';

@lazySingleton
class MarketRepositoryImpl {
  const MarketRepositoryImpl(this._remoteDataSource);

  // ignore: unused_field
  final MarketRemoteDataSource _remoteDataSource;
}
