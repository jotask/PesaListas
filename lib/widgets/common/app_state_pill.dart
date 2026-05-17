import 'package:flutter/material.dart';

class AppStatePill extends StatelessWidget {
  const AppStatePill({
    super.key,
    required this.label,
    required this.active,
    this.margin = const EdgeInsets.only(left: 8),
  });

  final String label;
  final bool active;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final backgroundColor = active
        ? theme.colorScheme.secondaryContainer
        : theme.colorScheme.primaryContainer;

    final foregroundColor = active
        ? theme.colorScheme.onSecondaryContainer
        : theme.colorScheme.onPrimaryContainer;

    return Container(
      margin: margin,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foregroundColor,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
