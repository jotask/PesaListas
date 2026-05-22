import 'package:flutter_test/flutter_test.dart';
import 'package:pesalistas/core/date_only.dart';

void main() {
  group('AppDateOnly.fromValue', () {
    test('returns null for invalid input', () {
      expect(AppDateOnly.fromValue(null), null);
      expect(AppDateOnly.fromValue('not-a-date'), null);
    });

    test('strips time from DateTime values', () {
      final result = AppDateOnly.fromValue(DateTime(2026, 5, 22, 18, 30));

      expect(result, DateTime(2026, 5, 22));
    });

    test('strips time from ISO strings', () {
      final result = AppDateOnly.fromValue('2026-05-22T18:30:45.000Z');

      expect(result, DateTime(2026, 5, 22));
    });
  });

  group('AppDateOnly day comparison helpers', () {
    test('classifies yesterday, today, and tomorrow', () {
      final today = AppDateOnly.today();
      final yesterday = today.subtract(const Duration(days: 1));
      final tomorrow = today.add(const Duration(days: 1));

      expect(AppDateOnly.isBeforeToday(yesterday), true);
      expect(AppDateOnly.isToday(today), true);
      expect(AppDateOnly.isAfterToday(tomorrow), true);

      expect(AppDateOnly.isBeforeToday(null), false);
      expect(AppDateOnly.isToday(null), false);
      expect(AppDateOnly.isAfterToday(null), false);
    });
  });
}
