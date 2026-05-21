import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pesalistas/core/app_local_notification_service.dart';
import 'package:pesalistas/repositories/notification_device_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppPushNotificationService {
  const AppPushNotificationService._();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('FCM MESSAGE OPENED: ${message.messageId}');
      debugPrint('FCM DATA: ${message.data}');
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      debugPrint('FCM TOKEN REFRESHED: ${_maskToken(token)}');

      await syncToken(token: token);
    });

    _initialized = true;
  }

  static SupabaseClient? _trySupabaseClient() {
    try {
      return Supabase.instance.client;
    } catch (error) {
      debugPrint('SUPABASE CLIENT NOT READY FOR FCM: $error');
      return null;
    }
  }

  static Future<bool> requestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint(
      'FCM AUTHORIZATION STATUS: ${settings.authorizationStatus.name}',
    );

    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  static Future<void> syncCurrentDevice() async {
    await initialize();

    final client = _trySupabaseClient();

    if (client == null) {
      debugPrint('FCM TOKEN SYNC SKIPPED: Supabase is not initialized yet.');
      return;
    }

    final user = client.auth.currentUser;

    if (user == null) {
      debugPrint('FCM TOKEN SYNC SKIPPED: no signed-in user.');
      return;
    }

    final granted = await requestPermission();

    if (!granted) {
      debugPrint(
        'FCM TOKEN SYNC SKIPPED: notification permission not granted.',
      );
      return;
    }

    final token = await FirebaseMessaging.instance.getToken();

    if (token == null || token.trim().isEmpty) {
      debugPrint('FCM TOKEN SYNC SKIPPED: token is empty.');
      return;
    }

    await syncToken(token: token);
  }

  static Future<void> syncToken({required String token}) async {
    final client = _trySupabaseClient();

    if (client == null) {
      debugPrint('FCM TOKEN SAVE SKIPPED: Supabase is not initialized yet.');
      return;
    }

    final user = client.auth.currentUser;

    if (user == null) {
      debugPrint('FCM TOKEN SAVE SKIPPED: no signed-in user.');
      return;
    }

    final packageInfo = await PackageInfo.fromPlatform();

    final repository = NotificationDeviceRepository(client);

    await repository.upsertCurrentDeviceToken(
      fcmToken: token,
      platform: _platformName(),
      appVersion: '${packageInfo.version}+${packageInfo.buildNumber}',
    );

    debugPrint('FCM TOKEN SAVED: ${_maskToken(token)}');
  }

  static Future<void> unregisterCurrentDevice() async {
    final token = await FirebaseMessaging.instance.getToken();

    if (token == null || token.trim().isEmpty) {
      return;
    }

    final client = _trySupabaseClient();

    if (client == null) {
      debugPrint('FCM TOKEN DISABLE SKIPPED: Supabase is not initialized yet.');
      return;
    }

    final repository = NotificationDeviceRepository(client);

    await repository.disableCurrentDeviceToken(token);

    debugPrint('FCM TOKEN DISABLED: ${_maskToken(token)}');
  }

  static Future<Map<String, dynamic>> sendTestPush() async {
    final client = _trySupabaseClient();

    if (client == null) {
      throw StateError('Supabase is not initialized yet.');
    }

    final response = await client.functions.invoke(
      'send-test-push',
      body: <String, dynamic>{},
    );

    final data = _asMap(response.data);

    if (response.status < 200 || response.status >= 300) {
      throw Exception(
        data['error']?.toString() ??
            'send-test-push failed with status ${response.status}.',
      );
    }

    return data;
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return {'value': value?.toString()};
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('FCM FOREGROUND MESSAGE: ${message.messageId}');
    debugPrint('FCM DATA: ${message.data}');

    final notification = message.notification;
    final title = notification?.title ?? message.data['title']?.toString();
    final body = notification?.body ?? message.data['body']?.toString();

    if (title == null || title.trim().isEmpty) {
      return;
    }

    await AppLocalNotificationService.showPushNotification(
      id: _messageNotificationId(message),
      title: title,
      body: body ?? '',
      payload: message.data.toString(),
    );
  }

  static int _messageNotificationId(RemoteMessage message) {
    final input =
        message.messageId ?? message.sentTime?.toIso8601String() ?? '';

    if (input.isEmpty) {
      return DateTime.now().millisecondsSinceEpoch.remainder(2147483647);
    }

    var hash = 0x811c9dc5;

    for (final codeUnit in input.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }

    return hash;
  }

  static String _platformName() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.linux:
        return 'linux';
      case TargetPlatform.fuchsia:
        return 'fuchsia';
    }
  }

  static String _maskToken(String token) {
    final value = token.trim();

    if (value.length <= 12) {
      return 'configured';
    }

    return '${value.substring(0, 6)}…${value.substring(value.length - 6)}';
  }
}
