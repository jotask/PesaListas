import 'package:flutter/material.dart';
import 'package:pesalistas/core/design/app_radius.dart';
import 'package:pesalistas/core/design/app_spacing.dart';
import 'package:pesalistas/core/design/list_type_style.dart';
import 'package:pesalistas/core/list_types.dart';
import 'package:pesalistas/widgets/design/app_icon_badge.dart';

class AppListTypeCard extends StatelessWidget {
  const AppListTypeCard({
    super.key,
    required this.config,
    required this.selected,
    required this.onTap,
  });

  final AppListTypeConfig config;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = ListTypeStyle.of(config.value);

    final backgroundColor = selected ? style.soft : theme.colorScheme.surface;

    final borderColor = selected
        ? style.accent
        : theme.colorScheme.outlineVariant.withValues(alpha: 0.6);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: theme.brightness == Brightness.dark ? 0.16 : 0.045,
                ),
                blurRadius: selected ? 20 : 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -18,
                bottom: -20,
                child: Icon(
                  config.icon,
                  size: 92,
                  color: style.accent.withValues(alpha: 0.07),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppIconBadge(
                    icon: config.icon,
                    backgroundColor: selected ? style.accent : style.soft,
                    foregroundColor: selected ? Colors.white : style.onSoft,
                  ),
                  const Spacer(),
                  Text(
                    config.label(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: selected
                          ? style.onSoft
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    config.description(context),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      height: 1.15,
                      color: selected
                          ? style.onSoft.withValues(alpha: 0.78)
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 160),
                  scale: selected ? 1 : 0.86,
                  child: Icon(
                    selected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: selected
                        ? style.accent
                        : theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.55,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
