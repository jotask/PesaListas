import 'package:flutter_test/flutter_test.dart';
import 'package:pesalistas/core/price_unit_converter.dart';
import 'package:pesalistas/core/product_price_fields.dart';

void main() {
  group('AppPriceUnitConverter.unitPriceFromPriceRow', () {
    test('converts price per 1000g to price per g', () {
      final result = AppPriceUnitConverter.unitPriceFromPriceRow({
        AppProductPriceFields.price: 2.30,
        AppProductPriceFields.priceQuantity: 1000,
        AppProductPriceFields.priceUnit: 'g',
      }, targetUnit: 'g');

      expect(result, closeTo(0.0023, 0.0000001));
    });

    test('converts price per kg to price per g', () {
      final result = AppPriceUnitConverter.unitPriceFromPriceRow({
        AppProductPriceFields.price: 2.30,
        AppProductPriceFields.priceQuantity: 1,
        AppProductPriceFields.priceUnit: 'kg',
      }, targetUnit: 'g');

      expect(result, closeTo(0.0023, 0.0000001));
    });

    test('converts price per liter to price per ml', () {
      final result = AppPriceUnitConverter.unitPriceFromPriceRow({
        AppProductPriceFields.price: 1.50,
        AppProductPriceFields.priceQuantity: 1,
        AppProductPriceFields.priceUnit: 'l',
      }, targetUnit: 'ml');

      expect(result, closeTo(0.0015, 0.0000001));
    });

    test('keeps pcs as direct unit price', () {
      final result = AppPriceUnitConverter.unitPriceFromPriceRow({
        AppProductPriceFields.price: 0.25,
        AppProductPriceFields.priceQuantity: 1,
        AppProductPriceFields.priceUnit: 'pcs',
      }, targetUnit: 'pcs');

      expect(result, 0.25);
    });

    test('supports comma decimal input', () {
      final result = AppPriceUnitConverter.unitPriceFromPriceRow({
        AppProductPriceFields.price: '2,30',
        AppProductPriceFields.priceQuantity: '1000',
        AppProductPriceFields.priceUnit: 'g',
      }, targetUnit: 'g');

      expect(result, closeTo(0.0023, 0.0000001));
    });

    test('returns null when price is missing', () {
      final result = AppPriceUnitConverter.unitPriceFromPriceRow({
        AppProductPriceFields.priceQuantity: 1000,
        AppProductPriceFields.priceUnit: 'g',
      }, targetUnit: 'g');

      expect(result, null);
    });
  });
}
