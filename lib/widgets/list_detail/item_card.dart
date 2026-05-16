import 'package:flutter/material.dart';
import 'package:pesalistas/core/item_text.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/core/fields/item_fields.dart';
import 'package:pesalistas/core/item_status.dart';
import 'package:pesalistas/widgets/common/app_meta_pill.dart';

class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.item,
    required this.onComplete,
    required this.onDelete,
    required this.onEdit,
  });

  final Map<String, dynamic> item;
  final VoidCallback onComplete;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  bool get isDone {
    return AppItemStatus.isDone(item[AppItemFields.status]);
  }

  String title(BuildContext context) {
    return AppItemText.title(item, fallback: context.l10n.untitledItem);
  }

  String subtitle(BuildContext context) {
    final description = AppItemText.description(item);

    if (description != null) {
      return description;
    }

    return isDone ? context.l10n.done : 'No description';
  }

  String stateLabel(BuildContext context) {
    return isDone ? context.l10n.done : context.l10n.open;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
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
                            ? Icons.check_circle
                            : Icons.inventory_2_outlined,
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
                                  title(context),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    decoration: isDone
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                              _ItemStatePill(
                                isDone: isDone,
                                label: stateLabel(context),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            subtitle(context),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              AppMetaPill(
                                icon: Icons.category_outlined,
                                label: 'Generic item',
                              ),
                            ],
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
                        onPressed: onComplete,
                        icon: Icon(
                          isDone ? Icons.undo : Icons.check_circle_outline,
                        ),
                        label: Text(
                          isDone
                              ? context.l10n.markAsOpen
                              : context.l10n.markAsDone,
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
                      tooltip: context.l10n.deleteItem,
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

class _ItemStatePill extends StatelessWidget {
  const _ItemStatePill({required this.isDone, required this.label});

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
