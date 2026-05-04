import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/core/item_fields.dart';
import 'package:pesalistas/core/item_status.dart';
import 'package:pesalistas/widgets/list_detail/empty_items_card.dart';
import 'package:pesalistas/widgets/list_detail/task_item_card.dart';

class TaskItemsView extends StatelessWidget {
  const TaskItemsView({
    super.key,
    required this.items,
    required this.loading,
    required this.onCreate,
    required this.onComplete,
    required this.onReopen,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Map<String, dynamic>> items;
  final bool loading;
  final VoidCallback onCreate;
  final void Function(String itemId) onComplete;
  final void Function(String itemId) onReopen;
  final void Function(Map<String, dynamic> item) onEdit;
  final void Function(String itemId) onDelete;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return EmptyItemsCard(
        icon: Icons.checklist,
        title: context.l10n.noTasksYet,
        subtitle: context.l10n.createYourFirstTask,
        onCreate: onCreate,
      );
    }

    return Column(
      children: [
        for (final item in items)
          TaskItemCard(
            item: item,
            onComplete: () {
              final itemId = item[AppItemFields.id].toString();
              final isDone = AppItemStatus.isDone(item[AppItemFields.status]);

              if (isDone) {
                onReopen(itemId);
              } else {
                onComplete(itemId);
              }
            },
            onEdit: () => onEdit(item),
            onDelete: () => onDelete(item[AppItemFields.id].toString()),
          ),
      ],
    );
  }
}
