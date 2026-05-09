import 'package:pesalistas/core/app_tables.dart';
import 'package:pesalistas/core/meal_plan_fields.dart';
import 'package:pesalistas/core/recipe_ingredient_fields.dart';
import 'package:pesalistas/core/shopping_item_fields.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MealPlanRepository {
  MealPlanRepository(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> getMealPlansForGroup(
    String groupId,
  ) async {
    final response = await _client
        .from(AppTables.mealPlans)
        .select()
        .eq(AppMealPlanFields.groupId, groupId)
        .order(AppMealPlanFields.plannedFor, ascending: true)
        .order(AppMealPlanFields.createdAt, ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> createMealPlan({
    required String groupId,
    required DateTime plannedFor,
    required String mealType,
    String? recipeId,
    String? note,
  }) async {
    await _client.from(AppTables.mealPlans).insert({
      AppMealPlanFields.groupId: groupId,
      AppMealPlanFields.recipeId: recipeId,
      AppMealPlanFields.plannedFor: _yyyyMmDd(plannedFor),
      AppMealPlanFields.mealType: mealType,
      AppMealPlanFields.note: note,
      AppMealPlanFields.createdBy: _client.auth.currentUser!.id,
    });
  }

  Future<void> updateMealPlan({
    required String mealPlanId,
    required DateTime plannedFor,
    required String mealType,
    String? recipeId,
    String? note,
  }) async {
    await _client
        .from(AppTables.mealPlans)
        .update({
          AppMealPlanFields.recipeId: recipeId,
          AppMealPlanFields.plannedFor: _yyyyMmDd(plannedFor),
          AppMealPlanFields.mealType: mealType,
          AppMealPlanFields.note: note,
        })
        .eq(AppMealPlanFields.id, mealPlanId);
  }

  Future<void> deleteMealPlan(String mealPlanId) async {
    await _client
        .from(AppTables.mealPlans)
        .delete()
        .eq(AppMealPlanFields.id, mealPlanId);
  }

  Future<int> generateShoppingFromMealPlans({
    required String groupId,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    final mealPlansResponse = await _client
        .from(AppTables.mealPlans)
        .select()
        .eq(AppMealPlanFields.groupId, groupId)
        .gte(AppMealPlanFields.plannedFor, dateOnly(fromDate))
        .lte(AppMealPlanFields.plannedFor, dateOnly(toDate));

    final mealPlans = List<Map<String, dynamic>>.from(mealPlansResponse);

    final recipeIds = mealPlans
        .map((mealPlan) => mealPlan[AppMealPlanFields.recipeId]?.toString())
        .whereType<String>()
        .where((recipeId) => recipeId.isNotEmpty)
        .toSet()
        .toList();

    final mealPlanIds = mealPlans
        .map((mealPlan) => mealPlan[AppMealPlanFields.id]?.toString())
        .whereType<String>()
        .where((mealPlanId) => mealPlanId.isNotEmpty)
        .toSet()
        .toList();

    if (mealPlans.isEmpty || recipeIds.isEmpty || mealPlanIds.isEmpty) {
      return 0;
    }

    final ingredientsResponse = await _client
        .from(AppTables.recipeIngredients)
        .select()
        .inFilter(AppRecipeIngredientFields.recipeId, recipeIds)
        .order(AppRecipeIngredientFields.name, ascending: true);

    final ingredients = List<Map<String, dynamic>>.from(ingredientsResponse);

    final existingGeneratedResponse = await _client
        .from(AppTables.shoppingListItems)
        .select(
          '${AppShoppingItemFields.sourceMealPlanId}, '
          '${AppShoppingItemFields.sourceRecipeIngredientId}',
        )
        .eq(AppShoppingItemFields.groupId, groupId)
        .inFilter(AppShoppingItemFields.sourceMealPlanId, mealPlanIds)
        .not(AppShoppingItemFields.sourceRecipeIngredientId, 'is', null);

    final existingGeneratedItems = List<Map<String, dynamic>>.from(
      existingGeneratedResponse,
    );

    final existingGeneratedKeys = existingGeneratedItems.map((item) {
      final mealPlanId = item[AppShoppingItemFields.sourceMealPlanId]
          ?.toString();
      final ingredientId = item[AppShoppingItemFields.sourceRecipeIngredientId]
          ?.toString();

      return generatedKey(
        mealPlanId: mealPlanId,
        recipeIngredientId: ingredientId,
      );
    }).toSet();

    final ingredientsByRecipeId = <String, List<Map<String, dynamic>>>{};

    for (final ingredient in ingredients) {
      final recipeId = ingredient[AppRecipeIngredientFields.recipeId]
          ?.toString();

      if (recipeId == null || recipeId.isEmpty) {
        continue;
      }

      ingredientsByRecipeId.putIfAbsent(recipeId, () => []).add(ingredient);
    }

    final currentUserId = _client.auth.currentUser?.id;
    final rows = <Map<String, dynamic>>[];

    for (final mealPlan in mealPlans) {
      final mealPlanId = mealPlan[AppMealPlanFields.id]?.toString();
      final recipeId = mealPlan[AppMealPlanFields.recipeId]?.toString();

      if (mealPlanId == null ||
          mealPlanId.isEmpty ||
          recipeId == null ||
          recipeId.isEmpty) {
        continue;
      }

      final recipeIngredients = ingredientsByRecipeId[recipeId] ?? [];

      for (final ingredient in recipeIngredients) {
        final ingredientId = ingredient[AppRecipeIngredientFields.id]
            ?.toString();
        final name = ingredient[AppRecipeIngredientFields.name]?.toString();

        if (ingredientId == null ||
            ingredientId.isEmpty ||
            name == null ||
            name.trim().isEmpty) {
          continue;
        }

        final key = generatedKey(
          mealPlanId: mealPlanId,
          recipeIngredientId: ingredientId,
        );

        if (existingGeneratedKeys.contains(key)) {
          continue;
        }

        existingGeneratedKeys.add(key);

        final quantity = doubleOrNull(
          ingredient[AppRecipeIngredientFields.quantity],
        );

        final estimatedUnitPrice = doubleOrNull(
          ingredient[AppRecipeIngredientFields.estimatedUnitPrice],
        );

        final explicitEstimatedTotalPrice = doubleOrNull(
          ingredient[AppRecipeIngredientFields.estimatedTotalPrice],
        );

        final estimatedTotalPrice =
            explicitEstimatedTotalPrice ??
            estimatedTotalFromQuantityAndUnitPrice(
              quantity: quantity,
              estimatedUnitPrice: estimatedUnitPrice,
            );

        rows.add({
          AppShoppingItemFields.groupId: groupId,
          AppShoppingItemFields.name: name.trim(),
          AppShoppingItemFields.quantity: quantity,
          AppShoppingItemFields.unit: nullableText(
            ingredient[AppRecipeIngredientFields.unit],
          ),
          AppShoppingItemFields.sourceRecipeId: recipeId,
          AppShoppingItemFields.sourceMealPlanId: mealPlanId,
          AppShoppingItemFields.sourceRecipeIngredientId: ingredientId,
          AppShoppingItemFields.createdBy: currentUserId,
          AppShoppingItemFields.barcode: nullableText(
            ingredient[AppRecipeIngredientFields.barcode],
          ),
          AppShoppingItemFields.productName: nullableText(
            ingredient[AppRecipeIngredientFields.productName],
          ),
          AppShoppingItemFields.productImageUrl: nullableText(
            ingredient[AppRecipeIngredientFields.productImageUrl],
          ),
          AppShoppingItemFields.estimatedUnitPrice: estimatedUnitPrice,
          AppShoppingItemFields.estimatedTotalPrice: estimatedTotalPrice,
          AppShoppingItemFields.priceCurrency:
              nullableText(
                ingredient[AppRecipeIngredientFields.priceCurrency],
              ) ??
              'EUR',
        });
      }
    }

    if (rows.isEmpty) {
      return 0;
    }

    await _client.from(AppTables.shoppingListItems).insert(rows);
    return rows.length;
  }

  String generatedKey({
    required String? mealPlanId,
    required String? recipeIngredientId,
  }) {
    return '${mealPlanId ?? ''}:${recipeIngredientId ?? ''}';
  }

  String dateOnly(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  String? nullableText(dynamic value) {
    final text = value?.toString().trim();

    if (text == null || text.isEmpty) {
      return null;
    }

    return text;
  }

  double? doubleOrNull(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString().replaceAll(',', '.'));
  }

  double? estimatedTotalFromQuantityAndUnitPrice({
    required double? quantity,
    required double? estimatedUnitPrice,
  }) {
    if (estimatedUnitPrice == null) {
      return null;
    }

    if (quantity == null) {
      return estimatedUnitPrice;
    }

    return quantity * estimatedUnitPrice;
  }

  String _yyyyMmDd(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}
