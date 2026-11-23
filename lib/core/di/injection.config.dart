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
import 'package:super_flutter/app/startup/app_startup.dart' as _i1066;
import 'package:super_flutter/core/di/app_modules.dart' as _i962;
import 'package:super_flutter/core/di/storage_module.dart' as _i775;
import 'package:super_flutter/core/error/app_error_handler.dart' as _i396;
import 'package:super_flutter/core/error/error_reporter.dart' as _i246;
import 'package:super_flutter/core/logging/app_logger.dart' as _i451;
import 'package:super_flutter/core/network/dio_client.dart' as _i42;
import 'package:super_flutter/core/network/network_module.dart' as _i469;
import 'package:super_flutter/core/network/session_manager.dart' as _i827;
import 'package:super_flutter/core/service/device_info_service.dart' as _i686;
import 'package:super_flutter/core/storage/local_storage.dart' as _i635;
import 'package:super_flutter/core/storage/secure_storage.dart' as _i491;
import 'package:super_flutter/core/storage/storage_service.dart' as _i407;
import 'package:super_flutter/data/auth/repositories/auth_repository_impl.dart'
    as _i227;
import 'package:super_flutter/data/auth/sources/local/auth_local_data_source.dart'
    as _i538;
import 'package:super_flutter/data/auth/sources/remote/auth_remote_data_source.dart'
    as _i234;
import 'package:super_flutter/data/communication/repositories/communication_repository_impl.dart'
    as _i944;
import 'package:super_flutter/data/communication/sources/local/communication_local_data_source.dart'
    as _i940;
import 'package:super_flutter/data/communication/sources/remote/communication_remote_data_source.dart'
    as _i390;
import 'package:super_flutter/data/crops/repositories/crop_repository_impl.dart'
    as _i468;
import 'package:super_flutter/data/crops/sources/remote/crop_remote_data_source.dart'
    as _i444;
import 'package:super_flutter/data/farm/repositories/farm_repository_impl.dart'
    as _i749;
import 'package:super_flutter/data/farm/sources/remote/farm_remote_data_source.dart'
    as _i773;
import 'package:super_flutter/data/market/repositories/market_repository_impl.dart'
    as _i341;
import 'package:super_flutter/data/market/sources/remote/market_remote_data_source.dart'
    as _i1002;
import 'package:super_flutter/domain/auth/repositories/auth_repository.dart'
    as _i631;
import 'package:super_flutter/domain/auth/use_cases/check_auth_status.dart'
    as _i236;
import 'package:super_flutter/domain/auth/use_cases/get_current_user.dart'
    as _i309;
import 'package:super_flutter/domain/auth/use_cases/login.dart' as _i489;
import 'package:super_flutter/domain/auth/use_cases/logout.dart' as _i239;
import 'package:super_flutter/domain/auth/use_cases/password_changed.dart'
    as _i275;
import 'package:super_flutter/domain/auth/use_cases/refresh_user.dart' as _i993;
import 'package:super_flutter/domain/auth/use_cases/request_otp.dart' as _i643;
import 'package:super_flutter/domain/auth/use_cases/verify_otp.dart' as _i625;
import 'package:super_flutter/domain/auth/use_cases/watch_auth_status.dart'
    as _i729;
import 'package:super_flutter/features/auth/presentation/change_password/bloc/change_password_bloc.dart'
    as _i930;
import 'package:super_flutter/features/auth/presentation/login/bloc/login_bloc.dart'
    as _i386;
import 'package:super_flutter/features/auth/session/bloc/auth_cubit.dart'
    as _i828;
import 'package:super_flutter/features/communication/presentation/alerts/bloc/alerts_bloc.dart'
    as _i140;
import 'package:super_flutter/features/communication/presentation/notice_detail/bloc/notice_detail_bloc.dart'
    as _i437;
import 'package:super_flutter/features/communication/presentation/notices/bloc/notices_bloc.dart'
    as _i929;
import 'package:super_flutter/features/crops/presentation/crop_detail/bloc/crop_detail_bloc.dart'
    as _i213;
import 'package:super_flutter/features/crops/presentation/crop_recommendations/bloc/crop_recommendations_bloc.dart'
    as _i977;
import 'package:super_flutter/features/crops/presentation/crops_list/bloc/crops_list_bloc.dart'
    as _i64;
import 'package:super_flutter/features/dashboard/presentation/dashboard/bloc/dashboard_bloc.dart'
    as _i931;
import 'package:super_flutter/features/farm/presentation/farm_detail/bloc/farm_detail_bloc.dart'
    as _i255;
import 'package:super_flutter/features/farm/presentation/farm_form/bloc/farm_form_bloc.dart'
    as _i653;
import 'package:super_flutter/features/farm/presentation/farms_list/bloc/farms_bloc.dart'
    as _i664;
import 'package:super_flutter/features/market/presentation/market/bloc/market_bloc.dart'
    as _i336;
import 'package:super_flutter/features/market/presentation/market_prices/bloc/market_prices_bloc.dart'
    as _i688;

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
    gh.lazySingleton<_i451.AppLogger>(() => coreModule.logger);
    gh.lazySingleton<_i491.SecureStorage>(() => storageModule.secureStorage());
    gh.lazySingleton<_i686.DeviceInfoService>(() => _i686.DeviceInfoService());
    gh.lazySingleton<_i940.CommunicationLocalDataSource>(
      () => _i940.CommunicationLocalDataSource(),
    );
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
      () => _i234.AuthRemoteDataSource(
        gh<_i42.DioClient>(),
        gh<_i686.DeviceInfoService>(),
      ),
    );
    gh.lazySingleton<_i390.CommunicationRemoteDataSource>(
      () => _i390.CommunicationRemoteDataSource(gh<_i42.DioClient>()),
    );
    gh.lazySingleton<_i444.CropRemoteDataSource>(
      () => _i444.CropRemoteDataSource(gh<_i42.DioClient>()),
    );
    gh.lazySingleton<_i773.FarmRemoteDataSource>(
      () => _i773.FarmRemoteDataSource(gh<_i42.DioClient>()),
    );
    gh.lazySingleton<_i1002.MarketRemoteDataSource>(
      () => _i1002.MarketRemoteDataSource(gh<_i42.DioClient>()),
    );
    gh.factory<_i213.CropDetailBloc>(
      () => _i213.CropDetailBloc(gh<_i444.CropRemoteDataSource>()),
    );
    gh.factory<_i977.CropRecommendationsBloc>(
      () => _i977.CropRecommendationsBloc(gh<_i444.CropRemoteDataSource>()),
    );
    gh.factory<_i64.CropsListBloc>(
      () => _i64.CropsListBloc(gh<_i444.CropRemoteDataSource>()),
    );
    gh.lazySingleton<_i468.CropRepositoryImpl>(
      () => _i468.CropRepositoryImpl(gh<_i444.CropRemoteDataSource>()),
    );
    gh.lazySingleton<_i631.AuthRepository>(
      () => _i227.AuthRepositoryImpl(
        gh<_i234.AuthRemoteDataSource>(),
        gh<_i538.AuthLocalDataSource>(),
        gh<_i827.SessionManager>(),
      ),
    );
    gh.factory<_i140.AlertsBloc>(
      () => _i140.AlertsBloc(gh<_i390.CommunicationRemoteDataSource>()),
    );
    gh.factory<_i437.NoticeDetailBloc>(
      () => _i437.NoticeDetailBloc(gh<_i390.CommunicationRemoteDataSource>()),
    );
    gh.factory<_i929.NoticesBloc>(
      () => _i929.NoticesBloc(gh<_i390.CommunicationRemoteDataSource>()),
    );
    gh.factory<_i255.FarmDetailBloc>(
      () => _i255.FarmDetailBloc(gh<_i773.FarmRemoteDataSource>()),
    );
    gh.factory<_i653.FarmFormBloc>(
      () => _i653.FarmFormBloc(gh<_i773.FarmRemoteDataSource>()),
    );
    gh.factory<_i664.FarmsBloc>(
      () => _i664.FarmsBloc(gh<_i773.FarmRemoteDataSource>()),
    );
    gh.lazySingleton<_i749.FarmRepositoryImpl>(
      () => _i749.FarmRepositoryImpl(gh<_i773.FarmRemoteDataSource>()),
    );
    gh.lazySingleton<_i944.CommunicationRepositoryImpl>(
      () => _i944.CommunicationRepositoryImpl(
        gh<_i390.CommunicationRemoteDataSource>(),
        gh<_i940.CommunicationLocalDataSource>(),
      ),
    );
    gh.factory<_i336.MarketBloc>(
      () => _i336.MarketBloc(gh<_i1002.MarketRemoteDataSource>()),
    );
    gh.factory<_i688.MarketPricesBloc>(
      () => _i688.MarketPricesBloc(gh<_i1002.MarketRemoteDataSource>()),
    );
    gh.lazySingleton<_i341.MarketRepositoryImpl>(
      () => _i341.MarketRepositoryImpl(gh<_i1002.MarketRemoteDataSource>()),
    );
    gh.factory<_i236.CheckAuthStatus>(
      () => _i236.CheckAuthStatus(gh<_i631.AuthRepository>()),
    );
    gh.factory<_i309.GetCurrentUser>(
      () => _i309.GetCurrentUser(gh<_i631.AuthRepository>()),
    );
    gh.factory<_i489.Login>(() => _i489.Login(gh<_i631.AuthRepository>()));
    gh.factory<_i239.Logout>(() => _i239.Logout(gh<_i631.AuthRepository>()));
    gh.factory<_i275.PasswordChanged>(
      () => _i275.PasswordChanged(gh<_i631.AuthRepository>()),
    );
    gh.factory<_i993.RefreshUser>(
      () => _i993.RefreshUser(gh<_i631.AuthRepository>()),
    );
    gh.factory<_i643.RequestOtp>(
      () => _i643.RequestOtp(gh<_i631.AuthRepository>()),
    );
    gh.factory<_i625.VerifyOtp>(
      () => _i625.VerifyOtp(gh<_i631.AuthRepository>()),
    );
    gh.factory<_i729.WatchAuthStatus>(
      () => _i729.WatchAuthStatus(gh<_i631.AuthRepository>()),
    );
    gh.factory<_i930.ChangePasswordBloc>(
      () => _i930.ChangePasswordBloc(
        gh<_i234.AuthRemoteDataSource>(),
        gh<_i275.PasswordChanged>(),
        gh<_i239.Logout>(),
      ),
    );
    gh.lazySingleton<_i828.AuthCubit>(
      () => _i828.AuthCubit(
        gh<_i236.CheckAuthStatus>(),
        gh<_i309.GetCurrentUser>(),
        gh<_i729.WatchAuthStatus>(),
        gh<_i993.RefreshUser>(),
      ),
    );
    gh.factory<_i386.LoginBloc>(
      () => _i386.LoginBloc(
        gh<_i489.Login>(),
        gh<_i643.RequestOtp>(),
        gh<_i625.VerifyOtp>(),
      ),
    );
    gh.lazySingleton<_i1066.AppStartup>(
      () => _i1066.AppStartup(
        gh<_i407.StorageService>(),
        gh<_i828.AuthCubit>(),
        gh<_i42.DioClient>(),
        gh<_i451.AppLogger>(),
      ),
    );
    gh.factory<_i931.DashboardBloc>(
      () => _i931.DashboardBloc(
        gh<_i239.Logout>(),
        gh<_i390.CommunicationRemoteDataSource>(),
      ),
    );
    return this;
  }
}

class _$CoreModule extends _i962.CoreModule {}

class _$StorageModule extends _i775.StorageModule {}

class _$NetworkModule extends _i469.NetworkModule {}
