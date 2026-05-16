import 'package:flutter/material.dart';

class AppMetaPill extends StatelessWidget {
  const AppMetaPill({
    super.key,
    required this.icon,
    required this.label,
    this.filled = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  final IconData icon;
  final String label;
  final bool filled;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final resolvedBackgroundColor =
        backgroundColor ??
        (filled
            ? theme.colorScheme.secondaryContainer
            : theme.colorScheme.surfaceContainerHighest);

    final resolvedForegroundColor =
        foregroundColor ??
        (filled
            ? theme.colorScheme.onSecondaryContainer
            : theme.colorScheme.onSurfaceVariant);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: resolvedBackgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: resolvedForegroundColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: resolvedForegroundColor,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
