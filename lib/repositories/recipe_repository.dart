import 'package:pesalistas/core/app_tables.dart';
import 'package:pesalistas/core/recipe_fields.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecipeRepository {
  RecipeRepository(this._client);

  final SupabaseClient _client;

  Future<Map<String, dynamic>?> getRecipeForItem(String itemId) async {
    final response = await _client
        .from(AppTables.recipes)
        .select()
        .eq(AppRecipeFields.itemId, itemId)
        .maybeSingle();

    return response;
  }

  Future<Map<String, dynamic>> ensureRecipeForItem(String itemId) async {
    final existing = await getRecipeForItem(itemId);

    if (existing != null) {
      return existing;
    }

    final response = await _client
        .from(AppTables.recipes)
        .insert({AppRecipeFields.itemId: itemId})
        .select()
        .single();

    return Map<String, dynamic>.from(response);
  }
}
