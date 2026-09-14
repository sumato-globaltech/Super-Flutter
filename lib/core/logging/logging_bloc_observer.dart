import 'package:bloc/bloc.dart';

import 'app_logger.dart';

class LoggingBlocObserver extends BlocObserver {
  const LoggingBlocObserver(this._logger);

  final AppLogger _logger;

  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);

    _logger.debug(
      '${bloc.runtimeType} created',
      name: 'bloc',
    );
  }

  @override
  void onChange(
      BlocBase<dynamic> bloc,
      Change<dynamic> change,
      ) {
    super.onChange(bloc, change);

    _logger.debug(
      '${bloc.runtimeType}: $change',
      name: 'bloc',
    );
  }

  @override
  void onError(
      BlocBase<dynamic> bloc,
      Object error,
      StackTrace stackTrace,
      ) {
    _logger.error(
      '${bloc.runtimeType} failed',
      name: 'bloc',
      error: error,
      stackTrace: stackTrace,
    );

    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    _logger.debug(
      '${bloc.runtimeType} closed',
      name: 'bloc',
    );

    super.onClose(bloc);
  }
}