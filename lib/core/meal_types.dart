import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';

class AppMealTypeConfig {
  const AppMealTypeConfig({
    required this.value,
    required this.labelKey,
    required this.icon,
  });

  final String value;
  final String labelKey;
  final IconData icon;

  String label(BuildContext context) {
    switch (labelKey) {
      case 'breakfast':
        return context.l10n.breakfast;
      case 'lunch':
        return context.l10n.lunch;
      case 'dinner':
        return context.l10n.dinner;
      case 'snack':
        return context.l10n.snack;
      default:
        return context.l10n.dinner;
    }
  }
}

class AppMealTypes {
  const AppMealTypes._();

  static const breakfast = 'breakfast';
  static const lunch = 'lunch';
  static const dinner = 'dinner';
  static const snack = 'snack';

  static const all = [
    AppMealTypeConfig(
      value: breakfast,
      labelKey: 'breakfast',
      icon: Icons.free_breakfast_outlined,
    ),
    AppMealTypeConfig(
      value: lunch,
      labelKey: 'lunch',
      icon: Icons.lunch_dining_outlined,
    ),
    AppMealTypeConfig(
      value: dinner,
      labelKey: 'dinner',
      icon: Icons.dinner_dining_outlined,
    ),
    AppMealTypeConfig(
      value: snack,
      labelKey: 'snack',
      icon: Icons.cookie_outlined,
    ),
  ];

  static AppMealTypeConfig fromValue(String? value) {
    for (final config in all) {
      if (config.value == value) return config;
    }

    return all.firstWhere((config) => config.value == dinner);
  }
}
