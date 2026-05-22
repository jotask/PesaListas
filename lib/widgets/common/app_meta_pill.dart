import 'package:flutter/material.dart';

class AppMetaPill extends StatelessWidget {
  const AppMetaPill({
    super.key,
    this.icon,
    required this.label,
    this.maxWidth = 180,
    this.filled = false,
    this.backgroundColor,
    this.foregroundColor,
    this.fontWeight = FontWeight.w800,
    this.iconSize = 14,
    this.fontSize = 12,
    this.horizontalPadding = 8,
    this.verticalPadding = 5,
  });

  final IconData? icon;
  final String label;
  final double maxWidth;
  final bool filled;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final FontWeight fontWeight;
  final double iconSize;
  final double fontSize;
  final double horizontalPadding;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final resolvedBackgroundColor =
        backgroundColor ??
        (filled
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest);

    final resolvedForegroundColor =
        foregroundColor ??
        (filled
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurfaceVariant);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: resolvedBackgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: iconSize, color: resolvedForegroundColor),
            const SizedBox(width: 5),
          ],
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: resolvedForegroundColor,
                fontSize: fontSize,
                fontWeight: fontWeight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
