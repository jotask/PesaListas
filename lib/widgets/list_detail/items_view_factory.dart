import 'package:flutter/material.dart';
import 'package:pesalistas/core/list_types.dart';
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
    required this.onReopen,
    required this.onEdit,
    required this.onDelete,
    required this.onVote,
    required this.onViewVotes,
    required this.onViewRecipeDetails,
    required this.onDeleteRecipe,
    required this.onGenerateShoppingFromMealPlans,
    required this.onClearAll,
  });

  final String listType;
  final List<Map<String, dynamic>> items;
  final bool loading;
  final VoidCallback onCreate;
  final void Function(String itemId) onComplete;
  final void Function(String itemId) onReopen;
  final void Function(Map<String, dynamic> item) onEdit;
  final void Function(String itemId) onDelete;
  final void Function(Map<String, dynamic> item) onVote;
  final void Function(Map<String, dynamic> item) onViewVotes;
  final void Function(Map<String, dynamic> recipe) onViewRecipeDetails;
  final void Function(String recipeId) onDeleteRecipe;
  final VoidCallback onGenerateShoppingFromMealPlans;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    if (listType == AppListTypes.tasks.value) {
      return TaskItemsView(
        items: items,
        loading: loading,
        onCreate: onCreate,
        onComplete: onComplete,
        onReopen: onReopen,
        onEdit: onEdit,
        onDelete: onDelete,
      );
    }

    if (listType == AppListTypes.chores.value) {
      return ChoreItemsView(
        items: items,
        loading: loading,
        onCreate: onCreate,
        onComplete: onComplete,
        onEdit: onEdit,
        onDelete: onDelete,
      );
    }

    if (listType == AppListTypes.movies.value) {
      return MovieItemsView(
        items: items,
        loading: loading,
        onCreate: onCreate,
        onComplete: onComplete,
        onEdit: onEdit,
        onDelete: onDelete,
        onVote: onVote,
        onViewVotes: onViewVotes,
      );
    }

    if (listType == AppListTypes.ideas.value) {
      return IdeasItemsView(
        items: items,
        loading: loading,
        onCreate: onCreate,
        onComplete: onComplete,
        onEdit: onEdit,
        onDelete: onDelete,
        onVote: onVote,
        onViewVotes: onViewVotes,
      );
    }

    if (listType == AppListTypes.activities.value) {
      return ActivitiesItemsView(
        items: items,
        loading: loading,
        onCreate: onCreate,
        onComplete: onComplete,
        onEdit: onEdit,
        onDelete: onDelete,
        onVote: onVote,
        onViewVotes: onViewVotes,
      );
    }

    if (listType == AppListTypes.recipes.value) {
      return RecipesItemsView(
        recipes: items,
        loading: loading,
        onCreate: onCreate,
        onViewRecipeDetails: onViewRecipeDetails,
        onDeleteRecipe: onDeleteRecipe,
      );
    }

    if (listType == AppListTypes.shopping.value) {
      return ShoppingItemsView(
        items: items,
        loading: loading,
        onCreate: onCreate,
        onComplete: onComplete,
        onReopen: onReopen,
        onEdit: onEdit,
        onDelete: onDelete,
        onClearBought: onGenerateShoppingFromMealPlans,
        onClearAll: onClearAll,
      );
    }

    if (listType == AppListTypes.mealPlan.value) {
      return MealPlanItemsView(
        mealPlans: items,
        loading: loading,
        onCreate: onCreate,
        onEdit: onEdit,
        onDelete: onDelete,
        onGenerateShopping: onGenerateShoppingFromMealPlans,
      );
    }

    if (listType == AppListTypes.generic.value) {
      return GenericItemsView(
        items: items,
        loading: loading,
        onCreate: onCreate,
        onComplete: onComplete,
        onReopen: onReopen,
        onEdit: onEdit,
        onDelete: onDelete,
      );
    }

    return const NotImplementedItemsView();
  }
}
