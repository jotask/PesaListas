import 'package:flutter_test/flutter_test.dart';
import 'package:pesalistas/core/recurrence_types.dart';

void main() {
  group('AppRecurrenceTypes.fromValue', () {
    test('returns configured recurrence by value', () {
      for (final config in AppRecurrenceTypes.all) {
        expect(AppRecurrenceTypes.fromValue(config.value), config);
      }
    });

    test('falls back to none for unknown values', () {
      expect(AppRecurrenceTypes.fromValue('unknown'), AppRecurrenceTypes.none);
    });
  });

  group('AppRecurrenceTypes.all', () {
    test('contains expected recurrence values', () {
      expect(AppRecurrenceTypes.all.map((config) => config.value).toList(), [
        null,
        'daily',
        'weekly',
        'monthly',
        'every_n_days',
      ]);
    });
  });
}
