import 'package:flutter/material.dart';

class AppFilterMenuOption<T> {
  const AppFilterMenuOption({
    required this.value,
    required this.label,
    this.icon,
  });

  final T value;
  final String label;
  final IconData? icon;
}

class AppFilterMenuButton<T> extends StatelessWidget {
  const AppFilterMenuButton({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.tooltip = 'Filter',
    this.showSelectedLabel = true,
  });

  final T value;
  final List<AppFilterMenuOption<T>> options;
  final ValueChanged<T> onChanged;
  final String tooltip;
  final bool showSelectedLabel;

  AppFilterMenuOption<T>? get selectedOption {
    for (final option in options) {
      if (option.value == value) {
        return option;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = selectedOption;

    return PopupMenuButton<T>(
      tooltip: tooltip,
      initialValue: value,
      onSelected: onChanged,
      itemBuilder: (context) {
        return options.map((option) {
          final selected = option.value == value;

          return PopupMenuItem<T>(
            value: option.value,
            child: Row(
              children: [
                Icon(
                  selected ? Icons.check : option.icon ?? Icons.filter_alt,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(option.label)),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.7,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_list, size: 20, color: theme.colorScheme.primary),
            if (showSelectedLabel && selected != null) ...[
              const SizedBox(width: 6),
              Text(
                selected.label,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
