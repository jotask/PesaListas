import 'package:flutter/material.dart';

enum AppMessageCardTone { neutral, error, success, warning }

class AppMessageCard extends StatelessWidget {
  const AppMessageCard({
    super.key,
    required this.message,
    this.icon = Icons.info_outline,
    this.tone = AppMessageCardTone.neutral,
  });

  final String message;
  final IconData icon;
  final AppMessageCardTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colors = _colorsForTone(theme);

    return Card(
      color: colors.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colors.foregroundColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: colors.foregroundColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _AppMessageCardColors _colorsForTone(ThemeData theme) {
    final colors = theme.colorScheme;

    switch (tone) {
      case AppMessageCardTone.error:
        return _AppMessageCardColors(
          backgroundColor: colors.errorContainer,
          foregroundColor: colors.onErrorContainer,
        );

      case AppMessageCardTone.success:
        return _AppMessageCardColors(
          backgroundColor: colors.primaryContainer,
          foregroundColor: colors.onPrimaryContainer,
        );

      case AppMessageCardTone.warning:
        return _AppMessageCardColors(
          backgroundColor: colors.tertiaryContainer,
          foregroundColor: colors.onTertiaryContainer,
        );

      case AppMessageCardTone.neutral:
        return _AppMessageCardColors(
          backgroundColor: colors.surface,
          foregroundColor: colors.onSurfaceVariant,
        );
    }
  }
}

class _AppMessageCardColors {
  const _AppMessageCardColors({
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final Color backgroundColor;
  final Color foregroundColor;
}
