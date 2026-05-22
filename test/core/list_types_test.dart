import 'package:flutter_test/flutter_test.dart';
import 'package:pesalistas/core/list_types.dart';

void main() {
  group('AppListTypes.fromValue', () {
    test('returns generic for null or unknown values', () {
      expect(AppListTypes.fromValue(null), AppListTypes.generic);
      expect(AppListTypes.fromValue('unknown'), AppListTypes.generic);
    });

    test('returns each configured list type by value', () {
      for (final config in AppListTypes.all) {
        expect(AppListTypes.fromValue(config.value), config);
      }
    });
  });

  group('AppListTypes.all', () {
    test('contains unique values', () {
      final values = AppListTypes.all.map((config) => config.value).toList();

      expect(values.toSet().length, values.length);
    });

    test('includes books and meal planning types', () {
      expect(AppListTypes.all, contains(AppListTypes.books));
      expect(AppListTypes.all, contains(AppListTypes.mealPlan));
    });
  });
}
