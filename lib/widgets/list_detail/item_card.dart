import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/app_strings.dart';
import 'package:pesalistas/core/item_fields.dart';
import 'package:pesalistas/core/item_status.dart';

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

  String get title {
    final value = item[AppItemFields.title]?.toString();

    if (value == null || value.trim().isEmpty) {
      return S.untitledItem;
    }

    return value.trim();
  }

  String get subtitle {
    final description = item[AppItemFields.description]?.toString();

    if (description != null && description.trim().isNotEmpty) {
      return description.trim();
    }

    return isDone ? S.done : S.open;
  }

  String get stateLabel {
    return isDone ? S.done : S.open;
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
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
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
                              _ItemStatePill(isDone: isDone, label: stateLabel),
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
                        onPressed: onComplete,
                        icon: Icon(
                          isDone ? Icons.undo : Icons.check_circle_outline,
                        ),
                        label: Text(isDone ? S.markAsOpen : S.markAsDone),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      onPressed: onEdit,
                      icon: Icon(Icons.edit_outlined),
                      tooltip: S.editItem,
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: Icon(Icons.delete_outline),
                      tooltip: S.deleteItem,
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
