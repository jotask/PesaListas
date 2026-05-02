import 'package:flutter/material.dart';
import 'package:pesalistas/widgets/common/empty_info_card.dart';
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
      return EmptyInfoCard(
        icon: Icons.add_task,
        title: 'No items yet',
        subtitle: 'Add your first item.',
        trailing: const Icon(Icons.add),
        onTap: onCreate,
      );
    }

    return Column(
      children: [
        for (final item in items)
          ItemCard(
            item: item,
            onComplete: () => onComplete(item['id']),
            onEdit: () => onEdit(item),
            onDelete: () => onDelete(item['id']),
          ),
      ],
    );
  }
}
