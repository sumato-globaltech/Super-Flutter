import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

typedef PushNote = ({String title, String body});

/// What the app needs from Firebase Messaging.
abstract class PushMessaging {
  /// The platform dam knows this device by; null where push does not work.
  String? get platform;

  Future<bool> askPermission();

  Future<String?> token();

  Future<void> deleteToken();

  Stream<String> get tokenRefreshed;

  Stream<PushNote> get received;

  Stream<PushNote> get opened;

  /// The notification that started the app.
  Future<PushNote?> openedWith();
}

@LazySingleton(as: PushMessaging)
class FirebasePushMessaging implements PushMessaging {
  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  @override
  String? get platform {
    if (kIsWeb || Firebase.apps.isEmpty) return null;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      _ => null,
    };
  }

  @override
  Future<bool> askPermission() async {
    final settings = await _messaging.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  @override
  Future<String?> token() => _messaging.getToken();

  @override
  Future<void> deleteToken() => _messaging.deleteToken();

  @override
  Stream<String> get tokenRefreshed => _messaging.onTokenRefresh;

  @override
  Stream<PushNote> get received => _notes(FirebaseMessaging.onMessage);

  @override
  Stream<PushNote> get opened => _notes(FirebaseMessaging.onMessageOpenedApp);

  @override
  Future<PushNote?> openedWith() async =>
      _note(await _messaging.getInitialMessage());

  Stream<PushNote> _notes(Stream<RemoteMessage> messages) =>
      messages.map(_note).where((note) => note != null).cast<PushNote>();

  PushNote? _note(RemoteMessage? message) {
    final notification = message?.notification;
    if (notification == null) return null;
    final note = (
      title: notification.title?.trim() ?? '',
      body: notification.body?.trim() ?? '',
    );
    return note.title.isEmpty && note.body.isEmpty ? null : note;
  }
}
