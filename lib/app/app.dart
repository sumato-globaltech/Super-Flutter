import 'dart:async';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    hide GlobalMaterialLocalizations, GlobalCupertinoLocalizations;
import 'package:material_ui/material_ui.dart';
import 'package:super_flutter/app/config/app_config.dart';
import 'package:super_flutter/app/router/app_router.dart';
import 'package:super_flutter/app/router/router_refresh.dart';
import 'package:super_flutter/app/startup/app_startup.dart';
import 'package:super_flutter/core/error/app_error_handler.dart';
import 'package:super_flutter/core/error/error_reporter.dart';
import 'package:super_flutter/core/logging/app_logger.dart';
import 'package:super_flutter/core/logging/logging_bloc_observer.dart';
import 'package:super_flutter/features/auth/session/bloc/auth_cubit.dart';
// sf:app-bloc-imports:begin
import 'package:super_flutter/features/super_awesome/presentation/super_awesome/bloc/super_awesome_bloc.dart';

// sf:app-bloc-imports:end
import '../core/constants/assets_names.dart';
import '../core/di/injection.dart';
import '../core/localization/app_localizations.dart';
import '../core/ui/theme/app_theme.dart';

Future<void> bootstrap(AppConfig config) async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await configureDependencies(config);
      getIt.get<AppErrorHandler>().initialize();
      final appLogger = getIt.get<AppLogger>();
      if (!config.isProduction) {
        Bloc.observer = LoggingBlocObserver(appLogger);
      }
      appLogger.info('Starting ${config.appName} (${config.flavor.name})');
      // The logo is decoded in parallel so the first frame already has it.
      await Future.wait([getIt.get<AppStartup>().run()]);
      runApp(const MyApp());
    },
    (error, stack) {
      getIt.get<ErrorReporter>().report(
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
  late final AppConfig _config = getIt.get<AppConfig>();
  late final GoRouterRefreshStream _authRefresh;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final authCubit = getIt.get<AuthCubit>();
    _authRefresh = GoRouterRefreshStream(authCubit.stream);
    _router = createRouter(
      authCubit: authCubit,
      startup: getIt.get<AppStartup>(),
      config: _config,
      refreshListenable: _authRefresh,
    );
  }

  @override
  void dispose() {
    _router.dispose();
    _authRefresh.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // sf:app-blocs:begin
        BlocProvider(create: (_) => SuperAwesomeBloc()),
        // sf:app-blocs:end
      ],
      child: MaterialApp.router(
        title: _config.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(_config.flavor),
        darkTheme: AppTheme.dark(_config.flavor),
        routerConfig: _router,
        // themeMode: ThemeMode.system,
        // theme: theme,
        // darkTheme: darkTheme,
        localizationsDelegates: [
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
            // color: AppColors.seedFor(_config.flavor),
            child: content,
          );
        },
      ),
    );
  }
}
