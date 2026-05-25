import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class AppLocalNotificationService {
  const AppLocalNotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _deadlineChannel =
      AndroidNotificationChannel(
        'deadline_reminders',
        'Deadline reminders',
        description: 'Task and chore deadline reminders.',
        importance: Importance.high,
      );

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    await _initializeTimezone();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open PesaListas',
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint('LOCAL NOTIFICATION TAPPED: ${response.payload}');
      },
    );

    await _createAndroidChannels();

    _initialized = true;
  }

  static Future<void> _initializeTimezone() async {
    tz_data.initializeTimeZones();

    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      final timezoneName = timezoneInfo.identifier;

      if (timezoneName.trim().isEmpty) {
        throw StateError('Device timezone name is empty.');
      }

      tz.setLocalLocation(tz.getLocation(timezoneName));

      debugPrint('LOCAL NOTIFICATIONS TIMEZONE: $timezoneName');
    } catch (error, stackTrace) {
      debugPrint('FAILED TO LOAD LOCAL TIMEZONE: $error');
      debugPrintStack(stackTrace: stackTrace);

      tz.setLocalLocation(tz.UTC);
    }
  }

  static Future<void> _createAndroidChannels() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin == null) return;

    await androidPlugin.createNotificationChannel(_deadlineChannel);
  }

  static Future<bool> requestPermission() async {
    final androidGranted = await _requestAndroidPermission();
    final iosGranted = await _requestIosPermission();
    final macosGranted = await _requestMacosPermission();

    return androidGranted && iosGranted && macosGranted;
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

  static Future<bool> _requestMacosPermission() async {
    final macosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();

    if (macosPlugin == null) {
      return true;
    }

    final granted = await macosPlugin.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    return granted ?? false;
  }

  static Future<void> showPushNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await initialize();

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: _notificationDetails(),
      payload: payload,
    );
  }

  static Future<void> showTestNotification() async {
    await initialize();

    await _plugin.show(
      id: 1001,
      title: 'PesaListas notifications are working',
      body: 'This is a local test notification.',
      notificationDetails: _notificationDetails(),
      payload: 'test',
    );
  }

  static Future<void> scheduleTaskDeadlineReminders({
    required String itemId,
    required String title,
    required DateTime deadlineAt,
  }) async {
    await initialize();

    await cancelTaskDeadlineReminders(itemId);

    await _scheduleIfFuture(
      id: _notificationId(itemId, 10),
      scheduledAt: deadlineAt.subtract(const Duration(hours: 1)),
      title: 'Task due soon',
      body: '$title is due in 1 hour.',
      payload: 'task_deadline_soon:$itemId',
    );

    await _scheduleIfFuture(
      id: _notificationId(itemId, 11),
      scheduledAt: deadlineAt,
      title: 'Task due now',
      body: title,
      payload: 'task_deadline_now:$itemId',
    );
  }

  static Future<void> scheduleChoreDueReminders({
    required String itemId,
    required String title,
    required DateTime nextDueAt,
  }) async {
    await initialize();

    await cancelChoreDueReminders(itemId);

    await _scheduleIfFuture(
      id: _notificationId(itemId, 20),
      scheduledAt: nextDueAt.subtract(const Duration(hours: 1)),
      title: 'Chore due soon',
      body: '$title is due in 1 hour.',
      payload: 'chore_due_soon:$itemId',
    );

    await _scheduleIfFuture(
      id: _notificationId(itemId, 21),
      scheduledAt: nextDueAt,
      title: 'Chore due now',
      body: title,
      payload: 'chore_due_now:$itemId',
    );
  }

  static Future<void> cancelItemReminders(String itemId) async {
    await cancelTaskDeadlineReminders(itemId);
    await cancelChoreDueReminders(itemId);
  }

  static Future<void> cancelTaskDeadlineReminders(String itemId) async {
    await initialize();

    await _plugin.cancel(id: _notificationId(itemId, 10));
    await _plugin.cancel(id: _notificationId(itemId, 11));
  }

  static Future<void> cancelChoreDueReminders(String itemId) async {
    await initialize();

    await _plugin.cancel(id: _notificationId(itemId, 20));
    await _plugin.cancel(id: _notificationId(itemId, 21));
  }

  static Future<void> cancelAll() async {
    await initialize();

    await _plugin.cancelAll();
  }

  static Future<List<PendingNotificationRequest>> pendingNotifications() async {
    await initialize();

    return _plugin.pendingNotificationRequests();
  }

  static Future<void> _scheduleIfFuture({
    required int id,
    required DateTime scheduledAt,
    required String title,
    required String body,
    required String payload,
  }) async {
    final localScheduledAt = scheduledAt.toLocal();
    final now = DateTime.now();

    if (!localScheduledAt.isAfter(now)) {
      debugPrint(
        'LOCAL NOTIFICATION SKIPPED: $title at $localScheduledAt is in the past.',
      );
      return;
    }

    final tzScheduledAt = tz.TZDateTime.from(localScheduledAt, tz.local);

    debugPrint(
      'LOCAL NOTIFICATION SCHEDULED: id=$id title=$title at=$tzScheduledAt payload=$payload',
    );

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tzScheduledAt,
      notificationDetails: _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
  }

  static NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'deadline_reminders',
        'Deadline reminders',
        channelDescription: 'Task and chore deadline reminders.',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );
  }

  static int _notificationId(String itemId, int suffix) {
    final input = '$itemId:$suffix';
    var hash = 0x811c9dc5;

    for (final codeUnit in input.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }

    return hash;
  }
}
