import 'dart:js_interop';

@JS('window.requestNotificationPermission')
external JSPromise<JSBoolean>? _jsRequestNotificationPermission();

@JS('window.showBrowserNotification')
external void _jsShowBrowserNotification(JSString title, JSString body);

Future<bool> platformRequestPermission() async {
  try {
    final promise = _jsRequestNotificationPermission();
    if (promise != null) {
      final result = await promise.toDart;
      return result.toDart;
    }
  } catch (_) {
    // Return true for non-blocking fallback
  }
  return false;
}

void platformShowNotification(String title, String body) {
  try {
    _jsShowBrowserNotification(title.toJS, body.toJS);
  } catch (_) {
    // Non-blocking fallback
  }
}
