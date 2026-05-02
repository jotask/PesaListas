import 'package:flutter/material.dart';
import 'package:pesalistas/widgets/list_detail/activities_items_view.dart';
import 'package:pesalistas/widgets/list_detail/chore_items_view.dart';
import 'package:pesalistas/widgets/list_detail/generic_items_view.dart';
import 'package:pesalistas/widgets/list_detail/ideas_items_view.dart';
import 'package:pesalistas/widgets/list_detail/meal_plan_items_view.dart';
import 'package:pesalistas/widgets/list_detail/movies_items_view.dart';
import 'package:pesalistas/widgets/list_detail/not_implemented_view.dart';
import 'package:pesalistas/widgets/list_detail/recipes_items_view.dart';
import 'package:pesalistas/widgets/list_detail/shopping_items_view.dart';
import 'package:pesalistas/widgets/list_detail/task_items_view.dart';

class ItemsViewFactory extends StatelessWidget {
  const ItemsViewFactory({
    super.key,
    required this.listType,
    required this.items,
    required this.loading,
    required this.onCreate,
    required this.onComplete,
    required this.onEdit,
    required this.onDelete,
    required this.onVote,
  });

  final String listType;
  final List<Map<String, dynamic>> items;
  final bool loading;
  final VoidCallback onCreate;
  final void Function(String itemId) onComplete;
  final void Function(Map<String, dynamic> item) onEdit;
  final void Function(String itemId) onDelete;
  final void Function(Map<String, dynamic> item) onVote;

  @override
  Widget build(BuildContext context) {
    switch (listType) {
      case 'tasks':
        return TaskItemsView(
          items: items,
          loading: loading,
          onCreate: onCreate,
          onComplete: onComplete,
          onEdit: onEdit,
          onDelete: onDelete,
        );
      case 'generic':
        return GenericItemsView(
          items: items,
          loading: loading,
          onCreate: onCreate,
          onComplete: onComplete,
          onEdit: onEdit,
          onDelete: onDelete,
        );
      case 'movies':
        return MovieItemsView(
          items: items,
          loading: loading,
          onCreate: onCreate,
          onComplete: onComplete,
          onEdit: onEdit,
          onDelete: onDelete,
          onVote: onVote,
        );
      case 'chores':
        return ChoreItemsView(
          items: items,
          loading: loading,
          onCreate: onCreate,
          onComplete: onComplete,
          onEdit: onEdit,
          onDelete: onDelete,
        );
      case 'ideas':
        return IdeasItemsView(
          items: items,
          loading: loading,
          onCreate: onCreate,
          onComplete: onComplete,
          onEdit: onEdit,
          onDelete: onDelete,
          onVote: onVote,
        );
      case 'activities':
        return ActivitiesItemsView(
          items: items,
          loading: loading,
          onCreate: onCreate,
          onComplete: onComplete,
          onEdit: onEdit,
          onDelete: onDelete,
          onVote: onVote,
        );
      case 'recipes':
        return RecipesItemsView(
          items: items,
          loading: loading,
          onCreate: onCreate,
          onComplete: onComplete,
          onEdit: onEdit,
          onDelete: onDelete,
        );
      case 'shopping':
        return ShoppingItemsView(
          items: items,
          loading: loading,
          onCreate: onCreate,
          onComplete: onComplete,
          onEdit: onEdit,
          onDelete: onDelete,
        );
      case 'meal_plan':
        return MealPlanItemsView(
          items: items,
          loading: loading,
          onCreate: onCreate,
          onComplete: onComplete,
          onEdit: onEdit,
          onDelete: onDelete,
        );

      default:
        return NotImplementedItemsView();
    }
  }
}
