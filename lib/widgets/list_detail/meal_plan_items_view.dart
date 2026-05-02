import 'package:flutter/material.dart';
import 'package:pesalistas/widgets/list_detail/simple_items_view.dart';

class MealPlanItemsView extends StatelessWidget {
  const MealPlanItemsView({
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
      emptyIcon: Icons.calendar_month_outlined,
      emptyTitle: 'No meal plans yet',
      emptySubtitle: 'Add a meal idea. Calendar planning will come later.',
      cardIcon: Icons.calendar_month_outlined,
      fallbackTitle: 'Untitled meal plan',
      defaultSubtitle: 'Meal planning calendar coming later',
      onCreate: onCreate,
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }
}
