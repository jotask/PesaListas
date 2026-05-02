import 'package:flutter/material.dart';
import 'package:pesalistas/core/date_formatting.dart';
import 'package:pesalistas/core/item_fields.dart';
import 'package:pesalistas/core/recurrence_types.dart';
import 'package:pesalistas/core/value_parsing.dart';
import 'package:pesalistas/widgets/list_detail/base_item_card.dart';

class ChoreItemCard extends StatelessWidget {
  const ChoreItemCard({
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

  String buildSubtitle() {
    final description = item[AppItemFields.description];
    final recurrenceType = item[AppItemFields.recurrenceType]?.toString();
    final recurrenceInterval = AppValueParsing.intOrNull(
      item[AppItemFields.recurrenceInterval],
    );
    final nextDueAt = item[AppItemFields.nextDueAt];

    final parts = <String>[];

    if (description != null && description.toString().trim().isNotEmpty) {
      parts.add(description.toString());
    }

    if (recurrenceType != null && recurrenceType.trim().isNotEmpty) {
      parts.add(
        AppRecurrenceTypes.displayText(
          recurrenceType: recurrenceType,
          recurrenceInterval: recurrenceInterval,
        ),
      );
    }

    final formattedNextDue = AppDateFormatting.yyyyMmDdFromValue(nextDueAt);

    if (formattedNextDue.isNotEmpty) {
      parts.add('Next due: $formattedNextDue');
    }

    return parts.isEmpty ? 'Chore' : parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    return BaseItemCard(
      title: item[AppItemFields.title]?.toString(),
      fallbackTitle: 'Untitled chore',
      subtitle: buildSubtitle(),
      icon: Icons.cleaning_services,
      onTap: onEdit,
      leadingAction: IconButton(
        icon: const Icon(Icons.check_circle_outline),
        onPressed: onComplete,
        tooltip: 'Complete chore',
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
          tooltip: 'Delete chore',
        ),
      ],
    );
  }
}
