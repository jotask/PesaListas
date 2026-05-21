import 'package:flutter/foundation.dart';
import 'package:pesalistas/core/app_local_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppNotificationPreferences {
  const AppNotificationPreferences({
    required this.enabled,
    required this.choreReminders,
    required this.mealPlanReminders,
    required this.shoppingReminders,
  });

  final bool enabled;
  final bool choreReminders;
  final bool mealPlanReminders;
  final bool shoppingReminders;

  static const defaults = AppNotificationPreferences(
    enabled: false,
    choreReminders: true,
    mealPlanReminders: true,
    shoppingReminders: true,
  );

  AppNotificationPreferences copyWith({
    bool? enabled,
    bool? choreReminders,
    bool? mealPlanReminders,
    bool? shoppingReminders,
  }) {
    return AppNotificationPreferences(
      enabled: enabled ?? this.enabled,
      choreReminders: choreReminders ?? this.choreReminders,
      mealPlanReminders: mealPlanReminders ?? this.mealPlanReminders,
      shoppingReminders: shoppingReminders ?? this.shoppingReminders,
    );
  }
}

class AppNotificationController {
  const AppNotificationController._();

  static const _enabledKey = 'notifications_enabled';
  static const _choreRemindersKey = 'notifications_chore_reminders';
  static const _mealPlanRemindersKey = 'notifications_meal_plan_reminders';
  static const _shoppingRemindersKey = 'notifications_shopping_reminders';

  static final ValueNotifier<AppNotificationPreferences> preferences =
      ValueNotifier<AppNotificationPreferences>(
        AppNotificationPreferences.defaults,
      );

  static Future<void> initialize() async {
    await AppLocalNotificationService.initialize();

    final prefs = await SharedPreferences.getInstance();

    preferences.value = AppNotificationPreferences(
      enabled:
          prefs.getBool(_enabledKey) ??
          AppNotificationPreferences.defaults.enabled,
      choreReminders:
          prefs.getBool(_choreRemindersKey) ??
          AppNotificationPreferences.defaults.choreReminders,
      mealPlanReminders:
          prefs.getBool(_mealPlanRemindersKey) ??
          AppNotificationPreferences.defaults.mealPlanReminders,
      shoppingReminders:
          prefs.getBool(_shoppingRemindersKey) ??
          AppNotificationPreferences.defaults.shoppingReminders,
    );
  }

  static Future<bool> setEnabled(bool value) async {
    if (!value) {
      await AppLocalNotificationService.cancelAll();
      await _save(preferences.value.copyWith(enabled: false));
      return true;
    }

    final granted = await AppLocalNotificationService.requestPermission();

    if (!granted) {
      await _save(preferences.value.copyWith(enabled: false));
      return false;
    }

    await _save(preferences.value.copyWith(enabled: true));
    return true;
  }

  static Future<void> setChoreReminders(bool value) async {
    if (!value) {
      await AppLocalNotificationService.cancelAll();
    }

    await _save(preferences.value.copyWith(choreReminders: value));
  }

  static Future<void> setMealPlanReminders(bool value) async {
    await _save(preferences.value.copyWith(mealPlanReminders: value));
  }

  static Future<void> setShoppingReminders(bool value) async {
    await _save(preferences.value.copyWith(shoppingReminders: value));
  }

  static Future<void> showTestNotification() async {
    if (!preferences.value.enabled) {
      final granted = await setEnabled(true);

      if (!granted) {
        return;
      }
    }

    await AppLocalNotificationService.showTestNotification();
  }

  static Future<void> scheduleTaskDeadlineReminders({
    required String itemId,
    required String title,
    required DateTime? deadlineAt,
  }) async {
    if (!preferences.value.enabled) return;

    if (deadlineAt == null) {
      await AppLocalNotificationService.cancelTaskDeadlineReminders(itemId);
      return;
    }

    await AppLocalNotificationService.scheduleTaskDeadlineReminders(
      itemId: itemId,
      title: title,
      deadlineAt: deadlineAt,
    );
  }

  static Future<void> scheduleChoreDueReminders({
    required String itemId,
    required String title,
    required DateTime? nextDueAt,
  }) async {
    if (!preferences.value.enabled || !preferences.value.choreReminders) {
      return;
    }

    if (nextDueAt == null) {
      await AppLocalNotificationService.cancelChoreDueReminders(itemId);
      return;
    }

    await AppLocalNotificationService.scheduleChoreDueReminders(
      itemId: itemId,
      title: title,
      nextDueAt: nextDueAt,
    );
  }

  static Future<void> cancelItemReminders(String itemId) async {
    await AppLocalNotificationService.cancelItemReminders(itemId);
  }

  static Future<void> cancelAllLocalNotifications() async {
    await AppLocalNotificationService.cancelAll();
  }

  static Future<void> _save(AppNotificationPreferences value) async {
    preferences.value = value;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_enabledKey, value.enabled);
    await prefs.setBool(_choreRemindersKey, value.choreReminders);
    await prefs.setBool(_mealPlanRemindersKey, value.mealPlanReminders);
    await prefs.setBool(_shoppingRemindersKey, value.shoppingReminders);
  }
}
