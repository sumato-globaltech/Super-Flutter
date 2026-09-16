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
import 'package:super_flutter/app/config/app_config.dart' as _i260;
import 'package:super_flutter/app/config/environment.dart' as _i604;
import 'package:super_flutter/core/di/app_modules.dart' as _i361;
import 'package:super_flutter/core/di/storage_module.dart' as _i1056;
import 'package:super_flutter/core/error/app_error_handler.dart' as _i527;
import 'package:super_flutter/core/error/error_reporter.dart' as _i982;
import 'package:super_flutter/core/logging/app_logger.dart' as _i474;
import 'package:super_flutter/core/network/dio_client.dart' as _i806;
import 'package:super_flutter/core/network/network_module.dart' as _i217;
import 'package:super_flutter/core/network/session_manager.dart' as _i708;
import 'package:super_flutter/core/storage/local_storage.dart' as _i915;
import 'package:super_flutter/core/storage/secure_storage.dart' as _i733;
import 'package:super_flutter/core/storage/storage_service.dart' as _i1064;
import 'package:super_flutter/data/auth/repositories/auth_repository_impl.dart'
    as _i459;
import 'package:super_flutter/data/auth/sources/local/auth_local_data_source.dart'
    as _i195;
import 'package:super_flutter/data/auth/sources/remote/auth_remote_data_source.dart'
    as _i701;
import 'package:super_flutter/domain/auth/repositories/auth_repository.dart' as _i902;
import 'package:super_flutter/domain/auth/use_cases/check_auth_status.dart' as _i862;
import 'package:super_flutter/domain/auth/use_cases/login.dart' as _i412;
import 'package:super_flutter/domain/auth/use_cases/logout.dart' as _i605;
import 'package:super_flutter/features/auth/presentation/login/bloc/login_bloc.dart'
    as _i444;
import 'package:super_flutter/features/auth/session/bloc/auth_cubit.dart' as _i477;
import 'package:super_flutter/features/dashboard/presentation/dashboard/bloc/dashboard_bloc.dart'
    as _i6;

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
    gh.lazySingleton<_i474.AppLogger>(() => coreModule.logger);
    gh.lazySingleton<_i733.SecureStorage>(() => storageModule.secureStorage());
    gh.lazySingleton<_i982.ErrorReporter>(
      () => coreModule.errorReporter(gh<_i474.AppLogger>()),
    );
    gh.lazySingleton<_i527.AppErrorHandler>(
      () => _i527.AppErrorHandler(gh<_i982.ErrorReporter>()),
    );
    gh.lazySingleton<_i604.Environment>(
      () => coreModule.appEnvironment(gh<_i260.AppConfig>()),
    );
    gh.lazySingleton<_i915.LocalDatabase>(
      () => storageModule.localDatabase(gh<_i604.Environment>()),
    );
    gh.lazySingleton<_i1064.StorageService>(
      () => storageModule.storageService(
        gh<_i733.SecureStorage>(),
        gh<_i915.LocalDatabase>(),
      ),
    );
    gh.lazySingleton<_i195.AuthLocalDataSource>(
      () => _i195.AuthLocalDataSource(gh<_i1064.StorageService>()),
    );
    gh.lazySingleton<_i708.SessionManager>(
      () =>
          _i708.SessionManagerImpl(storageService: gh<_i1064.StorageService>()),
    );
    gh.lazySingleton<_i806.DioClient>(
      () => networkModule.dioClient(
        gh<_i604.Environment>(),
        gh<_i733.SecureStorage>(),
        gh<_i474.AppLogger>(),
        gh<_i708.SessionManager>(),
      ),
    );
    gh.lazySingleton<_i701.AuthRemoteDataSource>(
      () => _i701.AuthRemoteDataSource(gh<_i806.DioClient>()),
    );
    gh.lazySingleton<_i902.AuthRepository>(
      () => _i459.AuthRepositoryImpl(
        gh<_i701.AuthRemoteDataSource>(),
        gh<_i195.AuthLocalDataSource>(),
      ),
    );
    gh.factory<_i862.CheckAuthStatus>(
      () => _i862.CheckAuthStatus(gh<_i902.AuthRepository>()),
    );
    gh.factory<_i412.Login>(() => _i412.Login(gh<_i902.AuthRepository>()));
    gh.factory<_i605.Logout>(() => _i605.Logout(gh<_i902.AuthRepository>()));
    gh.lazySingleton<_i477.AuthCubit>(
      () => _i477.AuthCubit(gh<_i862.CheckAuthStatus>()),
    );
    gh.factory<_i6.DashboardBloc>(
      () => _i6.DashboardBloc(gh<_i605.Logout>(), gh<_i477.AuthCubit>()),
    );
    gh.factory<_i444.LoginBloc>(
      () => _i444.LoginBloc(gh<_i412.Login>(), gh<_i477.AuthCubit>()),
    );
    return this;
  }
}

class _$CoreModule extends _i361.CoreModule {}

class _$StorageModule extends _i1056.StorageModule {}

class _$NetworkModule extends _i217.NetworkModule {}
