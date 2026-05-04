import 'package:pesalistas/l10n/app_strings.dart';

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

  static AppPriorityConfig get none => AppPriorityConfig(
        value: 0,
        label: S.none,
        description: S.noPriority,
      );

  static AppPriorityConfig get low => AppPriorityConfig(
        value: 1,
        label: S.low,
        description: S.lowPriority,
      );

  static AppPriorityConfig get medium => AppPriorityConfig(
        value: 2,
        label: S.medium,
        description: S.mediumPriority,
      );

  static AppPriorityConfig get high => AppPriorityConfig(
        value: 3,
        label: S.high,
        description: S.highPriority,
      );

  static List<AppPriorityConfig> get all => [none, low, medium, high];

  static AppPriorityConfig fromValue(int? value) {
    for (final config in all) {
      if (config.value == value) return config;
    }

    return none;
  }

  static String displayText(int? value) {
    final config = fromValue(value);

    if (config.value == 0) {
      return S.noPriority;
    }

    return '${config.label} ${S.priority.toLowerCase()}';
  }
}
