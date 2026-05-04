import 'package:flutter/material.dart';

class AppLocaleController {
  const AppLocaleController._();

  static final ValueNotifier<Locale?> locale = ValueNotifier<Locale?>(null);

  static void useSystem() {
    locale.value = null;
  }

  static void useEnglish() {
    locale.value = const Locale('en');
  }

  static void useSpanish() {
    locale.value = const Locale('es');
  }
}
