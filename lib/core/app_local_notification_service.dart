import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AppLocalNotificationService {
  const AppLocalNotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings: settings);
  }

  static Future<bool> requestPermission() async {
    final androidGranted = await _requestAndroidPermission();
    final iosGranted = await _requestIosPermission();

    return androidGranted && iosGranted;
  }

  static Future<bool> _requestAndroidPermission() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin == null) {
      return true;
    }

    final granted = await androidPlugin.requestNotificationsPermission();

    return granted ?? false;
  }

  static Future<bool> _requestIosPermission() async {
    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    if (iosPlugin == null) {
      return true;
    }

    final granted = await iosPlugin.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    return granted ?? false;
  }
}
