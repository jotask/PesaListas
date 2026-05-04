import 'package:pesalistas/core/app_tables.dart';
import 'package:pesalistas/core/meal_plan_fields.dart';
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

  Future<void> generateShoppingFromMealPlans({
    required String groupId,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    await _client.rpc(
      'generate_shopping_from_meal_plans',
      params: {
        'target_group_id': groupId,
        'from_date': _yyyyMmDd(fromDate),
        'to_date': _yyyyMmDd(toDate),
      },
    );
  }

  String _yyyyMmDd(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}
