import 'package:flutter/material.dart';
import 'package:pesalistas/core/app_config.dart';
import 'package:pesalistas/core/app_tables.dart';
import 'package:pesalistas/core/fields/recipe_fields.dart';
import 'package:pesalistas/core/fields/recipe_ingredient_fields.dart';
import 'package:pesalistas/core/list_types.dart';
import 'package:pesalistas/repositories/activity_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pesalistas/core/app_analytics.dart';

class RecipeIngredientRepository {
  RecipeIngredientRepository(this._client);

  final SupabaseClient _client;

  ActivityRepository get _activityRepository => ActivityRepository(_client);

  Future<Map<String, dynamic>?> _getRecipe(String recipeId) async {
    final response = await _client
        .from(AppTables.recipes)
        .select()
        .eq(AppRecipeFields.id, recipeId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>?> _getIngredient(String ingredientId) async {
    final response = await _client
        .from(AppTables.recipeIngredients)
        .select()
        .eq(AppRecipeIngredientFields.id, ingredientId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return Map<String, dynamic>.from(response);
  }

  String _ingredientName(
    Map<String, dynamic>? ingredient, {
    String fallback = 'ingredient',
  }) {
    final value = ingredient?[AppRecipeIngredientFields.name]
        ?.toString()
        .trim();

    if (value == null || value.isEmpty) {
      return fallback;
    }

    return value;
  }

  String _recipeName(Map<String, dynamic>? recipe) {
    final value = recipe?[AppRecipeFields.name]?.toString().trim();

    if (value == null || value.isEmpty) {
      return 'recipe';
    }

    return value;
  }

  Future<void> _recordIngredientActivity({
    required String recipeId,
    required String eventType,
    required String body,
    Map<String, dynamic> metadata = const {},
  }) async {
    try {
      final recipe = await _getRecipe(recipeId);
      final groupId = recipe?[AppRecipeFields.groupId]?.toString();

      if (groupId == null || groupId.isEmpty) {
        return;
      }

      await _activityRepository.createGroupListActivity(
        groupId: groupId,
        listType: AppListTypes.recipes.value,
        eventType: eventType,
        body: body,
        metadata: {
          'recipe_id': recipeId,
          'recipe_name': _recipeName(recipe),
          ...metadata,
        },
      );
    } catch (error, stackTrace) {
      debugPrint('RECIPE INGREDIENT ACTIVITY EVENT FAILED: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<List<Map<String, dynamic>>> getIngredientsForRecipe(
    String recipeId,
  ) async {
    final response = await _client
        .from(AppTables.recipeIngredients)
        .select()
        .eq(AppRecipeIngredientFields.recipeId, recipeId)
        .order(AppRecipeIngredientFields.createdAt);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> createIngredient({
    required String recipeId,
    required String name,
    double? quantity,
    String? unit,
    String? note,
    double? estimatedUnitPrice,
    String priceCurrency = AppConfig.defaultCurrency,
    String? barcode,
    String? catalogItemId,
    String? productName,
    String? productImageUrl,
  }) async {
    final estimatedTotalPrice = quantity != null && estimatedUnitPrice != null
        ? quantity * estimatedUnitPrice
        : estimatedUnitPrice;

    final response = await _client
        .from(AppTables.recipeIngredients)
        .insert({
          AppRecipeIngredientFields.recipeId: recipeId,
          AppRecipeIngredientFields.name: name,
          AppRecipeIngredientFields.quantity: quantity,
          AppRecipeIngredientFields.unit: unit,
          AppRecipeIngredientFields.note: note,
          AppRecipeIngredientFields.estimatedUnitPrice: estimatedUnitPrice,
          AppRecipeIngredientFields.estimatedTotalPrice: estimatedTotalPrice,
          AppRecipeIngredientFields.priceCurrency: priceCurrency,
          AppRecipeIngredientFields.barcode: barcode,
          AppRecipeIngredientFields.catalogItemId: catalogItemId,
          AppRecipeIngredientFields.productName: productName,
          AppRecipeIngredientFields.productImageUrl: productImageUrl,
        })
        .select()
        .single();

    await _recordIngredientActivity(
      recipeId: recipeId,
      eventType: 'recipe_ingredient_created',
      body: 'Added ingredient $name',
      metadata: {
        'ingredient_id': response[AppRecipeIngredientFields.id]?.toString(),
        'ingredient_name': name,
      },
    );
    await AppAnalytics.instance.logRecipeIngredientCreated(
      hasQuantity: quantity != null,
      hasEstimatedPrice: estimatedUnitPrice != null,
      hasBarcode: barcode != null && barcode.trim().isNotEmpty,
      hasCatalogItem: catalogItemId != null && catalogItemId.trim().isNotEmpty,
    );
  }

  Future<void> updateIngredient({
    required String ingredientId,
    required String name,
    double? quantity,
    String? unit,
    String? note,
    double? estimatedUnitPrice,
    String priceCurrency = AppConfig.defaultCurrency,
    String? barcode,
    String? catalogItemId,
    String? productName,
    String? productImageUrl,
  }) async {
    final previousIngredient = await _getIngredient(ingredientId);
    final recipeId = previousIngredient?[AppRecipeIngredientFields.recipeId]
        ?.toString();
    final previousName = _ingredientName(previousIngredient, fallback: name);

    final estimatedTotalPrice = quantity != null && estimatedUnitPrice != null
        ? quantity * estimatedUnitPrice
        : estimatedUnitPrice;

    await _client
        .from(AppTables.recipeIngredients)
        .update({
          AppRecipeIngredientFields.name: name,
          AppRecipeIngredientFields.quantity: quantity,
          AppRecipeIngredientFields.unit: unit,
          AppRecipeIngredientFields.note: note,
          AppRecipeIngredientFields.estimatedUnitPrice: estimatedUnitPrice,
          AppRecipeIngredientFields.estimatedTotalPrice: estimatedTotalPrice,
          AppRecipeIngredientFields.priceCurrency: priceCurrency,
          AppRecipeIngredientFields.barcode: barcode,
          AppRecipeIngredientFields.catalogItemId: catalogItemId,
          AppRecipeIngredientFields.productName: productName,
          AppRecipeIngredientFields.productImageUrl: productImageUrl,
        })
        .eq(AppRecipeIngredientFields.id, ingredientId);

    if (recipeId != null && recipeId.isNotEmpty) {
      await _recordIngredientActivity(
        recipeId: recipeId,
        eventType: 'recipe_ingredient_updated',
        body: 'Updated ingredient $name',
        metadata: {
          'ingredient_id': ingredientId,
          'ingredient_name': name,
          'previous_name': previousName,
        },
      );
    }

    await AppAnalytics.instance.logRecipeIngredientUpdated(
      hasQuantity: quantity != null,
      hasEstimatedPrice: estimatedUnitPrice != null,
      hasBarcode: barcode != null && barcode.trim().isNotEmpty,
      hasCatalogItem: catalogItemId != null && catalogItemId.trim().isNotEmpty,
    );
  }

  Future<void> deleteIngredient(String ingredientId) async {
    final previousIngredient = await _getIngredient(ingredientId);
    final recipeId = previousIngredient?[AppRecipeIngredientFields.recipeId]
        ?.toString();
    final ingredientName = _ingredientName(previousIngredient);

    await _client
        .from(AppTables.recipeIngredients)
        .delete()
        .eq(AppRecipeIngredientFields.id, ingredientId);

    if (recipeId != null && recipeId.isNotEmpty) {
      await _recordIngredientActivity(
        recipeId: recipeId,
        eventType: 'recipe_ingredient_deleted',
        body: 'Deleted ingredient $ingredientName',
        metadata: {
          'ingredient_id': ingredientId,
          'ingredient_name': ingredientName,
        },
      );
    }

    await AppAnalytics.instance.logRecipeIngredientDeleted();
  }
}
