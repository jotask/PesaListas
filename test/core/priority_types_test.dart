import 'package:flutter_test/flutter_test.dart';
import 'package:pesalistas/core/priority_types.dart';

void main() {
  group('AppPriorityTypes.fromValue', () {
    test('returns configured priority by value', () {
      for (final config in AppPriorityTypes.all) {
        expect(AppPriorityTypes.fromValue(config.value), config);
      }
    });

    test('falls back to none for null or unknown values', () {
      expect(AppPriorityTypes.fromValue(null), AppPriorityTypes.none);
      expect(AppPriorityTypes.fromValue(999), AppPriorityTypes.none);
    });
  });

  group('AppPriorityTypes.all', () {
    test('contains values in ascending priority order', () {
      expect(AppPriorityTypes.all.map((config) => config.value).toList(), [
        0,
        1,
        2,
        3,
      ]);
    });
  });
}
