import 'package:flutter/material.dart';
import 'package:pesalistas/core/date_formatting.dart';
import 'package:pesalistas/core/item_fields.dart';
import 'package:pesalistas/core/item_status.dart';
import 'package:pesalistas/core/priority_types.dart';
import 'package:pesalistas/core/value_parsing.dart';
import 'package:pesalistas/widgets/list_detail/base_item_card.dart';

class TaskItemCard extends StatelessWidget {
  const TaskItemCard({
    super.key,
    required this.item,
    required this.onComplete,
    required this.onEdit,
    required this.onDelete,
  });

  final Map<String, dynamic> item;
  final VoidCallback onComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  bool get isDone => AppItemStatus.isDone(item[AppItemFields.status]);

  String buildSubtitle() {
    final description = item[AppItemFields.description];
    final deadline = item[AppItemFields.deadlineAt];
    final priority = AppValueParsing.intOrNull(item[AppItemFields.priority]);

    final parts = <String>[];

    if (description != null && description.toString().trim().isNotEmpty) {
      parts.add(description.toString());
    }

    if (priority != null && priority > 0) {
      parts.add(AppPriorityTypes.displayText(priority));
    }

    final formattedDeadline = AppDateFormatting.yyyyMmDdFromValue(deadline);

    if (formattedDeadline.isNotEmpty) {
      parts.add('Due: $formattedDeadline');
    }

    return parts.isEmpty
        ? AppItemStatus.displayText(item[AppItemFields.status])
        : parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    return BaseItemCard(
      title: item[AppItemFields.title]?.toString(),
      fallbackTitle: 'Untitled task',
      subtitle: buildSubtitle(),
      icon: Icons.checklist,
      completed: isDone,
      onTap: onEdit,
      leadingAction: IconButton(
        icon: Icon(isDone ? Icons.check_circle : Icons.radio_button_unchecked),
        onPressed: isDone ? null : onComplete,
        tooltip: isDone ? 'Completed' : 'Complete task',
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
          tooltip: 'Delete task',
        ),
      ],
    );
  }
}
