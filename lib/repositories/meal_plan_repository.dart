import 'package:pesalistas/core/app_config.dart';
import 'package:pesalistas/core/app_tables.dart';
import 'package:pesalistas/core/fields/meal_plan_fields.dart';
import 'package:pesalistas/core/fields/recipe_ingredient_fields.dart';
import 'package:pesalistas/core/fields/shopping_item_fields.dart';
import 'package:pesalistas/core/value_parsing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pesalistas/core/app_analytics.dart';

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

    await AppAnalytics.instance.logMealPlanCreated(
      mealType: mealType,
      hasRecipe: recipeId != null && recipeId.trim().isNotEmpty,
      hasNote: note != null && note.trim().isNotEmpty,
    );
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

    await AppAnalytics.instance.logMealPlanUpdated(
      mealType: mealType,
      hasRecipe: recipeId != null && recipeId.trim().isNotEmpty,
      hasNote: note != null && note.trim().isNotEmpty,
    );
  }

  Future<void> deleteMealPlan(String mealPlanId) async {
    await _client
        .from(AppTables.mealPlans)
        .delete()
        .eq(AppMealPlanFields.id, mealPlanId);

    await AppAnalytics.instance.logMealPlanDeleted();
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
      await AppAnalytics.instance.logShoppingGeneratedFromMealPlans(
        insertedCount: 0,
        mealPlanCount: mealPlans.length,
        recipeCount: recipeIds.length,
        dayCount: dayCount(fromDate: fromDate, toDate: toDate),
      );

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

        final quantity = AppValueParsing.doubleOrNull(
          ingredient[AppRecipeIngredientFields.quantity],
        );

        final estimatedUnitPrice = AppValueParsing.doubleOrNull(
          ingredient[AppRecipeIngredientFields.estimatedUnitPrice],
        );

        final explicitEstimatedTotalPrice = AppValueParsing.doubleOrNull(
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
          AppShoppingItemFields.unit: AppValueParsing.textOrNull(
            ingredient[AppRecipeIngredientFields.unit],
          ),
          AppShoppingItemFields.sourceRecipeId: recipeId,
          AppShoppingItemFields.sourceMealPlanId: mealPlanId,
          AppShoppingItemFields.sourceRecipeIngredientId: ingredientId,
          AppShoppingItemFields.createdBy: currentUserId,
          AppShoppingItemFields.barcode: AppValueParsing.textOrNull(
            ingredient[AppRecipeIngredientFields.barcode],
          ),
          AppShoppingItemFields.catalogItemId: AppValueParsing.textOrNull(
            ingredient[AppRecipeIngredientFields.catalogItemId],
          ),
          AppShoppingItemFields.productName: AppValueParsing.textOrNull(
            ingredient[AppRecipeIngredientFields.productName],
          ),
          AppShoppingItemFields.productImageUrl: AppValueParsing.textOrNull(
            ingredient[AppRecipeIngredientFields.productImageUrl],
          ),
          AppShoppingItemFields.estimatedUnitPrice: estimatedUnitPrice,
          AppShoppingItemFields.estimatedTotalPrice: estimatedTotalPrice,
          AppShoppingItemFields.priceCurrency:
              AppValueParsing.textOrNull(
                ingredient[AppRecipeIngredientFields.priceCurrency],
              ) ??
              AppConfig.defaultCurrency,
        });
      }
    }

    if (rows.isEmpty) {
      await AppAnalytics.instance.logShoppingGeneratedFromMealPlans(
        insertedCount: 0,
        mealPlanCount: mealPlans.length,
        recipeCount: recipeIds.length,
        dayCount: dayCount(fromDate: fromDate, toDate: toDate),
      );

      return 0;
    }

    final uniqueRows = deduplicateGeneratedShoppingRows(rows);

    final rowsToInsert = await removeExistingGeneratedShoppingRows(
      groupId: groupId,
      rows: uniqueRows,
    );

    if (rowsToInsert.isEmpty) {
      await AppAnalytics.instance.logShoppingGeneratedFromMealPlans(
        insertedCount: 0,
        mealPlanCount: mealPlans.length,
        recipeCount: recipeIds.length,
        dayCount: dayCount(fromDate: fromDate, toDate: toDate),
      );

      return 0;
    }

    await _client.from(AppTables.shoppingListItems).insert(rowsToInsert);

    await AppAnalytics.instance.logShoppingGeneratedFromMealPlans(
      insertedCount: rowsToInsert.length,
      mealPlanCount: mealPlans.length,
      recipeCount: recipeIds.length,
      dayCount: dayCount(fromDate: fromDate, toDate: toDate),
    );

    return rowsToInsert.length;
  }

  List<Map<String, dynamic>> deduplicateGeneratedShoppingRows(
    List<Map<String, dynamic>> rows,
  ) {
    final seenKeys = <String>{};
    final uniqueRows = <Map<String, dynamic>>[];

    for (final row in rows) {
      final key = generatedShoppingUniqueKeyFromRow(row);

      if (key == null) {
        uniqueRows.add(row);
        continue;
      }

      if (seenKeys.add(key)) {
        uniqueRows.add(row);
      }
    }

    return uniqueRows;
  }

  Future<List<Map<String, dynamic>>> removeExistingGeneratedShoppingRows({
    required String groupId,
    required List<Map<String, dynamic>> rows,
  }) async {
    if (rows.isEmpty) {
      return rows;
    }

    final mealPlanIds = rows
        .map(
          (row) => AppValueParsing.textOrNull(
            row[AppShoppingItemFields.sourceMealPlanId],
          ),
        )
        .whereType<String>()
        .toSet()
        .toList();

    if (mealPlanIds.isEmpty) {
      return rows;
    }

    final existing = await _client
        .from(AppTables.shoppingListItems)
        .select(
          '${AppShoppingItemFields.sourceMealPlanId},'
          '${AppShoppingItemFields.sourceRecipeId},'
          '${AppShoppingItemFields.name},'
          '${AppShoppingItemFields.unit}',
        )
        .inFilter(AppShoppingItemFields.sourceMealPlanId, mealPlanIds);

    final existingKeys = List<Map<String, dynamic>>.from(
      existing,
    ).map(generatedShoppingUniqueKeyFromRow).whereType<String>().toSet();

    return rows.where((row) {
      final key = generatedShoppingUniqueKeyFromRow(row);

      if (key == null) {
        return true;
      }

      return !existingKeys.contains(key);
    }).toList();
  }

  String? generatedShoppingUniqueKeyFromRow(Map<String, dynamic> row) {
    final mealPlanId = AppValueParsing.textOrNull(
      row[AppShoppingItemFields.sourceMealPlanId],
    );

    final recipeId = AppValueParsing.textOrNull(
      row[AppShoppingItemFields.sourceRecipeId],
    );

    final name = AppValueParsing.textOrNull(row[AppShoppingItemFields.name]);

    if (mealPlanId == null || recipeId == null || name == null) {
      return null;
    }

    final normalizedName = name.trim().toLowerCase();
    final unit =
        AppValueParsing.textOrNull(row[AppShoppingItemFields.unit]) ?? '';

    return '$mealPlanId::$recipeId::$normalizedName::$unit';
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

  int dayCount({required DateTime fromDate, required DateTime toDate}) {
    final start = DateTime(fromDate.year, fromDate.month, fromDate.day);
    final end = DateTime(toDate.year, toDate.month, toDate.day);

    return end.difference(start).inDays.abs() + 1;
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
