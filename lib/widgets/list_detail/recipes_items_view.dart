import 'package:flutter/material.dart';
import 'package:pesalistas/widgets/common/empty_info_card.dart';

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
    return EmptyInfoCard(
      icon: Icons.restaurant_menu,
      title: 'Recipes coming soon',
      subtitle: 'Recipes will use the dedicated recipes table.',
    );
  }
}
