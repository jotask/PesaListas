import 'package:flutter_test/flutter_test.dart';
import 'package:pesalistas/core/fields/shopping_item_fields.dart';
import 'package:pesalistas/repositories/meal_plan_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

SupabaseClient _client() {
  return SupabaseClient('https://example.supabase.co', 'dummy-anon-key');
}

void main() {
  group('MealPlanRepository date helpers', () {
    test('dateOnly formats yyyy-mm-dd', () {
      final repository = MealPlanRepository(_client());

      expect(repository.dateOnly(DateTime(2026, 5, 3, 15, 30)), '2026-05-03');
    });

    test('dayCount is inclusive and order independent', () {
      final repository = MealPlanRepository(_client());

      expect(
        repository.dayCount(
          fromDate: DateTime(2026, 5, 1),
          toDate: DateTime(2026, 5, 1),
        ),
        1,
      );
      expect(
        repository.dayCount(
          fromDate: DateTime(2026, 5, 1),
          toDate: DateTime(2026, 5, 3),
        ),
        3,
      );
      expect(
        repository.dayCount(
          fromDate: DateTime(2026, 5, 3),
          toDate: DateTime(2026, 5, 1),
        ),
        3,
      );
    });
  });

  group('MealPlanRepository generated shopping keys', () {
    test('generatedKey handles nulls consistently', () {
      final repository = MealPlanRepository(_client());

      expect(
        repository.generatedKey(
          mealPlanId: 'meal-1',
          recipeIngredientId: 'ing-1',
        ),
        'meal-1:ing-1',
      );
      expect(
        repository.generatedKey(mealPlanId: null, recipeIngredientId: 'ing-1'),
        ':ing-1',
      );
      expect(
        repository.generatedKey(mealPlanId: 'meal-1', recipeIngredientId: null),
        'meal-1:',
      );
    });

    test('generatedShoppingUniqueKeyFromRow normalizes item name', () {
      final repository = MealPlanRepository(_client());

      final key = repository.generatedShoppingUniqueKeyFromRow({
        AppShoppingItemFields.sourceMealPlanId: 'meal-1',
        AppShoppingItemFields.sourceRecipeId: 'recipe-1',
        AppShoppingItemFields.name: '  Milk  ',
        AppShoppingItemFields.unit: 'l',
      });

      expect(key, 'meal-1::recipe-1::milk::l');
    });

    test(
      'generatedShoppingUniqueKeyFromRow returns null when required fields are missing',
      () {
        final repository = MealPlanRepository(_client());

        expect(repository.generatedShoppingUniqueKeyFromRow({}), isNull);
        expect(
          repository.generatedShoppingUniqueKeyFromRow({
            AppShoppingItemFields.sourceMealPlanId: 'meal-1',
            AppShoppingItemFields.sourceRecipeId: 'recipe-1',
          }),
          isNull,
        );
      },
    );

    test('deduplicateGeneratedShoppingRows keeps first duplicate only', () {
      final repository = MealPlanRepository(_client());
      final first = {
        AppShoppingItemFields.sourceMealPlanId: 'meal-1',
        AppShoppingItemFields.sourceRecipeId: 'recipe-1',
        AppShoppingItemFields.name: 'Milk',
        AppShoppingItemFields.unit: 'l',
      };
      final duplicate = {
        AppShoppingItemFields.sourceMealPlanId: 'meal-1',
        AppShoppingItemFields.sourceRecipeId: 'recipe-1',
        AppShoppingItemFields.name: ' milk ',
        AppShoppingItemFields.unit: 'l',
      };
      final different = {
        AppShoppingItemFields.sourceMealPlanId: 'meal-1',
        AppShoppingItemFields.sourceRecipeId: 'recipe-1',
        AppShoppingItemFields.name: 'Milk',
        AppShoppingItemFields.unit: 'kg',
      };

      final result = repository.deduplicateGeneratedShoppingRows([
        first,
        duplicate,
        different,
      ]);

      expect(result, [first, different]);
    });
  });

  group('MealPlanRepository estimated totals', () {
    test('uses unit price when quantity is missing', () {
      final repository = MealPlanRepository(_client());

      expect(
        repository.estimatedTotalFromQuantityAndUnitPrice(
          quantity: null,
          estimatedUnitPrice: 2.5,
        ),
        2.5,
      );
    });

    test('multiplies quantity by unit price when both are present', () {
      final repository = MealPlanRepository(_client());

      expect(
        repository.estimatedTotalFromQuantityAndUnitPrice(
          quantity: 3,
          estimatedUnitPrice: 2.5,
        ),
        7.5,
      );
    });

    test('returns null when unit price is missing', () {
      final repository = MealPlanRepository(_client());

      expect(
        repository.estimatedTotalFromQuantityAndUnitPrice(
          quantity: 3,
          estimatedUnitPrice: null,
        ),
        isNull,
      );
    });
  });
}
