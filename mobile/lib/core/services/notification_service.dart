import 'package:flutter/foundation.dart';
import 'notification_platform_stub.dart'
    if (dart.library.js_interop) 'notification_platform_web.dart';

class NotificationService {
  static Future<bool> requestPermission() async {
    if (!kIsWeb) return true;
    return platformRequestPermission();
  }

  static void showNotification(String title, String body) {
    if (!kIsWeb) return;
    platformShowNotification(title, body);
  }
}
