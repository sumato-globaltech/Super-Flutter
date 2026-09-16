import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:starter/core/storage/storage_service.dart';

import '../../features/auth/session/bloc/auth_cubit.dart';

abstract interface class SessionManager {
  Future<void> onSessionExpired();
}

@LazySingleton(as: SessionManager)
class SessionManagerImpl implements SessionManager {
  // NOTE: AuthCubit is looked up lazily (not constructor-injected) to avoid
  // a DI cycle: AuthCubit -> AuthRepository -> AuthRemoteDataSource ->
  // DioClient -> SessionManager -> AuthCubit. AuthCubit itself is status-only;
  // this only reflects expiry via unauthenticated().
  SessionManagerImpl({required this._storageService});

  final StorageService _storageService;

  @override
  Future<void> onSessionExpired() async {
    await _storageService.clearSession();
    if (GetIt.instance.isRegistered<AuthCubit>()) {
      GetIt.instance<AuthCubit>().unauthenticated();
    }
  }
}
