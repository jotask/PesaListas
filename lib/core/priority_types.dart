import 'package:flutter/widgets.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';

class AppPriorityConfig {
  const AppPriorityConfig({
    required this.value,
    required this.labelKey,
    required this.descriptionKey,
  });

  final int value;
  final String labelKey;
  final String descriptionKey;

  String label(BuildContext context) {
    switch (labelKey) {
      case 'none':
        return context.l10n.none;
      case 'low':
        return context.l10n.low;
      case 'medium':
        return context.l10n.medium;
      case 'high':
        return context.l10n.high;
      default:
        return context.l10n.none;
    }
  }

  String description(BuildContext context) {
    switch (descriptionKey) {
      case 'noPriority':
        return context.l10n.noPriority;
      case 'lowPriority':
        return context.l10n.lowPriority;
      case 'mediumPriority':
        return context.l10n.mediumPriority;
      case 'highPriority':
        return context.l10n.highPriority;
      default:
        return context.l10n.noPriority;
    }
  }
}

class AppPriorityTypes {
  const AppPriorityTypes._();

  static const none = AppPriorityConfig(
    value: 0,
    labelKey: 'none',
    descriptionKey: 'noPriority',
  );

  static const low = AppPriorityConfig(
    value: 1,
    labelKey: 'low',
    descriptionKey: 'lowPriority',
  );

  static const medium = AppPriorityConfig(
    value: 2,
    labelKey: 'medium',
    descriptionKey: 'mediumPriority',
  );

  static const high = AppPriorityConfig(
    value: 3,
    labelKey: 'high',
    descriptionKey: 'highPriority',
  );

  static const all = [none, low, medium, high];

  static AppPriorityConfig fromValue(int? value) {
    for (final config in all) {
      if (config.value == value) return config;
    }

    return none;
  }

  static String displayText(BuildContext context, int? value) {
    final config = fromValue(value);

    if (config.value == 0) {
      return context.l10n.noPriority;
    }

    return '${config.label(context)} ${context.l10n.priority.toLowerCase()}';
  }
}
