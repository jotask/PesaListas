import 'package:flutter/foundation.dart';
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

  static Future<void> setEnabled(bool value) async {
    await _save(preferences.value.copyWith(enabled: value));
  }

  static Future<void> setChoreReminders(bool value) async {
    await _save(preferences.value.copyWith(choreReminders: value));
  }

  static Future<void> setMealPlanReminders(bool value) async {
    await _save(preferences.value.copyWith(mealPlanReminders: value));
  }

  static Future<void> setShoppingReminders(bool value) async {
    await _save(preferences.value.copyWith(shoppingReminders: value));
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
