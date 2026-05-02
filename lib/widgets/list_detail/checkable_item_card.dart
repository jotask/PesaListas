import 'package:flutter/material.dart';
import 'package:pesalistas/core/item_fields.dart';
import 'package:pesalistas/core/item_status.dart';
import 'package:pesalistas/widgets/list_detail/base_item_card.dart';

class CheckableItemCard extends StatelessWidget {
  const CheckableItemCard({
    super.key,
    required this.item,
    required this.icon,
    required this.fallbackTitle,
    required this.defaultOpenSubtitle,
    required this.defaultDoneSubtitle,
    required this.completeTooltip,
    required this.doneTooltip,
    required this.deleteTooltip,
    required this.onComplete,
    required this.onEdit,
    required this.onDelete,
  });

  final Map<String, dynamic> item;
  final IconData icon;
  final String fallbackTitle;
  final String defaultOpenSubtitle;
  final String defaultDoneSubtitle;
  final String completeTooltip;
  final String doneTooltip;
  final String deleteTooltip;

  final VoidCallback onComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  bool get isDone => AppItemStatus.isDone(item[AppItemFields.status]);

  String get subtitle {
    final description = item[AppItemFields.description]?.toString();

    if (description != null && description.trim().isNotEmpty) {
      return description;
    }

    return isDone ? defaultDoneSubtitle : defaultOpenSubtitle;
  }

  @override
  Widget build(BuildContext context) {
    return BaseItemCard(
      title: item[AppItemFields.title]?.toString(),
      fallbackTitle: fallbackTitle,
      subtitle: subtitle,
      icon: icon,
      completed: isDone,
      onTap: onEdit,
      leadingAction: IconButton(
        icon: Icon(isDone ? Icons.check_circle : Icons.radio_button_unchecked),
        onPressed: isDone ? null : onComplete,
        tooltip: isDone ? doneTooltip : completeTooltip,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
          tooltip: deleteTooltip,
        ),
      ],
    );
  }
}
