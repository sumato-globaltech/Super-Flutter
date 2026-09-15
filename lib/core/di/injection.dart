import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:starter/app/config/app_config.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies(AppConfig config) async {
  if (!getIt.isRegistered<AppConfig>()) {
    getIt.registerSingleton<AppConfig>(config);
  }

  getIt.init();
}
