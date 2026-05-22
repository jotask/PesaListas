import 'dart:ui' as ui;

import 'package:pesalistas/core/controllers/app_locale_controller.dart';

class AppLanguage {
  const AppLanguage._();

  static String get currentLanguageCode {
    final locale =
        AppLocaleController.locale.value ??
        ui.PlatformDispatcher.instance.locale;

    final code = locale.languageCode.trim().toLowerCase();

    if (code.isEmpty) {
      return 'en';
    }

    return code;
  }

  static String get openLibraryLanguageCode {
    return currentLanguageCode;
  }

  static String get openFoodFactsLanguageCode {
    return currentLanguageCode;
  }

  static String get openFoodFactsCountryCode {
    switch (currentLanguageCode) {
      case 'es':
        return 'es';
      default:
        return 'world';
    }
  }

  static String get tmdbLanguageCode {
    switch (currentLanguageCode) {
      case 'es':
        return 'es-ES';
      case 'en':
      default:
        return 'en-US';
    }
  }
}
