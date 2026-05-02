class AppRecurrenceTypeConfig {
  const AppRecurrenceTypeConfig({
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

  static const none = AppRecurrenceTypeConfig(
    value: null,
    label: 'None',
    description: 'Does not repeat.',
  );

  static const daily = AppRecurrenceTypeConfig(
    value: 'daily',
    label: 'Daily',
    description: 'Repeats every day.',
  );

  static const weekly = AppRecurrenceTypeConfig(
    value: 'weekly',
    label: 'Weekly',
    description: 'Repeats every week.',
  );

  static const monthly = AppRecurrenceTypeConfig(
    value: 'monthly',
    label: 'Monthly',
    description: 'Repeats every month.',
  );

  static const everyNDays = AppRecurrenceTypeConfig(
    value: 'every_n_days',
    label: 'Every N days',
    description: 'Repeats after a custom number of days.',
  );

  static const all = [none, daily, weekly, monthly, everyNDays];

  static AppRecurrenceTypeConfig fromValue(String? value) {
    for (final config in all) {
      if (config.value == value) return config;
    }

    return none;
  }

  static String displayText({
    required String? recurrenceType,
    required int? recurrenceInterval,
  }) {
    final config = fromValue(recurrenceType);

    if (config.value == null) {
      return 'Does not repeat';
    }

    if (config.value == everyNDays.value) {
      final interval = recurrenceInterval ?? 1;

      if (interval <= 1) {
        return 'Repeats every day';
      }

      return 'Repeats every $interval days';
    }

    return config.description;
  }
}
