import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/core/network/session_manager.dart';
import 'package:super_flutter/core/storage/storage_service.dart';

class MockStorageService extends Mock implements StorageService {}

void main() {
  late MockStorageService storage;
  late SessionManager sessionManager;

  setUp(() {
    storage = MockStorageService();
    when(() => storage.clearSession()).thenAnswer((_) async {});
    sessionManager = SessionManagerImpl(storageService: storage);
  });

  test('clears session and notifies expiry', () async {
    final expired = expectLater(sessionManager.expired, emits(null));

    await sessionManager.onSessionExpired();

    verify(() => storage.clearSession()).called(1);
    await expired;
  });
}
