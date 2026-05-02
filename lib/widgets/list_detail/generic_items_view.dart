import 'package:flutter/material.dart';
import 'package:pesalistas/core/item_fields.dart';
import 'package:pesalistas/widgets/list_detail/empty_items_card.dart';
import 'package:pesalistas/widgets/list_detail/item_card.dart';

class GenericItemsView extends StatelessWidget {
  const GenericItemsView({
    super.key,
    required this.items,
    required this.loading,
    required this.onCreate,
    required this.onComplete,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Map<String, dynamic>> items;
  final bool loading;
  final VoidCallback onCreate;
  final void Function(String itemId) onComplete;
  final void Function(Map<String, dynamic> item) onEdit;
  final void Function(String itemId) onDelete;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return EmptyItemsCard(
        icon: Icons.add_task,
        title: 'No items yet',
        subtitle: 'Add your first item.',
        onCreate: onCreate,
      );
    }

    return Column(
      children: [
        for (final item in items)
          ItemCard(
            item: item,
            onComplete: () => onComplete(item[AppItemFields.id].toString()),
            onEdit: () => onEdit(item),
            onDelete: () => onDelete(item[AppItemFields.id].toString()),
          ),
      ],
    );
  }
}
