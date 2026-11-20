import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:material_ui/material_ui.dart';

import 'main_production.dart' as production;

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  debugPrint("📩 Background message received: ${message.messageId}");
  final title = message.notification?.title ?? "Notification";
  final body = message.notification?.body ?? "No content";
  debugPrint("Title: $title, Body: $body");
  final data = message.data;
  if (data.containsKey('updateform') &&
      (data['updateform']?.toString().toLowerCase() == '1')) {}
  debugPrint("📦 Background data: ${message.data}");
}

void main() => production.main();
