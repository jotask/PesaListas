import 'package:flutter/material.dart';
import 'package:pesalistas/widgets/common/empty_info_card.dart';

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
    return EmptyInfoCard(
      icon: Icons.shopping_cart_outlined,
      title: 'Shopping coming soon',
      subtitle: 'Shopping lists will use shopping_list_items.',
    );
  }
}
