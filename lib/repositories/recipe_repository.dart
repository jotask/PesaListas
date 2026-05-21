import 'package:pesalistas/core/app_tables.dart';
import 'package:pesalistas/core/fields/recipe_fields.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pesalistas/core/app_analytics.dart';

class RecipeRepository {
  RecipeRepository(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> getRecipesForGroup(String groupId) async {
    final response = await _client
        .from(AppTables.recipes)
        .select()
        .eq(AppRecipeFields.groupId, groupId)
        .order(AppRecipeFields.createdAt, ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createRecipe({
    required String groupId,
    required String name,
    String? description,
  }) async {
    final response = await _client
        .from(AppTables.recipes)
        .insert({
          AppRecipeFields.groupId: groupId,
          AppRecipeFields.name: name,
          AppRecipeFields.description: description,
          AppRecipeFields.createdBy: _client.auth.currentUser!.id,
        })
        .select()
        .single();

    await AppAnalytics.instance.logRecipeCreated(
      hasDescription: description != null && description.trim().isNotEmpty,
    );

    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>?> getRecipe(String recipeId) async {
    final response = await _client
        .from(AppTables.recipes)
        .select()
        .eq(AppRecipeFields.id, recipeId)
        .maybeSingle();

    return response;
  }

  Future<void> updateRecipeInfo({
    required String recipeId,
    required String name,
    String? description,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    int? servings,
  }) async {
    await _client
        .from(AppTables.recipes)
        .update({
          AppRecipeFields.name: name,
          AppRecipeFields.description: description,
          AppRecipeFields.prepTimeMinutes: prepTimeMinutes,
          AppRecipeFields.cookTimeMinutes: cookTimeMinutes,
          AppRecipeFields.servings: servings,
        })
        .eq(AppRecipeFields.id, recipeId);

    await AppAnalytics.instance.logRecipeInfoUpdated(
      hasDescription: description != null && description.trim().isNotEmpty,
      hasPrepTime: prepTimeMinutes != null,
      hasCookTime: cookTimeMinutes != null,
      hasServings: servings != null,
    );
  }

  Future<void> updateRecipeInstructions({
    required String recipeId,
    String? instructions,
  }) async {
    await _client
        .from(AppTables.recipes)
        .update({AppRecipeFields.instructions: instructions})
        .eq(AppRecipeFields.id, recipeId);

    await AppAnalytics.instance.logRecipeInstructionsUpdated(
      hasInstructions: instructions != null && instructions.trim().isNotEmpty,
    );
  }

  Future<void> deleteRecipe(String recipeId) async {
    await _client
        .from(AppTables.recipes)
        .delete()
        .eq(AppRecipeFields.id, recipeId);

    await AppAnalytics.instance.logRecipeDeleted();
  }
}
