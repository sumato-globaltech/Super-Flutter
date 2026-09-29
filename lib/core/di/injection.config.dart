// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:super_flutter/app/config/app_config.dart' as _i65;
import 'package:super_flutter/app/config/environment.dart' as _i1067;
import 'package:super_flutter/core/di/app_modules.dart' as _i962;
import 'package:super_flutter/core/di/storage_module.dart' as _i775;
import 'package:super_flutter/core/error/app_error_handler.dart' as _i396;
import 'package:super_flutter/core/error/error_reporter.dart' as _i246;
import 'package:super_flutter/core/logging/app_logger.dart' as _i451;
import 'package:super_flutter/core/network/dio_client.dart' as _i42;
import 'package:super_flutter/core/network/network_module.dart' as _i468;
import 'package:super_flutter/core/network/session_manager.dart' as _i827;
import 'package:super_flutter/core/storage/local_storage.dart' as _i635;
import 'package:super_flutter/core/storage/secure_storage.dart' as _i491;
import 'package:super_flutter/core/storage/storage_service.dart' as _i407;
import 'package:super_flutter/data/auth/repositories/auth_repository_impl.dart'
    as _i227;
import 'package:super_flutter/data/auth/sources/local/auth_local_data_source.dart'
    as _i538;
import 'package:super_flutter/data/auth/sources/remote/auth_remote_data_source.dart'
    as _i234;
import 'package:super_flutter/domain/auth/repositories/auth_repository.dart'
    as _i631;
import 'package:super_flutter/domain/auth/use_cases/check_auth_status.dart'
    as _i236;
import 'package:super_flutter/domain/auth/use_cases/login.dart' as _i489;
import 'package:super_flutter/domain/auth/use_cases/logout.dart' as _i239;
import 'package:super_flutter/features/auth/presentation/login/bloc/login_bloc.dart'
    as _i386;
import 'package:super_flutter/features/auth/session/bloc/auth_cubit.dart'
    as _i828;
import 'package:super_flutter/features/dashboard/presentation/dashboard/bloc/dashboard_bloc.dart'
    as _i930;
import 'package:super_flutter/features/map/presentation/map/bloc/map_screen_cubit.dart'
    as _i679;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final coreModule = _$CoreModule();
    final storageModule = _$StorageModule();
    final networkModule = _$NetworkModule();
    gh.factory<_i679.MapScreenCubit>(() => _i679.MapScreenCubit());
    gh.lazySingleton<_i451.AppLogger>(() => coreModule.logger);
    gh.lazySingleton<_i491.SecureStorage>(() => storageModule.secureStorage());
    gh.lazySingleton<_i1067.Environment>(
      () => coreModule.appEnvironment(gh<_i65.AppConfig>()),
    );
    gh.lazySingleton<_i635.LocalDatabase>(
      () => storageModule.localDatabase(gh<_i1067.Environment>()),
    );
    gh.lazySingleton<_i246.ErrorReporter>(
      () => coreModule.errorReporter(gh<_i451.AppLogger>()),
    );
    gh.lazySingleton<_i407.StorageService>(
      () => storageModule.storageService(
        gh<_i491.SecureStorage>(),
        gh<_i635.LocalDatabase>(),
      ),
    );
    gh.lazySingleton<_i538.AuthLocalDataSource>(
      () => _i538.AuthLocalDataSource(gh<_i407.StorageService>()),
    );
    gh.lazySingleton<_i827.SessionManager>(
      () =>
          _i827.SessionManagerImpl(storageService: gh<_i407.StorageService>()),
    );
    gh.lazySingleton<_i396.AppErrorHandler>(
      () => _i396.AppErrorHandler(gh<_i246.ErrorReporter>()),
    );
    gh.lazySingleton<_i42.DioClient>(
      () => networkModule.dioClient(
        gh<_i1067.Environment>(),
        gh<_i491.SecureStorage>(),
        gh<_i451.AppLogger>(),
        gh<_i827.SessionManager>(),
      ),
    );
    gh.lazySingleton<_i234.AuthRemoteDataSource>(
      () => _i234.AuthRemoteDataSource(gh<_i42.DioClient>()),
    );
    gh.lazySingleton<_i631.AuthRepository>(
      () => _i227.AuthRepositoryImpl(
        gh<_i234.AuthRemoteDataSource>(),
        gh<_i538.AuthLocalDataSource>(),
      ),
    );
    gh.factory<_i236.CheckAuthStatus>(
      () => _i236.CheckAuthStatus(gh<_i631.AuthRepository>()),
    );
    gh.factory<_i489.Login>(() => _i489.Login(gh<_i631.AuthRepository>()));
    gh.factory<_i239.Logout>(() => _i239.Logout(gh<_i631.AuthRepository>()));
    gh.lazySingleton<_i828.AuthCubit>(
      () => _i828.AuthCubit(gh<_i236.CheckAuthStatus>()),
    );
    gh.factory<_i386.LoginBloc>(
      () => _i386.LoginBloc(gh<_i489.Login>(), gh<_i828.AuthCubit>()),
    );
    gh.factory<_i930.DashboardBloc>(
      () => _i930.DashboardBloc(gh<_i239.Logout>(), gh<_i828.AuthCubit>()),
    );
    return this;
  }
}

class _$CoreModule extends _i962.CoreModule {}

class _$StorageModule extends _i775.StorageModule {}

class _$NetworkModule extends _i468.NetworkModule {}
