import 'package:flutter_test/flutter_test.dart';
import 'package:pesalistas/core/app_config.dart';
import 'package:pesalistas/core/fields/shopping_item_fields.dart';
import 'package:pesalistas/core/shopping_item_cost.dart';

void main() {
  group('AppShoppingItemCost.priceCurrency', () {
    test('returns item currency when present', () {
      expect(
        AppShoppingItemCost.priceCurrency({AppShoppingItemFields.priceCurrency: 'USD'}),
        'USD',
      );
    });

    test('falls back to default currency', () {
      expect(AppShoppingItemCost.priceCurrency({}), AppConfig.defaultCurrency);
    });
  });

  group('AppShoppingItemCost.estimatedUnitPrice', () {
    test('parses unit price', () {
      expect(
        AppShoppingItemCost.estimatedUnitPrice({
          AppShoppingItemFields.estimatedUnitPrice: '2,50',
        }),
        2.5,
      );
    });
  });

  group('AppShoppingItemCost.estimatedTotal', () {
    test('uses explicit total when present', () {
      expect(
        AppShoppingItemCost.estimatedTotal({
          AppShoppingItemFields.estimatedTotalPrice: '9.99',
          AppShoppingItemFields.quantity: 4,
          AppShoppingItemFields.estimatedUnitPrice: 2,
        }),
        9.99,
      );
    });

    test('calculates total from quantity and unit price', () {
      expect(
        AppShoppingItemCost.estimatedTotal({
          AppShoppingItemFields.quantity: '4',
          AppShoppingItemFields.estimatedUnitPrice: '2.5',
        }),
        10.0,
      );
    });

    test('returns null when no price is available', () {
      expect(AppShoppingItemCost.estimatedTotal({}), null);
    });
  });
}
