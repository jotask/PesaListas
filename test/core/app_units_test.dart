import 'package:flutter_test/flutter_test.dart';
import 'package:pesalistas/core/app_units.dart';

void main() {
  group('AppUnitType.normalize', () {
    test('normalizes common unit aliases', () {
      expect(AppUnitType.normalize('pieces'), 'pcs');
      expect(AppUnitType.normalize('pc'), 'pcs');
      expect(AppUnitType.normalize('grams'), 'g');
      expect(AppUnitType.normalize('kilos'), 'kg');
      expect(AppUnitType.normalize('litres'), 'l');
      expect(AppUnitType.normalize('packet'), 'pack');
    });

    test('returns null for blank units', () {
      expect(AppUnitType.normalize(null), null);
      expect(AppUnitType.normalize(''), null);
      expect(AppUnitType.normalize('   '), null);
    });

    test('keeps unknown non-empty units normalized to lowercase', () {
      expect(AppUnitType.normalize('Cup'), 'cup');
    });
  });

  group('AppUnitType.fromValue', () {
    test('returns matching enum for known units', () {
      expect(AppUnitType.fromValue('kg'), AppUnitType.kilogram);
      expect(AppUnitType.fromValue('grams'), AppUnitType.gram);
    });

    test('returns null for unknown units', () {
      expect(AppUnitType.fromValue('cup'), null);
    });
  });

  group('AppUnitType labels', () {
    test('returns display labels', () {
      expect(AppUnitType.labelForValue('kg'), 'Kilograms');
      expect(AppUnitType.displayLabel('kg'), 'Kilograms (kg)');
      expect(AppUnitType.displayLabel('kg', includeValue: false), 'Kilograms');
      expect(AppUnitType.shortLabel('kilograms'), 'kg');
    });
  });

  group('AppUnitType.quantityText', () {
    test('formats integer and decimal quantities', () {
      expect(AppUnitType.quantityText(quantity: 2, unit: 'kg'), '2 kg');
      expect(AppUnitType.quantityText(quantity: 2.5, unit: 'kg'), '2.5 kg');
    });

    test('handles missing quantity or unit', () {
      expect(AppUnitType.quantityText(quantity: null, unit: 'kg'), 'kg');
      expect(AppUnitType.quantityText(quantity: 2, unit: null), '2');
    });
  });
}
