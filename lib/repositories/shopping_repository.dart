import 'package:flutter/material.dart';
import 'package:pesalistas/core/activity_entity_types.dart';
import 'package:pesalistas/core/app_config.dart';
import 'package:pesalistas/core/app_tables.dart';
import 'package:pesalistas/core/fields/meal_plan_fields.dart';
import 'package:pesalistas/core/fields/recipe_fields.dart';
import 'package:pesalistas/core/fields/shopping_item_fields.dart';
import 'package:pesalistas/core/list_types.dart';
import 'package:pesalistas/repositories/activity_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pesalistas/core/app_analytics.dart';

class ShoppingRepository {
  ShoppingRepository(this._client);

  final SupabaseClient _client;

  ActivityRepository get _activityRepository => ActivityRepository(_client);

  Future<Map<String, dynamic>?> _getShoppingItem(String shoppingItemId) async {
    final response = await _client
        .from(AppTables.shoppingListItems)
        .select()
        .eq(AppShoppingItemFields.id, shoppingItemId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return Map<String, dynamic>.from(response);
  }

  String _shoppingItemName(
    Map<String, dynamic>? item, {
    String fallback = 'item',
  }) {
    final value = item?[AppShoppingItemFields.name]?.toString().trim();

    if (value == null || value.isEmpty) {
      return fallback;
    }

    return value;
  }

  Future<void> _recordShoppingActivity({
    required String groupId,
    required String eventType,
    required String body,
    Map<String, dynamic> metadata = const {},
    String? entityId,
  }) async {
    try {
      await _activityRepository.createGroupListActivity(
        groupId: groupId,
        listType: AppListTypes.shopping.value,
        eventType: eventType,
        body: body,
        metadata: metadata,
        entityType: entityId == null
            ? null
            : AppActivityEntityTypes.shoppingItem,
        entityId: entityId,
      );
    } catch (error, stackTrace) {
      debugPrint('SHOPPING ACTIVITY EVENT FAILED: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

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
        AppShoppingItemFields.sourceRecipe: sourceRecipe,
        AppShoppingItemFields.sourceMealPlan: sourceMealPlan,
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

  Future<void> clearAllItems(String groupId) async {
    final existingResponse = await _client
        .from(AppTables.shoppingListItems)
        .select(AppShoppingItemFields.id)
        .eq(AppShoppingItemFields.groupId, groupId);

    final existingItems = List<Map<String, dynamic>>.from(existingResponse);
    final count = existingItems.length;

    await _client
        .from(AppTables.shoppingListItems)
        .delete()
        .eq(AppShoppingItemFields.groupId, groupId);

    if (count > 0) {
      await _recordShoppingActivity(
        groupId: groupId,
        eventType: 'shopping_items_cleared',
        body: 'Cleared $count shopping ${count == 1 ? 'item' : 'items'}',
        metadata: {'count': count},
      );
    }

    await AppAnalytics.instance.logShoppingItemsCleared(scope: 'all');
  }

  Future<void> clearBoughtItems(String groupId) async {
    final existingResponse = await _client
        .from(AppTables.shoppingListItems)
        .select(AppShoppingItemFields.id)
        .eq(AppShoppingItemFields.groupId, groupId)
        .eq(AppShoppingItemFields.checked, true);

    final existingItems = List<Map<String, dynamic>>.from(existingResponse);
    final count = existingItems.length;

    await _client
        .from(AppTables.shoppingListItems)
        .delete()
        .eq(AppShoppingItemFields.groupId, groupId)
        .eq(AppShoppingItemFields.checked, true);

    if (count > 0) {
      await _recordShoppingActivity(
        groupId: groupId,
        eventType: 'shopping_bought_items_cleared',
        body: 'Cleared $count bought shopping ${count == 1 ? 'item' : 'items'}',
        metadata: {'count': count},
      );
    }

    await AppAnalytics.instance.logShoppingItemsCleared(scope: 'bought');
  }

  Future<Map<String, dynamic>> createShoppingItemFromProduct({
    required String groupId,
    required String name,
    double? quantity,
    String? unit,
    String? barcode,
    String? catalogItemId,
    String? productName,
    String? productImageUrl,
    double? estimatedUnitPrice,
    String priceCurrency = AppConfig.defaultCurrency,
    String? storeKey,
    String? storeName,
  }) async {
    final estimatedTotalPrice = quantity != null && estimatedUnitPrice != null
        ? quantity * estimatedUnitPrice
        : estimatedUnitPrice;

    final currentUserId = _client.auth.currentUser?.id;

    if (currentUserId == null) {
      throw StateError('User must be signed in to create a shopping item.');
    }

    final row = {
      AppShoppingItemFields.groupId: groupId,
      AppShoppingItemFields.name: name,
      AppShoppingItemFields.quantity: quantity,
      AppShoppingItemFields.unit: unit,
      AppShoppingItemFields.barcode: barcode,
      AppShoppingItemFields.catalogItemId: catalogItemId,
      AppShoppingItemFields.productName: productName,
      AppShoppingItemFields.productImageUrl: productImageUrl,
      AppShoppingItemFields.estimatedUnitPrice: estimatedUnitPrice,
      AppShoppingItemFields.estimatedTotalPrice: estimatedTotalPrice,
      AppShoppingItemFields.priceCurrency: priceCurrency,
      AppShoppingItemFields.createdBy: currentUserId,
      AppShoppingItemFields.storeKey: storeKey,
      AppShoppingItemFields.storeName: storeName,
    };

    final result = await _client
        .from(AppTables.shoppingListItems)
        .insert(row)
        .select()
        .single();

    final shoppingItemId = result[AppShoppingItemFields.id]?.toString();

    await _recordShoppingActivity(
      groupId: groupId,
      eventType: 'shopping_item_created',
      body: 'Added $name',
      entityId: shoppingItemId,
      metadata: {
        'shopping_item_id': shoppingItemId,
        'item_name': name,
        'source': 'product',
      },
    );

    await AppAnalytics.instance.logShoppingItemCreated(
      source: 'product',
      hasQuantity: quantity != null,
      hasEstimatedPrice: estimatedUnitPrice != null,
      hasBarcode: barcode != null && barcode.trim().isNotEmpty,
      hasCatalogItem: catalogItemId != null && catalogItemId.trim().isNotEmpty,
    );

    return result;
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
    double? estimatedUnitPrice,
    String priceCurrency = AppConfig.defaultCurrency,
    String? barcode,
    String? catalogItemId,
    String? productName,
    String? productImageUrl,
    String? storeKey,
    String? storeName,
  }) async {
    final estimatedTotalPrice = quantity != null && estimatedUnitPrice != null
        ? quantity * estimatedUnitPrice
        : estimatedUnitPrice;

    final result = await _client
        .from(AppTables.shoppingListItems)
        .insert({
          AppShoppingItemFields.groupId: groupId,
          AppShoppingItemFields.name: name,
          AppShoppingItemFields.quantity: quantity,
          AppShoppingItemFields.unit: unit,
          AppShoppingItemFields.estimatedUnitPrice: estimatedUnitPrice,
          AppShoppingItemFields.estimatedTotalPrice: estimatedTotalPrice,
          AppShoppingItemFields.priceCurrency: priceCurrency,
          AppShoppingItemFields.barcode: barcode,
          AppShoppingItemFields.catalogItemId: catalogItemId,
          AppShoppingItemFields.productName: productName,
          AppShoppingItemFields.productImageUrl: productImageUrl,
          AppShoppingItemFields.storeKey: storeKey,
          AppShoppingItemFields.storeName: storeName,
          AppShoppingItemFields.createdBy: _client.auth.currentUser!.id,
        })
        .select()
        .single();

    final shoppingItemId = result[AppShoppingItemFields.id]?.toString();

    await _recordShoppingActivity(
      groupId: groupId,
      eventType: 'shopping_item_created',
      body: 'Added $name',
      entityId: shoppingItemId,
      metadata: {
        'shopping_item_id': shoppingItemId,
        'item_name': name,
        'source': 'manual',
      },
    );

    await AppAnalytics.instance.logShoppingItemCreated(
      source: 'manual',
      hasQuantity: quantity != null,
      hasEstimatedPrice: estimatedUnitPrice != null,
      hasBarcode: barcode != null && barcode.trim().isNotEmpty,
      hasCatalogItem: catalogItemId != null && catalogItemId.trim().isNotEmpty,
    );
  }

  Future<void> updateShoppingItem({
    required String shoppingItemId,
    required String name,
    double? quantity,
    String? unit,
    double? estimatedUnitPrice,
    String priceCurrency = AppConfig.defaultCurrency,
    String? barcode,
    String? catalogItemId,
    String? productName,
    String? productImageUrl,
    String? storeKey,
    String? storeName,
  }) async {
    final previousItem = await _getShoppingItem(shoppingItemId);
    final groupId = previousItem?[AppShoppingItemFields.groupId]?.toString();
    final previousName = _shoppingItemName(previousItem, fallback: name);

    final estimatedTotalPrice = quantity != null && estimatedUnitPrice != null
        ? quantity * estimatedUnitPrice
        : estimatedUnitPrice;

    await _client
        .from(AppTables.shoppingListItems)
        .update({
          AppShoppingItemFields.name: name,
          AppShoppingItemFields.quantity: quantity,
          AppShoppingItemFields.unit: unit,
          AppShoppingItemFields.estimatedUnitPrice: estimatedUnitPrice,
          AppShoppingItemFields.estimatedTotalPrice: estimatedTotalPrice,
          AppShoppingItemFields.priceCurrency: priceCurrency,
          AppShoppingItemFields.barcode: barcode,
          AppShoppingItemFields.catalogItemId: catalogItemId,
          AppShoppingItemFields.productName: productName,
          AppShoppingItemFields.productImageUrl: productImageUrl,
          AppShoppingItemFields.storeKey: storeKey,
          AppShoppingItemFields.storeName: storeName,
        })
        .eq(AppShoppingItemFields.id, shoppingItemId);

    if (groupId != null && groupId.isNotEmpty) {
      await _recordShoppingActivity(
        groupId: groupId,
        eventType: 'shopping_item_updated',
        body: 'Updated $name',
        metadata: {
          'shopping_item_id': shoppingItemId,
          'item_name': name,
          'previous_name': previousName,
        },
        entityId: shoppingItemId,
      );
    }

    await AppAnalytics.instance.logShoppingItemUpdated(
      hasQuantity: quantity != null,
      hasEstimatedPrice: estimatedUnitPrice != null,
      hasBarcode: barcode != null && barcode.trim().isNotEmpty,
      hasCatalogItem: catalogItemId != null && catalogItemId.trim().isNotEmpty,
    );
  }

  Future<void> setShoppingItemChecked({
    required String shoppingItemId,
    required bool checked,
  }) async {
    final previousItem = await _getShoppingItem(shoppingItemId);
    final groupId = previousItem?[AppShoppingItemFields.groupId]?.toString();
    final itemName = _shoppingItemName(previousItem);

    await _client
        .from(AppTables.shoppingListItems)
        .update({AppShoppingItemFields.checked: checked})
        .eq(AppShoppingItemFields.id, shoppingItemId);

    if (groupId != null && groupId.isNotEmpty) {
      await _recordShoppingActivity(
        groupId: groupId,
        eventType: checked
            ? 'shopping_item_checked'
            : 'shopping_item_unchecked',
        body: checked ? 'Bought $itemName' : 'Marked $itemName as not bought',
        entityId: shoppingItemId,
        metadata: {
          'shopping_item_id': shoppingItemId,
          'item_name': itemName,
          'checked': checked,
        },
      );
    }

    await AppAnalytics.instance.logShoppingItemChecked(checked: checked);
  }

  Future<void> deleteShoppingItem(String shoppingItemId) async {
    final previousItem = await _getShoppingItem(shoppingItemId);
    final groupId = previousItem?[AppShoppingItemFields.groupId]?.toString();
    final itemName = _shoppingItemName(previousItem);

    await _client
        .from(AppTables.shoppingListItems)
        .delete()
        .eq(AppShoppingItemFields.id, shoppingItemId);

    if (groupId != null && groupId.isNotEmpty) {
      await _recordShoppingActivity(
        groupId: groupId,
        eventType: 'shopping_item_deleted',
        body: 'Deleted $itemName',
        metadata: {'shopping_item_id': shoppingItemId, 'item_name': itemName},
        entityId: shoppingItemId,
      );
    }

    await AppAnalytics.instance.logShoppingItemDeleted();
  }
}
