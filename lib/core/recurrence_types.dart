import 'package:pesalistas/l10n/app_strings.dart';

class AppRecurrenceConfig {
  const AppRecurrenceConfig({
    required this.value,
    required this.label,
    required this.description,
  });

  final String? value;
  final String label;
  final String description;
}

class AppRecurrenceTypes {
  const AppRecurrenceTypes._();

  static AppRecurrenceConfig get none => AppRecurrenceConfig(
        value: null,
        label: S.none,
        description: S.doesNotRepeat2,
      );

  static AppRecurrenceConfig get daily => AppRecurrenceConfig(
        value: 'daily',
        label: S.daily,
        description: S.repeatsEveryDay,
      );

  static AppRecurrenceConfig get weekly => AppRecurrenceConfig(
        value: 'weekly',
        label: S.weekly,
        description: S.repeatsEveryWeek,
      );

  static AppRecurrenceConfig get monthly => AppRecurrenceConfig(
        value: 'monthly',
        label: S.monthly,
        description: S.repeatsEveryMonth,
      );

  static AppRecurrenceConfig get everyNDays => AppRecurrenceConfig(
        value: 'every_n_days',
        label: S.everyNDays,
        description: S.repeatsAfterACustomNumberOfDays,
      );

  static List<AppRecurrenceConfig> get all => [
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

  static String displayText(String? value, int? interval) {
    if (value == null) return S.doesNotRepeat;

    if (value == 'every_n_days') {
      return '${S.repeatEvery} ${interval ?? 1} ${S.days}';
    }

    return fromValue(value).label;
  }
}
