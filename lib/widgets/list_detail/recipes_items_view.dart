import 'package:flutter/material.dart';
import 'package:pesalistas/widgets/list_detail/simple_items_view.dart';

class RecipesItemsView extends StatelessWidget {
  const RecipesItemsView({
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
    return SimpleItemsView(
      items: items,
      loading: loading,
      emptyIcon: Icons.restaurant_menu_outlined,
      emptyTitle: 'No recipes yet',
      emptySubtitle: 'Add a recipe idea. Full ingredients will come later.',
      cardIcon: Icons.restaurant_menu_outlined,
      fallbackTitle: 'Untitled recipe',
      defaultSubtitle: 'Recipe details coming later',
      onCreate: onCreate,
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }
}
