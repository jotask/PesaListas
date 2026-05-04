import 'package:pesalistas/core/app_tables.dart';
import 'package:pesalistas/core/meal_plan_fields.dart';
import 'package:pesalistas/core/recipe_fields.dart';
import 'package:pesalistas/core/shopping_item_fields.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShoppingRepository {
  ShoppingRepository(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> getShoppingItemsForGroup(
    String groupId,
  ) async {
    final shoppingItems = await _getRawShoppingItemsForGroup(groupId);

    if (shoppingItems.isEmpty) {
      return shoppingItems;
    }

    final recipes = await _getRecipesForGroup(groupId);
    final mealPlans = await _getMealPlansForGroup(groupId);

    final recipesById = {
      for (final recipe in recipes)
        recipe[AppRecipeFields.id].toString(): recipe,
    };

    final mealPlansById = {
      for (final mealPlan in mealPlans)
        mealPlan[AppMealPlanFields.id].toString(): mealPlan,
    };

    return shoppingItems.map((item) {
      final sourceRecipeId = item[AppShoppingItemFields.sourceRecipeId]
          ?.toString();
      final sourceMealPlanId = item[AppShoppingItemFields.sourceMealPlanId]
          ?.toString();

      final sourceRecipe = sourceRecipeId == null || sourceRecipeId.isEmpty
          ? null
          : recipesById[sourceRecipeId];

      final sourceMealPlan =
          sourceMealPlanId == null || sourceMealPlanId.isEmpty
          ? null
          : mealPlansById[sourceMealPlanId];

      return {
        ...item,
        AppShoppingItemFields.sourceRecipe: ?sourceRecipe,
        AppShoppingItemFields.sourceMealPlan: ?sourceMealPlan,
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _getRawShoppingItemsForGroup(
    String groupId,
  ) async {
    final response = await _client
        .from(AppTables.shoppingListItems)
        .select()
        .eq(AppShoppingItemFields.groupId, groupId)
        .order(AppShoppingItemFields.checked, ascending: true)
        .order(AppShoppingItemFields.createdAt, ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> clearBoughtItems(String groupId) async {
    await _client
        .from(AppTables.shoppingListItems)
        .delete()
        .eq(AppShoppingItemFields.groupId, groupId)
        .eq(AppShoppingItemFields.checked, true);
  }

  Future<List<Map<String, dynamic>>> _getRecipesForGroup(String groupId) async {
    final response = await _client
        .from(AppTables.recipes)
        .select()
        .eq(AppRecipeFields.groupId, groupId);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> _getMealPlansForGroup(
    String groupId,
  ) async {
    final response = await _client
        .from(AppTables.mealPlans)
        .select()
        .eq(AppMealPlanFields.groupId, groupId);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> createShoppingItem({
    required String groupId,
    required String name,
    double? quantity,
    String? unit,
  }) async {
    await _client.from(AppTables.shoppingListItems).insert({
      AppShoppingItemFields.groupId: groupId,
      AppShoppingItemFields.name: name,
      AppShoppingItemFields.quantity: quantity,
      AppShoppingItemFields.unit: unit,
      AppShoppingItemFields.createdBy: _client.auth.currentUser!.id,
    });
  }

  Future<void> updateShoppingItem({
    required String shoppingItemId,
    required String name,
    double? quantity,
    String? unit,
  }) async {
    await _client
        .from(AppTables.shoppingListItems)
        .update({
          AppShoppingItemFields.name: name,
          AppShoppingItemFields.quantity: quantity,
          AppShoppingItemFields.unit: unit,
        })
        .eq(AppShoppingItemFields.id, shoppingItemId);
  }

  Future<void> setShoppingItemChecked({
    required String shoppingItemId,
    required bool checked,
  }) async {
    await _client
        .from(AppTables.shoppingListItems)
        .update({AppShoppingItemFields.checked: checked})
        .eq(AppShoppingItemFields.id, shoppingItemId);
  }

  Future<void> deleteShoppingItem(String shoppingItemId) async {
    await _client
        .from(AppTables.shoppingListItems)
        .delete()
        .eq(AppShoppingItemFields.id, shoppingItemId);
  }
}
