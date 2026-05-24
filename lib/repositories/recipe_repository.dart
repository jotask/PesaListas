import 'package:flutter/material.dart';
import 'package:pesalistas/core/activity_entity_types.dart';
import 'package:pesalistas/core/app_tables.dart';
import 'package:pesalistas/core/fields/recipe_fields.dart';
import 'package:pesalistas/core/list_types.dart';
import 'package:pesalistas/repositories/activity_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pesalistas/core/app_analytics.dart';

class RecipeRepository {
  RecipeRepository(this._client);

  final SupabaseClient _client;

  ActivityRepository get _activityRepository => ActivityRepository(_client);

  Future<void> _recordRecipeActivity({
    required String groupId,
    required String eventType,
    required String body,
    String? entityId,
    Map<String, dynamic> metadata = const {},
  }) async {
    try {
      await _activityRepository.createGroupListActivity(
        groupId: groupId,
        listType: AppListTypes.recipes.value,
        eventType: eventType,
        body: body,
        entityType: entityId == null ? null : AppActivityEntityTypes.recipe,
        entityId: entityId,
        metadata: metadata,
      );
    } catch (error, stackTrace) {
      debugPrint('RECIPE ACTIVITY EVENT FAILED: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  String _recipeName(
    Map<String, dynamic>? recipe, {
    String fallback = 'recipe',
  }) {
    final value = recipe?[AppRecipeFields.name]?.toString().trim();

    if (value == null || value.isEmpty) {
      return fallback;
    }

    return value;
  }

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

    final recipeId = response[AppRecipeFields.id]?.toString();

    await _recordRecipeActivity(
      groupId: groupId,
      eventType: 'recipe_created',
      body: 'Added recipe $name',
      entityId: recipeId,
      metadata: {'recipe_id': recipeId, 'recipe_name': name},
    );

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
    final previousRecipe = await getRecipe(recipeId);
    final groupId = previousRecipe?[AppRecipeFields.groupId]?.toString();
    final previousName = _recipeName(previousRecipe, fallback: name);

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

    if (groupId != null && groupId.isNotEmpty) {
      await _recordRecipeActivity(
        groupId: groupId,
        eventType: 'recipe_info_updated',
        body: 'Updated recipe $name',
        metadata: {
          'recipe_id': recipeId,
          'recipe_name': name,
          'previous_name': previousName,
        },
        entityId: recipeId,
      );
    }

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
    final previousRecipe = await getRecipe(recipeId);
    final groupId = previousRecipe?[AppRecipeFields.groupId]?.toString();
    final recipeName = _recipeName(previousRecipe);

    await _client
        .from(AppTables.recipes)
        .update({AppRecipeFields.instructions: instructions})
        .eq(AppRecipeFields.id, recipeId);

    if (groupId != null && groupId.isNotEmpty) {
      await _recordRecipeActivity(
        groupId: groupId,
        eventType: 'recipe_instructions_updated',
        body: 'Updated instructions for $recipeName',
        metadata: {'recipe_id': recipeId, 'recipe_name': recipeName},
      );
    }

    await AppAnalytics.instance.logRecipeInstructionsUpdated(
      hasInstructions: instructions != null && instructions.trim().isNotEmpty,
    );
  }

  Future<void> deleteRecipe(String recipeId) async {
    final previousRecipe = await getRecipe(recipeId);
    final groupId = previousRecipe?[AppRecipeFields.groupId]?.toString();
    final recipeName = _recipeName(previousRecipe);

    await _client
        .from(AppTables.recipes)
        .delete()
        .eq(AppRecipeFields.id, recipeId);

    if (groupId != null && groupId.isNotEmpty) {
      await _recordRecipeActivity(
        groupId: groupId,
        eventType: 'recipe_deleted',
        body: 'Deleted recipe $recipeName',
        metadata: {'recipe_id': recipeId, 'recipe_name': recipeName},
        entityId: recipeId,
      );
    }

    await AppAnalytics.instance.logRecipeDeleted();
  }
}
