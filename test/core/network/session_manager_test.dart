import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:starter/core/network/session_manager.dart';

import 'package:starter/core/storage/storage_service.dart';
import 'package:starter/features/auth/session/bloc/auth_cubit.dart';

class MockStorageService extends Mock implements StorageService {}

class MockAuthCubit extends Mock implements AuthCubit {}

void main() {
  late MockStorageService storage;
  late MockAuthCubit authCubit;
  late SessionManager sessionManager;

  setUp(() {
    storage = MockStorageService();
    authCubit = MockAuthCubit();

    when(() => storage.clearSession()).thenAnswer((_) async {});
    when(() => authCubit.unauthenticated()).thenReturn(null);

    final getIt = GetIt.instance;
    if (getIt.isRegistered<AuthCubit>()) {
      getIt.unregister<AuthCubit>();
    }
    getIt.registerSingleton<AuthCubit>(authCubit);

    sessionManager = SessionManagerImpl(storageService: storage);
  });

  tearDown(() {
    if (GetIt.instance.isRegistered<AuthCubit>()) {
      GetIt.instance.unregister<AuthCubit>();
    }
  });

  test('clears session and marks auth as unauthenticated', () async {
    // Act
    await sessionManager.onSessionExpired();

    // Assert
    verify(() => storage.clearSession()).called(1);
    verify(() => authCubit.unauthenticated()).called(1);
  });
}
