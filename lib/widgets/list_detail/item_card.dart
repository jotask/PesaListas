import 'package:flutter/material.dart';
import 'package:pesalistas/core/item_fields.dart';
import 'package:pesalistas/core/item_status.dart';
import 'package:pesalistas/widgets/list_detail/base_item_card.dart';

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

  @override
  Widget build(BuildContext context) {
    final status = item[AppItemFields.status];
    final isDone = AppItemStatus.isDone(status);

    final title = item[AppItemFields.title]?.toString();
    final description = item[AppItemFields.description]?.toString();

    return BaseItemCard(
      title: title,
      fallbackTitle: 'Untitled item',
      subtitle: description == null || description.isEmpty
          ? AppItemStatus.displayText(status)
          : description,
      icon: Icons.list_alt,
      completed: isDone,
      onTap: onEdit,
      leadingAction: IconButton(
        icon: Icon(isDone ? Icons.check_circle : Icons.radio_button_unchecked),
        onPressed: isDone ? null : onComplete,
        tooltip: isDone ? 'Completed' : 'Complete item',
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
          tooltip: 'Delete item',
        ),
      ],
    );
  }
}
