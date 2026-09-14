import 'package:injectable/injectable.dart';
import 'package:starter/core/storage/storage_service.dart';

import '../../features/auth/presentation/bloc/auth_cubit.dart';

abstract interface class SessionManager {
  Future<void> onSessionExpired();
}

@LazySingleton(as: SessionManager)
class SessionManagerImpl implements SessionManager {
  SessionManagerImpl({
    required AuthCubit authCubit,
    required StorageService storageService,
  }) : _authCubit = authCubit,
       _storageService = storageService;

  final AuthCubit _authCubit;
  final StorageService _storageService;

  @override
  Future<void> onSessionExpired() async {
    _storageService.clearSession();
    _authCubit.unauthenticated();
  }
}
