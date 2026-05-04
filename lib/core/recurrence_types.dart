import 'package:flutter/widgets.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';

class AppRecurrenceConfig {
  const AppRecurrenceConfig({
    required this.value,
    required this.labelKey,
    required this.descriptionKey,
  });

  final String? value;
  final String labelKey;
  final String descriptionKey;

  String label(BuildContext context) {
    switch (labelKey) {
      case 'none':
        return context.l10n.none;
      case 'daily':
        return context.l10n.daily;
      case 'weekly':
        return context.l10n.weekly;
      case 'monthly':
        return context.l10n.monthly;
      case 'everyNDays':
        return context.l10n.everyNDays;
      default:
        return context.l10n.none;
    }
  }

  String description(BuildContext context) {
    switch (descriptionKey) {
      case 'doesNotRepeat2':
        return context.l10n.doesNotRepeat2;
      case 'repeatsEveryDay':
        return context.l10n.repeatsEveryDay;
      case 'repeatsEveryWeek':
        return context.l10n.repeatsEveryWeek;
      case 'repeatsEveryMonth':
        return context.l10n.repeatsEveryMonth;
      case 'repeatsAfterACustomNumberOfDays':
        return context.l10n.repeatsAfterACustomNumberOfDays;
      default:
        return context.l10n.doesNotRepeat2;
    }
  }
}

class AppRecurrenceTypes {
  const AppRecurrenceTypes._();

  static const none = AppRecurrenceConfig(
    value: null,
    labelKey: 'none',
    descriptionKey: 'doesNotRepeat2',
  );

  static const daily = AppRecurrenceConfig(
    value: 'daily',
    labelKey: 'daily',
    descriptionKey: 'repeatsEveryDay',
  );

  static const weekly = AppRecurrenceConfig(
    value: 'weekly',
    labelKey: 'weekly',
    descriptionKey: 'repeatsEveryWeek',
  );

  static const monthly = AppRecurrenceConfig(
    value: 'monthly',
    labelKey: 'monthly',
    descriptionKey: 'repeatsEveryMonth',
  );

  static const everyNDays = AppRecurrenceConfig(
    value: 'every_n_days',
    labelKey: 'everyNDays',
    descriptionKey: 'repeatsAfterACustomNumberOfDays',
  );

  static const all = [
    none,
    daily,
    weekly,
    monthly,
    everyNDays,
  ];

  static AppRecurrenceConfig fromValue(String? value) {
    for (final config in all) {
      if (config.value == value) return config;
    }

    return none;
  }

  static String displayText(
    BuildContext context,
    String? value,
    int? interval,
  ) {
    if (value == null) return context.l10n.doesNotRepeat;

    if (value == 'every_n_days') {
      return '${context.l10n.repeatEvery} ${interval ?? 1} ${context.l10n.days}';
    }

    return fromValue(value).label(context);
  }
}
