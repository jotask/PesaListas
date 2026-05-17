import 'package:pesalistas/core/app_config.dart';
import 'package:pesalistas/core/estimated_cost_calculator.dart';
import 'package:pesalistas/core/shopping_item_fields.dart';
import 'package:pesalistas/core/value_parsing.dart';

class AppShoppingItemCost {
  const AppShoppingItemCost._();

  static String priceCurrency(Map<String, dynamic> item) {
    return AppValueParsing.textOrNull(
          item[AppShoppingItemFields.priceCurrency],
        ) ??
        AppConfig.defaultCurrency;
  }

  static double? estimatedUnitPrice(Map<String, dynamic> item) {
    return AppValueParsing.doubleOrNull(
      item[AppShoppingItemFields.estimatedUnitPrice],
    );
  }

  static double? estimatedTotal(Map<String, dynamic> item) {
    final explicitTotal = AppValueParsing.doubleOrNull(
      item[AppShoppingItemFields.estimatedTotalPrice],
    );

    if (explicitTotal != null) {
      return explicitTotal;
    }

    return AppEstimatedCostCalculator.estimatedTotal(
      quantity: AppValueParsing.doubleOrNull(
        item[AppShoppingItemFields.quantity],
      ),
      unitPrice: estimatedUnitPrice(item),
    );
  }
}
