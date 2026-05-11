import 'package:flutter_test/flutter_test.dart';
import 'package:pesalistas/core/app_config.dart';
import 'package:pesalistas/core/app_cost_calculator.dart';
import 'package:pesalistas/core/recipe_ingredient_fields.dart';
import 'package:pesalistas/core/shopping_item_fields.dart';

void main() {
  group('AppCostCalculator.estimatedTotal', () {
    test('uses explicit total when present', () {
      final result = AppCostCalculator.estimatedTotal(
        explicitTotal: 9.99,
        unitPrice: 2.0,
        quantity: 3,
      );

      expect(result, 9.99);
    });

    test('calculates unit price times quantity', () {
      final result = AppCostCalculator.estimatedTotal(
        explicitTotal: null,
        unitPrice: 2.5,
        quantity: 4,
      );

      expect(result, 10.0);
    });

    test('uses unit price when quantity is missing', () {
      final result = AppCostCalculator.estimatedTotal(
        explicitTotal: null,
        unitPrice: 2.5,
        quantity: null,
      );

      expect(result, 2.5);
    });

    test('returns null when price is missing', () {
      final result = AppCostCalculator.estimatedTotal(
        explicitTotal: null,
        unitPrice: null,
        quantity: 3,
      );

      expect(result, null);
    });

    test('supports comma decimals', () {
      final result = AppCostCalculator.estimatedTotal(
        explicitTotal: null,
        unitPrice: '2,50',
        quantity: '4',
      );

      expect(result, 10.0);
    });
  });

  group('AppCostCalculator.recipeIngredientEstimatedTotal', () {
    test('calculates recipe ingredient total', () {
      final result = AppCostCalculator.recipeIngredientEstimatedTotal({
        AppRecipeIngredientFields.estimatedUnitPrice: 0.0023,
        AppRecipeIngredientFields.quantity: 500,
      });

      expect(result, closeTo(1.15, 0.000001));
    });

    test('uses recipe ingredient explicit total first', () {
      final result = AppCostCalculator.recipeIngredientEstimatedTotal({
        AppRecipeIngredientFields.estimatedTotalPrice: 3.25,
        AppRecipeIngredientFields.estimatedUnitPrice: 0.0023,
        AppRecipeIngredientFields.quantity: 500,
      });

      expect(result, 3.25);
    });

    test('uses default recipe ingredient currency when missing', () {
      final result = AppCostCalculator.recipeIngredientCurrency({});

      expect(result, AppConfig.defaultCurrency);
    });

    test('uses recipe ingredient currency when present', () {
      final result = AppCostCalculator.recipeIngredientCurrency({
        AppRecipeIngredientFields.priceCurrency: 'USD',
      });

      expect(result, 'USD');
    });
  });

  group('AppCostCalculator.shoppingItemEstimatedTotal', () {
    test('calculates shopping item total', () {
      final result = AppCostCalculator.shoppingItemEstimatedTotal({
        AppShoppingItemFields.estimatedUnitPrice: 1.5,
        AppShoppingItemFields.quantity: 2,
      });

      expect(result, 3.0);
    });

    test('uses shopping item explicit total first', () {
      final result = AppCostCalculator.shoppingItemEstimatedTotal({
        AppShoppingItemFields.estimatedTotalPrice: 4.75,
        AppShoppingItemFields.estimatedUnitPrice: 1.5,
        AppShoppingItemFields.quantity: 2,
      });

      expect(result, 4.75);
    });

    test('uses default shopping item currency when missing', () {
      final result = AppCostCalculator.shoppingItemCurrency({});

      expect(result, AppConfig.defaultCurrency);
    });

    test('uses shopping item currency when present', () {
      final result = AppCostCalculator.shoppingItemCurrency({
        AppShoppingItemFields.priceCurrency: 'GBP',
      });

      expect(result, 'GBP');
    });
  });
}
