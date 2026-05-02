import 'package:flutter/material.dart';
import 'package:pesalistas/widgets/list_detail/checkable_item_card.dart';
import 'package:pesalistas/widgets/list_detail/empty_items_card.dart';

class ShoppingItemsView extends StatelessWidget {
  const ShoppingItemsView({
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
        icon: Icons.shopping_cart_outlined,
        title: 'No shopping items yet',
        subtitle: 'Add something to buy.',
        onCreate: onCreate,
      );
    }

    return Column(
      children: [
        for (final item in items)
          CheckableItemCard(
            item: item,
            icon: Icons.shopping_cart_outlined,
            fallbackTitle: 'Untitled shopping item',
            defaultOpenSubtitle: 'To buy',
            defaultDoneSubtitle: 'Bought',
            completeTooltip: 'Mark as bought',
            doneTooltip: 'Bought',
            deleteTooltip: 'Delete shopping item',
            onComplete: () => onComplete(item['id'].toString()),
            onEdit: () => onEdit(item),
            onDelete: () => onDelete(item['id'].toString()),
          ),
      ],
    );
  }
}
