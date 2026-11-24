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
import 'package:super_flutter/data/admin_communication/repositories/admin_communication_repository_impl.dart'
    as _i1056;
import 'package:super_flutter/data/admin_communication/sources/local/admin_communication_local_data_source.dart'
    as _i466;
import 'package:super_flutter/data/admin_communication/sources/remote/admin_communication_remote_data_source.dart'
    as _i414;
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
import 'package:super_flutter/data/crop_detector/repositories/crop_detector_repository_impl.dart'
    as _i264;
import 'package:super_flutter/data/crop_detector/sources/local/crop_detector_local_data_source.dart'
    as _i223;
import 'package:super_flutter/data/crop_detector/sources/remote/crop_detector_remote_data_source.dart'
    as _i981;
import 'package:super_flutter/data/crops/repositories/crop_repository_impl.dart'
    as _i468;
import 'package:super_flutter/data/crops/sources/remote/crop_remote_data_source.dart'
    as _i444;
import 'package:super_flutter/data/facilities/repositories/facilities_repository_impl.dart'
    as _i316;
import 'package:super_flutter/data/facilities/sources/local/facilities_local_data_source.dart'
    as _i1048;
import 'package:super_flutter/data/facilities/sources/remote/facilities_remote_data_source.dart'
    as _i610;
import 'package:super_flutter/data/farm/repositories/farm_repository_impl.dart'
    as _i749;
import 'package:super_flutter/data/farm/sources/remote/farm_remote_data_source.dart'
    as _i773;
import 'package:super_flutter/data/farming_assistant/repositories/farming_assistant_repository_impl.dart'
    as _i77;
import 'package:super_flutter/data/farming_assistant/sources/local/farming_assistant_local_data_source.dart'
    as _i214;
import 'package:super_flutter/data/farming_assistant/sources/remote/farming_assistant_remote_data_source.dart'
    as _i254;
import 'package:super_flutter/data/help_desk/repositories/help_desk_repository_impl.dart'
    as _i588;
import 'package:super_flutter/data/help_desk/sources/local/help_desk_local_data_source.dart'
    as _i772;
import 'package:super_flutter/data/help_desk/sources/remote/help_desk_remote_data_source.dart'
    as _i878;
import 'package:super_flutter/data/iot/repositories/iot_repository_impl.dart'
    as _i59;
import 'package:super_flutter/data/iot/sources/remote/iot_remote_data_source.dart'
    as _i17;
import 'package:super_flutter/data/market/repositories/market_repository_impl.dart'
    as _i341;
import 'package:super_flutter/data/market/sources/remote/market_remote_data_source.dart'
    as _i1002;
import 'package:super_flutter/data/meetings/repositories/meetings_repository_impl.dart'
    as _i849;
import 'package:super_flutter/data/meetings/sources/local/meetings_local_data_source.dart'
    as _i496;
import 'package:super_flutter/data/meetings/sources/remote/meetings_remote_data_source.dart'
    as _i133;
import 'package:super_flutter/data/production/repositories/production_repository_impl.dart'
    as _i142;
import 'package:super_flutter/data/production/sources/local/production_local_data_source.dart'
    as _i385;
import 'package:super_flutter/data/production/sources/remote/production_remote_data_source.dart'
    as _i480;
import 'package:super_flutter/data/profile/repositories/profile_repository_impl.dart'
    as _i931;
import 'package:super_flutter/data/profile/sources/local/profile_local_data_source.dart'
    as _i394;
import 'package:super_flutter/data/profile/sources/remote/profile_remote_data_source.dart'
    as _i117;
import 'package:super_flutter/data/schemes/repositories/schemes_repository_impl.dart'
    as _i707;
import 'package:super_flutter/data/schemes/sources/local/schemes_local_data_source.dart'
    as _i1054;
import 'package:super_flutter/data/schemes/sources/remote/schemes_remote_data_source.dart'
    as _i474;
import 'package:super_flutter/data/shipments/repositories/shipments_repository_impl.dart'
    as _i860;
import 'package:super_flutter/data/shipments/sources/local/shipments_local_data_source.dart'
    as _i299;
import 'package:super_flutter/data/shipments/sources/remote/shipments_remote_data_source.dart'
    as _i353;
import 'package:super_flutter/data/support/repositories/support_repository_impl.dart'
    as _i1006;
import 'package:super_flutter/data/support/sources/local/support_local_data_source.dart'
    as _i363;
import 'package:super_flutter/data/support/sources/remote/support_remote_data_source.dart'
    as _i975;
import 'package:super_flutter/data/vistaar/repositories/vistaar_repository_impl.dart'
    as _i432;
import 'package:super_flutter/data/vistaar/sources/local/vistaar_local_data_source.dart'
    as _i813;
import 'package:super_flutter/data/vistaar/sources/remote/vistaar_remote_data_source.dart'
    as _i393;
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
import 'package:super_flutter/features/admin_communication/presentation/add_alert/bloc/add_alert_bloc.dart'
    as _i463;
import 'package:super_flutter/features/admin_communication/presentation/add_notice/bloc/add_notice_bloc.dart'
    as _i486;
import 'package:super_flutter/features/admin_communication/presentation/admin_alerts/bloc/admin_alerts_bloc.dart'
    as _i141;
import 'package:super_flutter/features/admin_communication/presentation/admin_notices/bloc/admin_notices_bloc.dart'
    as _i186;
import 'package:super_flutter/features/admin_communication/presentation/edit_alert/bloc/edit_alert_bloc.dart'
    as _i715;
import 'package:super_flutter/features/admin_communication/presentation/edit_notice/bloc/edit_notice_bloc.dart'
    as _i294;
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
import 'package:super_flutter/features/crop_detector/presentation/crop_detector/bloc/crop_detector_bloc.dart'
    as _i1055;
import 'package:super_flutter/features/crops/presentation/crop_detail/bloc/crop_detail_bloc.dart'
    as _i213;
import 'package:super_flutter/features/crops/presentation/crop_recommendations/bloc/crop_recommendations_bloc.dart'
    as _i977;
import 'package:super_flutter/features/crops/presentation/crops_list/bloc/crops_list_bloc.dart'
    as _i64;
import 'package:super_flutter/features/dashboard/presentation/dashboard/bloc/dashboard_bloc.dart'
    as _i932;
import 'package:super_flutter/features/facilities/presentation/facilities/bloc/facilities_bloc.dart'
    as _i28;
import 'package:super_flutter/features/facilities/presentation/facility_stats/bloc/facility_stats_bloc.dart'
    as _i177;
import 'package:super_flutter/features/farm/presentation/add_farm/bloc/add_farm_bloc.dart'
    as _i461;
import 'package:super_flutter/features/farm/presentation/edit_farm/bloc/edit_farm_bloc.dart'
    as _i288;
import 'package:super_flutter/features/farm/presentation/farm_detail/bloc/farm_detail_bloc.dart'
    as _i255;
import 'package:super_flutter/features/farm/presentation/farms_list/bloc/farms_bloc.dart'
    as _i664;
import 'package:super_flutter/features/farming_assistant/presentation/farming_assistant/bloc/farming_assistant_bloc.dart'
    as _i784;
import 'package:super_flutter/features/help_desk/presentation/queue_summary/bloc/queue_summary_bloc.dart'
    as _i621;
import 'package:super_flutter/features/iot/presentation/device_detail/bloc/device_detail_bloc.dart'
    as _i561;
import 'package:super_flutter/features/market/presentation/market/bloc/market_bloc.dart'
    as _i336;
import 'package:super_flutter/features/market/presentation/market_prices/bloc/market_prices_bloc.dart'
    as _i688;
import 'package:super_flutter/features/meetings/presentation/meetings/bloc/meetings_bloc.dart'
    as _i188;
import 'package:super_flutter/features/production/presentation/production/bloc/production_bloc.dart'
    as _i477;
import 'package:super_flutter/features/profile/presentation/edit_profile/bloc/edit_profile_bloc.dart'
    as _i734;
import 'package:super_flutter/features/profile/presentation/profile/bloc/profile_bloc.dart'
    as _i116;
import 'package:super_flutter/features/schemes/presentation/my_applications/bloc/my_applications_bloc.dart'
    as _i250;
import 'package:super_flutter/features/schemes/presentation/scheme_detail/bloc/scheme_detail_bloc.dart'
    as _i253;
import 'package:super_flutter/features/schemes/presentation/schemes/bloc/schemes_bloc.dart'
    as _i60;
import 'package:super_flutter/features/shipments/presentation/request_shipment/bloc/request_shipment_bloc.dart'
    as _i837;
import 'package:super_flutter/features/shipments/presentation/shipment_detail/bloc/shipment_detail_bloc.dart'
    as _i100;
import 'package:super_flutter/features/shipments/presentation/shipments/bloc/shipments_bloc.dart'
    as _i935;
import 'package:super_flutter/features/support/presentation/create_ticket/bloc/create_ticket_bloc.dart'
    as _i665;
import 'package:super_flutter/features/support/presentation/support/bloc/support_bloc.dart'
    as _i1070;
import 'package:super_flutter/features/support/presentation/ticket_detail/bloc/ticket_detail_bloc.dart'
    as _i247;
import 'package:super_flutter/features/vistaar/presentation/vistaar/bloc/vistaar_bloc.dart'
    as _i653;

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
    gh.lazySingleton<_i466.AdminCommunicationLocalDataSource>(
      () => _i466.AdminCommunicationLocalDataSource(),
    );
    gh.lazySingleton<_i940.CommunicationLocalDataSource>(
      () => _i940.CommunicationLocalDataSource(),
    );
    gh.lazySingleton<_i223.CropDetectorLocalDataSource>(
      () => _i223.CropDetectorLocalDataSource(),
    );
    gh.lazySingleton<_i1048.FacilitiesLocalDataSource>(
      () => _i1048.FacilitiesLocalDataSource(),
    );
    gh.lazySingleton<_i214.FarmingAssistantLocalDataSource>(
      () => _i214.FarmingAssistantLocalDataSource(),
    );
    gh.lazySingleton<_i772.HelpDeskLocalDataSource>(
      () => _i772.HelpDeskLocalDataSource(),
    );
    gh.lazySingleton<_i496.MeetingsLocalDataSource>(
      () => _i496.MeetingsLocalDataSource(),
    );
    gh.lazySingleton<_i385.ProductionLocalDataSource>(
      () => _i385.ProductionLocalDataSource(),
    );
    gh.lazySingleton<_i394.ProfileLocalDataSource>(
      () => _i394.ProfileLocalDataSource(),
    );
    gh.lazySingleton<_i1054.SchemesLocalDataSource>(
      () => _i1054.SchemesLocalDataSource(),
    );
    gh.lazySingleton<_i299.ShipmentsLocalDataSource>(
      () => _i299.ShipmentsLocalDataSource(),
    );
    gh.lazySingleton<_i363.SupportLocalDataSource>(
      () => _i363.SupportLocalDataSource(),
    );
    gh.lazySingleton<_i813.VistaarLocalDataSource>(
      () => _i813.VistaarLocalDataSource(),
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
    gh.lazySingleton<_i414.AdminCommunicationRemoteDataSource>(
      () => _i414.AdminCommunicationRemoteDataSource(gh<_i42.DioClient>()),
    );
    gh.lazySingleton<_i390.CommunicationRemoteDataSource>(
      () => _i390.CommunicationRemoteDataSource(gh<_i42.DioClient>()),
    );
    gh.lazySingleton<_i981.CropDetectorRemoteDataSource>(
      () => _i981.CropDetectorRemoteDataSource(gh<_i42.DioClient>()),
    );
    gh.lazySingleton<_i444.CropRemoteDataSource>(
      () => _i444.CropRemoteDataSource(gh<_i42.DioClient>()),
    );
    gh.lazySingleton<_i610.FacilitiesRemoteDataSource>(
      () => _i610.FacilitiesRemoteDataSource(gh<_i42.DioClient>()),
    );
    gh.lazySingleton<_i773.FarmRemoteDataSource>(
      () => _i773.FarmRemoteDataSource(gh<_i42.DioClient>()),
    );
    gh.lazySingleton<_i254.FarmingAssistantRemoteDataSource>(
      () => _i254.FarmingAssistantRemoteDataSource(gh<_i42.DioClient>()),
    );
    gh.lazySingleton<_i878.HelpDeskRemoteDataSource>(
      () => _i878.HelpDeskRemoteDataSource(gh<_i42.DioClient>()),
    );
    gh.lazySingleton<_i17.IotRemoteDataSource>(
      () => _i17.IotRemoteDataSource(gh<_i42.DioClient>()),
    );
    gh.lazySingleton<_i1002.MarketRemoteDataSource>(
      () => _i1002.MarketRemoteDataSource(gh<_i42.DioClient>()),
    );
    gh.lazySingleton<_i133.MeetingsRemoteDataSource>(
      () => _i133.MeetingsRemoteDataSource(gh<_i42.DioClient>()),
    );
    gh.lazySingleton<_i480.ProductionRemoteDataSource>(
      () => _i480.ProductionRemoteDataSource(gh<_i42.DioClient>()),
    );
    gh.lazySingleton<_i117.ProfileRemoteDataSource>(
      () => _i117.ProfileRemoteDataSource(gh<_i42.DioClient>()),
    );
    gh.lazySingleton<_i474.SchemesRemoteDataSource>(
      () => _i474.SchemesRemoteDataSource(gh<_i42.DioClient>()),
    );
    gh.lazySingleton<_i353.ShipmentsRemoteDataSource>(
      () => _i353.ShipmentsRemoteDataSource(gh<_i42.DioClient>()),
    );
    gh.lazySingleton<_i975.SupportRemoteDataSource>(
      () => _i975.SupportRemoteDataSource(gh<_i42.DioClient>()),
    );
    gh.lazySingleton<_i393.VistaarRemoteDataSource>(
      () => _i393.VistaarRemoteDataSource(gh<_i42.DioClient>()),
    );
    gh.factory<_i188.MeetingsBloc>(
      () => _i188.MeetingsBloc(
        gh<_i133.MeetingsRemoteDataSource>(),
        gh<_i117.ProfileRemoteDataSource>(),
      ),
    );
    gh.factory<_i665.CreateTicketBloc>(
      () => _i665.CreateTicketBloc(gh<_i975.SupportRemoteDataSource>()),
    );
    gh.factory<_i1070.SupportBloc>(
      () => _i1070.SupportBloc(gh<_i975.SupportRemoteDataSource>()),
    );
    gh.factory<_i247.TicketDetailBloc>(
      () => _i247.TicketDetailBloc(gh<_i975.SupportRemoteDataSource>()),
    );
    gh.factory<_i1055.CropDetectorBloc>(
      () => _i1055.CropDetectorBloc(gh<_i981.CropDetectorRemoteDataSource>()),
    );
    gh.lazySingleton<_i849.MeetingsRepositoryImpl>(
      () => _i849.MeetingsRepositoryImpl(
        gh<_i133.MeetingsRemoteDataSource>(),
        gh<_i496.MeetingsLocalDataSource>(),
      ),
    );
    gh.factory<_i116.ProfileBloc>(
      () => _i116.ProfileBloc(gh<_i117.ProfileRemoteDataSource>()),
    );
    gh.factory<_i477.ProductionBloc>(
      () => _i477.ProductionBloc(
        gh<_i480.ProductionRemoteDataSource>(),
        gh<_i444.CropRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i588.HelpDeskRepositoryImpl>(
      () => _i588.HelpDeskRepositoryImpl(
        gh<_i878.HelpDeskRemoteDataSource>(),
        gh<_i772.HelpDeskLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i1006.SupportRepositoryImpl>(
      () => _i1006.SupportRepositoryImpl(
        gh<_i975.SupportRemoteDataSource>(),
        gh<_i363.SupportLocalDataSource>(),
      ),
    );
    gh.factory<_i255.FarmDetailBloc>(
      () => _i255.FarmDetailBloc(
        gh<_i773.FarmRemoteDataSource>(),
        gh<_i17.IotRemoteDataSource>(),
        gh<_i444.CropRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i59.IotRepositoryImpl>(
      () => _i59.IotRepositoryImpl(gh<_i17.IotRemoteDataSource>()),
    );
    gh.factory<_i561.DeviceDetailBloc>(
      () => _i561.DeviceDetailBloc(gh<_i17.IotRemoteDataSource>()),
    );
    gh.lazySingleton<_i77.FarmingAssistantRepositoryImpl>(
      () => _i77.FarmingAssistantRepositoryImpl(
        gh<_i254.FarmingAssistantRemoteDataSource>(),
        gh<_i214.FarmingAssistantLocalDataSource>(),
      ),
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
    gh.factory<_i28.FacilitiesBloc>(
      () => _i28.FacilitiesBloc(
        gh<_i610.FacilitiesRemoteDataSource>(),
        gh<_i133.MeetingsRemoteDataSource>(),
      ),
    );
    gh.factory<_i837.RequestShipmentBloc>(
      () => _i837.RequestShipmentBloc(gh<_i353.ShipmentsRemoteDataSource>()),
    );
    gh.factory<_i100.ShipmentDetailBloc>(
      () => _i100.ShipmentDetailBloc(gh<_i353.ShipmentsRemoteDataSource>()),
    );
    gh.factory<_i935.ShipmentsBloc>(
      () => _i935.ShipmentsBloc(gh<_i353.ShipmentsRemoteDataSource>()),
    );
    gh.factory<_i653.VistaarBloc>(
      () => _i653.VistaarBloc(gh<_i393.VistaarRemoteDataSource>()),
    );
    gh.lazySingleton<_i432.VistaarRepositoryImpl>(
      () => _i432.VistaarRepositoryImpl(
        gh<_i393.VistaarRemoteDataSource>(),
        gh<_i813.VistaarLocalDataSource>(),
      ),
    );
    gh.factory<_i463.AddAlertBloc>(
      () => _i463.AddAlertBloc(gh<_i414.AdminCommunicationRemoteDataSource>()),
    );
    gh.factory<_i486.AddNoticeBloc>(
      () => _i486.AddNoticeBloc(gh<_i414.AdminCommunicationRemoteDataSource>()),
    );
    gh.factory<_i141.AdminAlertsBloc>(
      () =>
          _i141.AdminAlertsBloc(gh<_i414.AdminCommunicationRemoteDataSource>()),
    );
    gh.factory<_i186.AdminNoticesBloc>(
      () => _i186.AdminNoticesBloc(
        gh<_i414.AdminCommunicationRemoteDataSource>(),
      ),
    );
    gh.factory<_i715.EditAlertBloc>(
      () => _i715.EditAlertBloc(gh<_i414.AdminCommunicationRemoteDataSource>()),
    );
    gh.factory<_i294.EditNoticeBloc>(
      () =>
          _i294.EditNoticeBloc(gh<_i414.AdminCommunicationRemoteDataSource>()),
    );
    gh.lazySingleton<_i931.ProfileRepositoryImpl>(
      () => _i931.ProfileRepositoryImpl(
        gh<_i117.ProfileRemoteDataSource>(),
        gh<_i394.ProfileLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i631.AuthRepository>(
      () => _i227.AuthRepositoryImpl(
        gh<_i234.AuthRemoteDataSource>(),
        gh<_i538.AuthLocalDataSource>(),
        gh<_i827.SessionManager>(),
      ),
    );
    gh.factory<_i250.MyApplicationsBloc>(
      () => _i250.MyApplicationsBloc(gh<_i474.SchemesRemoteDataSource>()),
    );
    gh.factory<_i253.SchemeDetailBloc>(
      () => _i253.SchemeDetailBloc(gh<_i474.SchemesRemoteDataSource>()),
    );
    gh.factory<_i60.SchemesBloc>(
      () => _i60.SchemesBloc(gh<_i474.SchemesRemoteDataSource>()),
    );
    gh.lazySingleton<_i707.SchemesRepositoryImpl>(
      () => _i707.SchemesRepositoryImpl(
        gh<_i474.SchemesRemoteDataSource>(),
        gh<_i1054.SchemesLocalDataSource>(),
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
    gh.lazySingleton<_i142.ProductionRepositoryImpl>(
      () => _i142.ProductionRepositoryImpl(
        gh<_i480.ProductionRemoteDataSource>(),
        gh<_i385.ProductionLocalDataSource>(),
      ),
    );
    gh.factory<_i664.FarmsBloc>(
      () => _i664.FarmsBloc(gh<_i773.FarmRemoteDataSource>()),
    );
    gh.lazySingleton<_i749.FarmRepositoryImpl>(
      () => _i749.FarmRepositoryImpl(gh<_i773.FarmRemoteDataSource>()),
    );
    gh.factory<_i621.QueueSummaryBloc>(
      () => _i621.QueueSummaryBloc(gh<_i878.HelpDeskRemoteDataSource>()),
    );
    gh.lazySingleton<_i944.CommunicationRepositoryImpl>(
      () => _i944.CommunicationRepositoryImpl(
        gh<_i390.CommunicationRemoteDataSource>(),
        gh<_i940.CommunicationLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i316.FacilitiesRepositoryImpl>(
      () => _i316.FacilitiesRepositoryImpl(
        gh<_i610.FacilitiesRemoteDataSource>(),
        gh<_i1048.FacilitiesLocalDataSource>(),
      ),
    );
    gh.factory<_i177.FacilityStatsBloc>(
      () => _i177.FacilityStatsBloc(gh<_i610.FacilitiesRemoteDataSource>()),
    );
    gh.lazySingleton<_i860.ShipmentsRepositoryImpl>(
      () => _i860.ShipmentsRepositoryImpl(
        gh<_i353.ShipmentsRemoteDataSource>(),
        gh<_i299.ShipmentsLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i264.CropDetectorRepositoryImpl>(
      () => _i264.CropDetectorRepositoryImpl(
        gh<_i981.CropDetectorRemoteDataSource>(),
        gh<_i223.CropDetectorLocalDataSource>(),
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
    gh.factory<_i784.FarmingAssistantBloc>(
      () => _i784.FarmingAssistantBloc(
        gh<_i254.FarmingAssistantRemoteDataSource>(),
      ),
    );
    gh.factory<_i734.EditProfileBloc>(
      () => _i734.EditProfileBloc(
        gh<_i117.ProfileRemoteDataSource>(),
        gh<_i773.FarmRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i1056.AdminCommunicationRepositoryImpl>(
      () => _i1056.AdminCommunicationRepositoryImpl(
        gh<_i414.AdminCommunicationRemoteDataSource>(),
        gh<_i466.AdminCommunicationLocalDataSource>(),
      ),
    );
    gh.factory<_i461.AddFarmBloc>(
      () => _i461.AddFarmBloc(gh<_i773.FarmRemoteDataSource>()),
    );
    gh.factory<_i288.EditFarmBloc>(
      () => _i288.EditFarmBloc(gh<_i773.FarmRemoteDataSource>()),
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
    gh.factory<_i932.DashboardBloc>(
      () => _i932.DashboardBloc(
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
