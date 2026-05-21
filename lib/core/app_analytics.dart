import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class AppAnalytics {
  AppAnalytics._();

  static final AppAnalytics instance = AppAnalytics._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  Future<void> setUserId(String? userId) async {
    await _safeRun('set_user_id', () async {
      await _analytics.setUserId(id: userId);
      await _crashlytics.setUserIdentifier(userId ?? '');
    });
  }

  Future<void> logAppOpened() async {
    await logEvent('app_opened');
  }

  Future<void> logAuthSessionRestored() async {
    await logEvent('auth_session_restored');
  }

  Future<void> logLogin({required String method}) async {
    await _safeRun('login', () async {
      await _analytics.logLogin(loginMethod: method);
    });
  }

  Future<void> logSignUp({required String method}) async {
    await _safeRun('sign_up', () async {
      await _analytics.logSignUp(signUpMethod: method);
    });
  }

  Future<void> logLogout() async {
    await logEvent('logout');
  }

  Future<void> logGroupCreated({required bool hasDescription}) async {
    await logEvent(
      'group_created',
      parameters: {
        'has_description': _boolValue(hasDescription),
      },
    );
  }

  Future<void> logGroupUpdated({required bool hasDescription}) async {
    await logEvent(
      'group_updated',
      parameters: {
        'has_description': _boolValue(hasDescription),
      },
    );
  }

  Future<void> logListCreated({required String listType}) async {
    await logEvent(
      'list_created',
      parameters: {
        'list_type': listType,
      },
    );
  }

  Future<void> logShoppingListEnsured({required bool created}) async {
    await logEvent(
      'shopping_list_ensured',
      parameters: {
        'created': _boolValue(created),
      },
    );
  }

  Future<void> logListArchived() async {
    await logEvent('list_archived');
  }

  Future<void> logListRestored() async {
    await logEvent('list_restored');
  }

  Future<void> logListDeleted() async {
    await logEvent('list_deleted');
  }

  Future<void> logItemCreated({
    required String assignmentScope,
    required bool hasDeadline,
    required bool isRecurring,
    required bool hasMovie,
  }) async {
    await logEvent(
      'item_created',
      parameters: {
        'assignment_scope': assignmentScope,
        'has_deadline': _boolValue(hasDeadline),
        'is_recurring': _boolValue(isRecurring),
        'has_movie': _boolValue(hasMovie),
      },
    );
  }

  Future<void> logItemUpdated() async {
    await logEvent('item_updated');
  }

  Future<void> logItemCompleted() async {
    await logEvent('item_completed');
  }

  Future<void> logItemReopened() async {
    await logEvent('item_reopened');
  }

  Future<void> logItemDeleted() async {
    await logEvent('item_deleted');
  }

  Future<void> logInvitationSent({required String role}) async {
    await logEvent(
      'invitation_sent',
      parameters: {
        'role': role,
      },
    );
  }

  Future<void> logInvitationAccepted() async {
    await logEvent('invitation_accepted');
  }

  Future<void> logInvitationDeclined() async {
    await logEvent('invitation_declined');
  }

  Future<void> logInvitationCanceled() async {
    await logEvent('invitation_canceled');
  }

  Future<void> logVoteUpserted({
    required int points,
    required bool hasComment,
  }) async {
    await logEvent(
      'vote_upserted',
      parameters: {
        'points': points,
        'has_comment': _boolValue(hasComment),
      },
    );
  }

  Future<void> logVoteDeleted() async {
    await logEvent('vote_deleted');
  }

  Future<void> logShoppingItemCreated({
    required String source,
    required bool hasQuantity,
    required bool hasEstimatedPrice,
    required bool hasBarcode,
    required bool hasCatalogItem,
  }) async {
    await logEvent(
      'shopping_item_created',
      parameters: {
        'source': source,
        'has_quantity': _boolValue(hasQuantity),
        'has_estimated_price': _boolValue(hasEstimatedPrice),
        'has_barcode': _boolValue(hasBarcode),
        'has_catalog_item': _boolValue(hasCatalogItem),
      },
    );
  }

  Future<void> logShoppingItemUpdated({
    required bool hasQuantity,
    required bool hasEstimatedPrice,
    required bool hasBarcode,
    required bool hasCatalogItem,
  }) async {
    await logEvent(
      'shopping_item_updated',
      parameters: {
        'has_quantity': _boolValue(hasQuantity),
        'has_estimated_price': _boolValue(hasEstimatedPrice),
        'has_barcode': _boolValue(hasBarcode),
        'has_catalog_item': _boolValue(hasCatalogItem),
      },
    );
  }

  Future<void> logShoppingItemChecked({required bool checked}) async {
    await logEvent(
      'shopping_item_checked',
      parameters: {
        'checked': _boolValue(checked),
      },
    );
  }

  Future<void> logShoppingItemDeleted() async {
    await logEvent('shopping_item_deleted');
  }

  Future<void> logShoppingItemsCleared({required String scope}) async {
    await logEvent(
      'shopping_items_cleared',
      parameters: {
        'scope': scope,
      },
    );
  }

  Future<void> logCatalogItemCreated({
    required bool hasCategory,
    required bool hasDefaultUnit,
    required bool reusedExisting,
  }) async {
    await logEvent(
      'catalog_item_created',
      parameters: {
        'has_category': _boolValue(hasCategory),
        'has_default_unit': _boolValue(hasDefaultUnit),
        'reused_existing': _boolValue(reusedExisting),
      },
    );
  }

  Future<void> logCatalogItemUpdated({
    required bool hasCategory,
    required bool hasDefaultUnit,
  }) async {
    await logEvent(
      'catalog_item_updated',
      parameters: {
        'has_category': _boolValue(hasCategory),
        'has_default_unit': _boolValue(hasDefaultUnit),
      },
    );
  }

  Future<void> logProductLookup({
    required String source,
    required bool found,
    required bool forceRefresh,
    required bool useStaging,
  }) async {
    await logEvent(
      'product_lookup',
      parameters: {
        'source': source,
        'found': _boolValue(found),
        'force_refresh': _boolValue(forceRefresh),
        'use_staging': _boolValue(useStaging),
      },
    );
  }

  Future<void> logProductPriceSaved({
    required String source,
    required bool hasStoreName,
    required bool hasNote,
    required bool hasPriceUnit,
  }) async {
    await logEvent(
      'product_price_saved',
      parameters: {
        'source': source,
        'has_store_name': _boolValue(hasStoreName),
        'has_note': _boolValue(hasNote),
        'has_price_unit': _boolValue(hasPriceUnit),
      },
    );
  }

  Future<void> logProductPriceDeleted() async {
    await logEvent('product_price_deleted');
  }

  Future<void> logRecipeCreated({required bool hasDescription}) async {
    await logEvent(
      'recipe_created',
      parameters: {
        'has_description': _boolValue(hasDescription),
      },
    );
  }

  Future<void> logRecipeInfoUpdated({
    required bool hasDescription,
    required bool hasPrepTime,
    required bool hasCookTime,
    required bool hasServings,
  }) async {
    await logEvent(
      'recipe_info_updated',
      parameters: {
        'has_description': _boolValue(hasDescription),
        'has_prep_time': _boolValue(hasPrepTime),
        'has_cook_time': _boolValue(hasCookTime),
        'has_servings': _boolValue(hasServings),
      },
    );
  }

  Future<void> logRecipeInstructionsUpdated({
    required bool hasInstructions,
  }) async {
    await logEvent(
      'recipe_instructions_updated',
      parameters: {
        'has_instructions': _boolValue(hasInstructions),
      },
    );
  }

  Future<void> logRecipeDeleted() async {
    await logEvent('recipe_deleted');
  }

  Future<void> logRecipeIngredientCreated({
    required bool hasQuantity,
    required bool hasEstimatedPrice,
    required bool hasBarcode,
    required bool hasCatalogItem,
  }) async {
    await logEvent(
      'recipe_ingredient_created',
      parameters: {
        'has_quantity': _boolValue(hasQuantity),
        'has_estimated_price': _boolValue(hasEstimatedPrice),
        'has_barcode': _boolValue(hasBarcode),
        'has_catalog_item': _boolValue(hasCatalogItem),
      },
    );
  }

  Future<void> logRecipeIngredientUpdated({
    required bool hasQuantity,
    required bool hasEstimatedPrice,
    required bool hasBarcode,
    required bool hasCatalogItem,
  }) async {
    await logEvent(
      'recipe_ingredient_updated',
      parameters: {
        'has_quantity': _boolValue(hasQuantity),
        'has_estimated_price': _boolValue(hasEstimatedPrice),
        'has_barcode': _boolValue(hasBarcode),
        'has_catalog_item': _boolValue(hasCatalogItem),
      },
    );
  }

  Future<void> logRecipeIngredientDeleted() async {
    await logEvent('recipe_ingredient_deleted');
  }

  Future<void> logMealPlanCreated({
    required String mealType,
    required bool hasRecipe,
    required bool hasNote,
  }) async {
    await logEvent(
      'meal_plan_created',
      parameters: {
        'meal_type': mealType,
        'has_recipe': _boolValue(hasRecipe),
        'has_note': _boolValue(hasNote),
      },
    );
  }

  Future<void> logMealPlanUpdated({
    required String mealType,
    required bool hasRecipe,
    required bool hasNote,
  }) async {
    await logEvent(
      'meal_plan_updated',
      parameters: {
        'meal_type': mealType,
        'has_recipe': _boolValue(hasRecipe),
        'has_note': _boolValue(hasNote),
      },
    );
  }

  Future<void> logMealPlanDeleted() async {
    await logEvent('meal_plan_deleted');
  }

  Future<void> logShoppingGeneratedFromMealPlans({
    required int insertedCount,
    required int mealPlanCount,
    required int recipeCount,
    required int dayCount,
  }) async {
    await logEvent(
      'shopping_generated_meals',
      parameters: {
        'inserted_count': insertedCount,
        'meal_plan_count': mealPlanCount,
        'recipe_count': recipeCount,
        'day_count': dayCount,
      },
    );
  }

  Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    await _safeRun(name, () async {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
    });
  }

  Future<void> recordNonFatalError(
    Object error,
    StackTrace stackTrace, {
    String? reason,
  }) async {
    await _safeRun('record_non_fatal_error', () async {
      await _crashlytics.recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: false,
      );
    });
  }

  int _boolValue(bool value) {
    return value ? 1 : 0;
  }

  Future<void> _safeRun(
    String debugLabel,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (error, stackTrace) {
      debugPrint('APP ANALYTICS ERROR [$debugLabel]: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
