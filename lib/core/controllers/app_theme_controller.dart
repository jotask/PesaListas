import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemeController {
  const AppThemeController._();

  static const _themeModeKey = 'app_theme_mode';

  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(
    ThemeMode.system,
  );

  static final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  static Future<void> loadSavedThemeMode() async {
    final savedThemeMode = await _preferences.getString(_themeModeKey);

    switch (savedThemeMode) {
      case 'light':
        themeMode.value = ThemeMode.light;
        break;
      case 'dark':
        themeMode.value = ThemeMode.dark;
        break;
      default:
        themeMode.value = ThemeMode.system;
        break;
    }
  }

  static Future<void> useSystem() async {
    await _preferences.remove(_themeModeKey);
    themeMode.value = ThemeMode.system;
  }

  static Future<void> useLight() async {
    await _preferences.setString(_themeModeKey, 'light');
    themeMode.value = ThemeMode.light;
  }

  static Future<void> useDark() async {
    await _preferences.setString(_themeModeKey, 'dark');
    themeMode.value = ThemeMode.dark;
  }
}
