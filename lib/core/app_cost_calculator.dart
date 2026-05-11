import 'package:pesalistas/core/app_config.dart';
import 'package:pesalistas/core/recipe_ingredient_fields.dart';
import 'package:pesalistas/core/shopping_item_fields.dart';
import 'package:pesalistas/core/value_parsing.dart';

class AppCostCalculator {
  const AppCostCalculator._();

  static double? estimatedTotal({
    required dynamic explicitTotal,
    required dynamic unitPrice,
    required dynamic quantity,
  }) {
    final parsedExplicitTotal = AppValueParsing.doubleOrNull(explicitTotal);

    if (parsedExplicitTotal != null) {
      return parsedExplicitTotal;
    }

    final parsedUnitPrice = AppValueParsing.doubleOrNull(unitPrice);

    if (parsedUnitPrice == null) {
      return null;
    }

    final parsedQuantity = AppValueParsing.doubleOrNull(quantity);

    if (parsedQuantity == null) {
      return parsedUnitPrice;
    }

    return parsedUnitPrice * parsedQuantity;
  }

  static double? recipeIngredientEstimatedTotal(
    Map<String, dynamic> ingredient,
  ) {
    return estimatedTotal(
      explicitTotal: ingredient[AppRecipeIngredientFields.estimatedTotalPrice],
      unitPrice: ingredient[AppRecipeIngredientFields.estimatedUnitPrice],
      quantity: ingredient[AppRecipeIngredientFields.quantity],
    );
  }

  static String recipeIngredientCurrency(Map<String, dynamic> ingredient) {
    return AppValueParsing.textOrNull(
          ingredient[AppRecipeIngredientFields.priceCurrency],
        ) ??
        AppConfig.defaultCurrency;
  }

  static double? shoppingItemEstimatedTotal(Map<String, dynamic> item) {
    return estimatedTotal(
      explicitTotal: item[AppShoppingItemFields.estimatedTotalPrice],
      unitPrice: item[AppShoppingItemFields.estimatedUnitPrice],
      quantity: item[AppShoppingItemFields.quantity],
    );
  }

  static String shoppingItemCurrency(Map<String, dynamic> item) {
    return AppValueParsing.textOrNull(
          item[AppShoppingItemFields.priceCurrency],
        ) ??
        AppConfig.defaultCurrency;
  }
}
