import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/core/fields/item_fields.dart';
import 'package:pesalistas/core/item_status.dart';

class CheckableItemCard extends StatelessWidget {
  const CheckableItemCard({
    super.key,
    required this.item,
    required this.icon,
    required this.fallbackTitle,
    required this.defaultOpenSubtitle,
    required this.defaultDoneSubtitle,
    required this.completeTooltip,
    required this.reopenTooltip,
    required this.deleteTooltip,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final Map<String, dynamic> item;
  final IconData icon;
  final String fallbackTitle;
  final String defaultOpenSubtitle;
  final String defaultDoneSubtitle;
  final String completeTooltip;
  final String reopenTooltip;
  final String deleteTooltip;

  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  bool get isDone => AppItemStatus.isDone(item[AppItemFields.status]);

  String get title {
    final value = item[AppItemFields.title]?.toString();

    if (value == null || value.trim().isEmpty) {
      return fallbackTitle;
    }

    return value.trim();
  }

  String get subtitle {
    final description = item[AppItemFields.description]?.toString();

    if (description != null && description.trim().isNotEmpty) {
      return description.trim();
    }

    return isDone ? defaultDoneSubtitle : defaultOpenSubtitle;
  }

  String get stateLabel {
    return isDone ? defaultDoneSubtitle : defaultOpenSubtitle;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Opacity(
            opacity: isDone ? 0.72 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: isDone
                          ? theme.colorScheme.secondaryContainer
                          : theme.colorScheme.primaryContainer,
                      child: Icon(
                        isDone
                            ? Icons.shopping_cart_checkout
                            : Icons.shopping_cart_outlined,
                        color: isDone
                            ? theme.colorScheme.onSecondaryContainer
                            : theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    decoration: isDone
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                              _ShoppingStatePill(
                                isDone: isDone,
                                label: stateLabel,
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onToggle,
                        icon: Icon(
                          isDone ? Icons.undo : Icons.check_circle_outline,
                        ),
                        label: Text(
                          isDone
                              ? context.l10n.markAsNotBought
                              : context.l10n.markAsBought,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      onPressed: onEdit,
                      icon: Icon(Icons.edit_outlined),
                      tooltip: context.l10n.editItem,
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: Icon(Icons.delete_outline),
                      tooltip: deleteTooltip,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShoppingStatePill extends StatelessWidget {
  const _ShoppingStatePill({required this.isDone, required this.label});

  final bool isDone;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final backgroundColor = isDone
        ? theme.colorScheme.secondaryContainer
        : theme.colorScheme.primaryContainer;

    final foregroundColor = isDone
        ? theme.colorScheme.onSecondaryContainer
        : theme.colorScheme.onPrimaryContainer;

    return Container(
      margin: const EdgeInsets.only(left: 8),
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
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
