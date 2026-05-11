import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocaleController {
  const AppLocaleController._();

  static const _localeKey = 'app_locale';

  static final ValueNotifier<Locale?> locale = ValueNotifier<Locale?>(null);

  static final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  static Future<void> loadSavedLocale() async {
    final savedLocale = await _preferences.getString(_localeKey);

    switch (savedLocale) {
      case 'en':
        locale.value = const Locale('en');
        break;
      case 'es':
        locale.value = const Locale('es');
        break;
      default:
        locale.value = null;
        break;
    }
  }

  static Future<void> useSystem() async {
    await _preferences.remove(_localeKey);
    locale.value = null;
  }

  static Future<void> useEnglish() async {
    await _preferences.setString(_localeKey, 'en');
    locale.value = const Locale('en');
  }

  static Future<void> useSpanish() async {
    await _preferences.setString(_localeKey, 'es');
    locale.value = const Locale('es');
  }
}
