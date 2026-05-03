import 'package:flutter/material.dart';
import 'package:pesalistas/core/list_types.dart';

class ListDetailHeader extends StatelessWidget {
  const ListDetailHeader({
    super.key,
    required this.listName,
    required this.config,
    required this.onBack,
  });

  final String listName;
  final AppListTypeConfig config;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(8, 4, 16, 12),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            border: Border(
              bottom: BorderSide(color: theme.dividerColor.withOpacity(0.4)),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 40,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Back',
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        config.icon,
                        size: 22,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        listName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _ListTypePill(icon: config.icon, label: config.label),
                    Text(config.description, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListTypePill extends StatelessWidget {
  const _ListTypePill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
