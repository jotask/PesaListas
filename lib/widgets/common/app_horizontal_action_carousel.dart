import 'package:flutter/material.dart';

class AppHorizontalActionCarousel extends StatelessWidget {
  const AppHorizontalActionCarousel({
    super.key,
    required this.actions,
    this.height = 78,
    this.itemWidth = 104,
    this.padding = EdgeInsets.zero,
  });

  final List<AppHorizontalActionItem> actions;
  final double height;
  final double itemWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: actions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return SizedBox(
            width: itemWidth,
            child: _AppHorizontalActionTile(action: actions[index]),
          );
        },
      ),
    );
  }
}

class AppHorizontalActionItem {
  const AppHorizontalActionItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.enabled = true,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final bool enabled;
}

class _AppHorizontalActionTile extends StatelessWidget {
  const _AppHorizontalActionTile({required this.action});

  final AppHorizontalActionItem action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final child = Material(
      color: action.enabled
          ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.72)
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.32),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: action.enabled ? action.onTap : null,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                action.icon,
                size: 24,
                color: action.enabled
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.45,
                      ),
              ),
              const SizedBox(height: 6),
              Text(
                action.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: action.enabled
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.45,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (action.tooltip == null || action.tooltip!.trim().isEmpty) {
      return child;
    }

    return Tooltip(message: action.tooltip!, child: child);
  }
}
