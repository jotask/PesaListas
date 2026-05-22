import 'package:flutter_test/flutter_test.dart';
import 'package:pesalistas/core/meal_types.dart';

void main() {
  group('AppMealTypes.fromValue', () {
    test('returns configured meal types by value', () {
      for (final config in AppMealTypes.all) {
        expect(AppMealTypes.fromValue(config.value), config);
      }
    });

    test('falls back to dinner for null or unknown values', () {
      expect(AppMealTypes.fromValue(null).value, AppMealTypes.dinner);
      expect(AppMealTypes.fromValue('unknown').value, AppMealTypes.dinner);
    });
  });

  group('AppMealTypes.all', () {
    test('contains unique values', () {
      final values = AppMealTypes.all.map((config) => config.value).toList();

      expect(values.toSet().length, values.length);
    });
  });
}
