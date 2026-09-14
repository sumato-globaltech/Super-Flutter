import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:starter/app/config/app_config.dart';
import 'package:starter/app/router/app_router.dart';
import 'package:starter/core/error/app_error_handler.dart';
import 'package:starter/core/error/error_reporter.dart';
import 'package:starter/core/logging/app_logger.dart';
import 'package:starter/core/logging/logging_bloc_observer.dart';

import '../core/di/injection.dart';
import '../core/localization/app_localizations.dart';
import '../core/storage/storage_service.dart';
import '../core/ui/theme/app_colors.dart';
import '../core/ui/theme/app_theme.dart';
import '../features/auth/presentation/bloc/auth_cubit.dart';

Future<void> bootstrap(AppConfig config) async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await configureDependencies(config);
      getIt<AppErrorHandler>().initialize();

      print('MAIN STARTED');

      final appLogger = getIt.get<AppLogger>();

      appLogger.debug('AppLogger DEBUG TEST');

      appLogger.info('AppLogger INFO TEST');

      appLogger.warning('AppLogger WARNING TEST');

      appLogger.error('AppLogger ERROR TEST');

      // Bloc activity logger
      if (!config.isProduction) {
        Bloc.observer = LoggingBlocObserver(appLogger);
      }

      appLogger.info('Starting ${config.appName} (${config.flavor.name})');

      await getIt<StorageService>().restoreSession();

      runApp(MyApp());

      // todo auth token checking and refreshing
      // unawaited(getIt<AuthRepository>().restoreSession());
    },
    (error, stack) {
      getIt<ErrorReporter>().report(
        error,
        stack,
        reason: 'Uncaught zone error',
      );
    },
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppConfig _config = getIt<AppConfig>();
  late final GoRouter _router;
  late final AuthCubit _authCubit = getIt<AuthCubit>();

  @override
  void initState() {
    super.initState();

    _router = createRouter(authCubit: _authCubit, config: getIt<AppConfig>());

    _authCubit.initialize();
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authCubit,
      child: MaterialApp.router(
        title: _config.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(_config.flavor),
        darkTheme: AppTheme.dark(_config.flavor),
        routerConfig: _router,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) {
          final content = child ?? const SizedBox.shrink();
          if (!_config.environment.showFlavorBanner) return content;
          return Banner(
            message: _config.flavor.label,
            location: BannerLocation.topEnd,
            color: AppColors.seedFor(_config.flavor),
            child: content,
          );
        },
      ),
    );
  }
}
