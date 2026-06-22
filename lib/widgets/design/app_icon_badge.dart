import 'package:flutter/material.dart';
import 'package:pesalistas/core/design/app_radius.dart';

class AppIconBadge extends StatelessWidget {
  const AppIconBadge({
    super.key,
    required this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.size = 44,
    this.iconSize = 22,
  });

  final IconData icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: foregroundColor ?? theme.colorScheme.onPrimaryContainer,
      ),
    );
  }
}
