import 'package:pesalistas/core/app_tables.dart';
import 'package:pesalistas/core/recipe_ingredient_fields.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecipeIngredientRepository {
  RecipeIngredientRepository(this._client);

  final SupabaseClient _client;

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
    String priceCurrency = 'EUR',
    String? barcode,
    String? productName,
    String? productImageUrl,
  }) async {
    final estimatedTotalPrice = quantity != null && estimatedUnitPrice != null
        ? quantity * estimatedUnitPrice
        : estimatedUnitPrice;

    await _client.from(AppTables.recipeIngredients).insert({
      AppRecipeIngredientFields.recipeId: recipeId,
      AppRecipeIngredientFields.name: name,
      AppRecipeIngredientFields.quantity: quantity,
      AppRecipeIngredientFields.unit: unit,
      AppRecipeIngredientFields.note: note,
      AppRecipeIngredientFields.estimatedUnitPrice: estimatedUnitPrice,
      AppRecipeIngredientFields.estimatedTotalPrice: estimatedTotalPrice,
      AppRecipeIngredientFields.priceCurrency: priceCurrency,
      AppRecipeIngredientFields.barcode: barcode,
      AppRecipeIngredientFields.productName: productName,
      AppRecipeIngredientFields.productImageUrl: productImageUrl,
    });
  }

  Future<void> updateIngredient({
    required String ingredientId,
    required String name,
    double? quantity,
    String? unit,
    String? note,
    double? estimatedUnitPrice,
    String priceCurrency = 'EUR',
    String? barcode,
    String? productName,
    String? productImageUrl,
  }) async {
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
          AppRecipeIngredientFields.productName: productName,
          AppRecipeIngredientFields.productImageUrl: productImageUrl,
        })
        .eq(AppRecipeIngredientFields.id, ingredientId);
  }

  Future<void> deleteIngredient(String ingredientId) async {
    await _client
        .from(AppTables.recipeIngredients)
        .delete()
        .eq(AppRecipeIngredientFields.id, ingredientId);
  }
}
