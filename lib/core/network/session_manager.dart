import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/storage/storage_service.dart';

import '../../features/auth/session/bloc/auth_cubit.dart';

abstract interface class SessionManager {
  Future<void> onSessionExpired();
}

@LazySingleton(as: SessionManager)
class SessionManagerImpl implements SessionManager {
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
