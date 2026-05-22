import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesalistas/core/app_language.dart';
import 'package:pesalistas/core/controllers/app_locale_controller.dart';

void main() {
  tearDown(() {
    AppLocaleController.locale.value = null;
  });

  group('AppLanguage explicit locale mapping', () {
    test('maps Spanish app locale to Spanish API language/country codes', () {
      AppLocaleController.locale.value = const Locale('es');

      expect(AppLanguage.currentLanguageCode, 'es');
      expect(AppLanguage.openLibraryLanguageCode, 'es');
      expect(AppLanguage.openFoodFactsLanguageCode, 'es');
      expect(AppLanguage.openFoodFactsCountryCode, 'es');
      expect(AppLanguage.tmdbLanguageCode, 'es-ES');
    });

    test('maps English app locale to English/world API codes', () {
      AppLocaleController.locale.value = const Locale('en');

      expect(AppLanguage.currentLanguageCode, 'en');
      expect(AppLanguage.openLibraryLanguageCode, 'en');
      expect(AppLanguage.openFoodFactsLanguageCode, 'en');
      expect(AppLanguage.openFoodFactsCountryCode, 'world');
      expect(AppLanguage.tmdbLanguageCode, 'en-US');
    });

    test(
      'falls back to world country and raw TMDb language for unsupported short codes',
      () {
        AppLocaleController.locale.value = const Locale('fr');

        expect(AppLanguage.currentLanguageCode, 'fr');
        expect(AppLanguage.openFoodFactsCountryCode, 'world');
        expect(AppLanguage.tmdbLanguageCode, 'en-US');
      },
    );
  });
}
