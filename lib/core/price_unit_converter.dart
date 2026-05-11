import 'package:pesalistas/core/product_price_fields.dart';
import 'package:pesalistas/core/value_parsing.dart';

class AppPriceUnitConverter {
  const AppPriceUnitConverter._();

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

    final normalizedPriceUnit = priceUnit?.toLowerCase();
    final normalizedTargetUnit = targetUnit?.toLowerCase();

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

    if ((normalizedPriceUnit == 'l' || normalizedPriceUnit == 'lt') &&
        normalizedTargetUnit == 'ml') {
      return price / (priceQuantity * 1000);
    }

    if (normalizedPriceUnit == 'ml' &&
        (normalizedTargetUnit == 'l' || normalizedTargetUnit == 'lt')) {
      return price / (priceQuantity / 1000);
    }

    return price / priceQuantity;
  }
}
