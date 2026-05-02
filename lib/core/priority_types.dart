class AppPriorityConfig {
  const AppPriorityConfig({
    required this.value,
    required this.label,
    required this.description,
  });

  final int value;
  final String label;
  final String description;
}

class AppPriorityTypes {
  const AppPriorityTypes._();

  static const none = AppPriorityConfig(
    value: 0,
    label: 'None',
    description: 'No priority',
  );

  static const low = AppPriorityConfig(
    value: 1,
    label: 'Low',
    description: 'Low priority',
  );

  static const medium = AppPriorityConfig(
    value: 2,
    label: 'Medium',
    description: 'Medium priority',
  );

  static const high = AppPriorityConfig(
    value: 3,
    label: 'High',
    description: 'High priority',
  );

  static const all = [none, low, medium, high];

  static AppPriorityConfig fromValue(int? value) {
    for (final config in all) {
      if (config.value == value) return config;
    }

    return none;
  }

  static String displayText(int? value) {
    final config = fromValue(value);

    if (config.value == 0) {
      return 'No priority';
    }

    return '${config.label} priority';
  }
}
