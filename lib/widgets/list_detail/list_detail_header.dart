import 'package:flutter/material.dart';
import 'package:pesalistas/core/list_types.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';

class ListDetailHeader extends StatelessWidget {
  const ListDetailHeader({
    super.key,
    required this.listName,
    this.listDescription,
    required this.config,
    required this.onBack,
    required this.onEdit,
    this.actions = const [],
  });

  final String listName;
  final String? listDescription;
  final AppListTypeConfig config;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final description = listDescription?.trim();
    final hasDescription = description != null && description.isNotEmpty;

    final subtitle = hasDescription
        ? '${config.label(context)} • $description'
        : config.label(context);

    return Material(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(4, 4, 8, 8),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            border: Border(
              bottom: BorderSide(
                color: theme.dividerColor.withValues(alpha: 0.35),
              ),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
                tooltip: context.l10n.back,
                visualDensity: VisualDensity.compact,
              ),
              CircleAvatar(
                radius: 17,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  config.icon,
                  size: 18,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ...actions,
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                tooltip: context.l10n.editList,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
