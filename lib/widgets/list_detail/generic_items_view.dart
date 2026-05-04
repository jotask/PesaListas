import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/app_strings.dart';
import 'package:pesalistas/core/item_fields.dart';
import 'package:pesalistas/core/item_status.dart';
import 'package:pesalistas/widgets/list_detail/empty_items_card.dart';
import 'package:pesalistas/widgets/list_detail/item_card.dart';

class GenericItemsView extends StatelessWidget {
  const GenericItemsView({
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

  void toggleItem(Map<String, dynamic> item) {
    final itemId = item[AppItemFields.id].toString();
    final isDone = AppItemStatus.isDone(item[AppItemFields.status]);

    if (isDone) {
      onReopen(itemId);
    } else {
      onComplete(itemId);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return EmptyItemsCard(
        icon: Icons.add_task,
        title: S.noItemsYet,
        subtitle: S.addYourFirstItem,
        onCreate: onCreate,
      );
    }

    return Column(
      children: [
        for (final item in items)
          ItemCard(
            item: item,
            onComplete: () => toggleItem(item),
            onEdit: () => onEdit(item),
            onDelete: () => onDelete(item[AppItemFields.id].toString()),
          ),
      ],
    );
  }
}
