import 'package:pesalistas/core/product_price_fields.dart';
import 'package:pesalistas/core/value_parsing.dart';

class AppProductPriceCalculator {
  const AppProductPriceCalculator._();

  static double? unitPriceFromPriceRow(
    Map<String, dynamic> priceRow, {
    String? targetUnit,
  }) {
    final price = AppValueParsing.doubleOrNull(
      priceRow[AppProductPriceFields.price],
    );

    if (price == null) {
      return null;
    }

    final priceQuantity =
        AppValueParsing.doubleOrNull(
          priceRow[AppProductPriceFields.priceQuantity],
        ) ??
        1;

    if (priceQuantity <= 0) {
      return price;
    }

    final priceUnit = AppValueParsing.textOrNull(
      priceRow[AppProductPriceFields.priceUnit],
    );

    final normalizedPriceUnit = normalizeUnit(priceUnit);
    final normalizedTargetUnit = normalizeUnit(targetUnit);

    if (normalizedPriceUnit == null ||
        normalizedTargetUnit == null ||
        normalizedPriceUnit == normalizedTargetUnit) {
      return price / priceQuantity;
    }

    if (normalizedPriceUnit == 'kg' && normalizedTargetUnit == 'g') {
      return price / (priceQuantity * 1000);
    }

    if (normalizedPriceUnit == 'g' && normalizedTargetUnit == 'kg') {
      return price / (priceQuantity / 1000);
    }

    if (normalizedPriceUnit == 'l' && normalizedTargetUnit == 'ml') {
      return price / (priceQuantity * 1000);
    }

    if (normalizedPriceUnit == 'ml' && normalizedTargetUnit == 'l') {
      return price / (priceQuantity / 1000);
    }

    return price / priceQuantity;
  }

  static String? normalizeUnit(String? value) {
    final unit = AppValueParsing.textOrNull(value)?.toLowerCase();

    if (unit == null) {
      return null;
    }

    if (unit == 'lt' ||
        unit == 'liter' ||
        unit == 'litre' ||
        unit == 'liters' ||
        unit == 'litres') {
      return 'l';
    }

    if (unit == 'kgs' || unit == 'kilogram' || unit == 'kilograms') {
      return 'kg';
    }

    if (unit == 'gram' || unit == 'grams') {
      return 'g';
    }

    return unit;
  }
}
