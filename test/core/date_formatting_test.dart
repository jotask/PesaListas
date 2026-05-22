import 'package:flutter_test/flutter_test.dart';
import 'package:pesalistas/core/date_formatting.dart';

void main() {
  group('AppDateFormatting.yyyyMmDd', () {
    test('formats DateTime as yyyy-MM-dd', () {
      final date = DateTime(2026, 5, 22, 18, 30, 45);

      expect(AppDateFormatting.yyyyMmDd(date), '2026-05-22');
    });
  });

  group('AppDateFormatting.yyyyMmDdFromValue', () {
    test('returns empty string for null or empty values', () {
      expect(AppDateFormatting.yyyyMmDdFromValue(null), '');
      expect(AppDateFormatting.yyyyMmDdFromValue(''), '');
    });

    test('extracts date part from ISO text', () {
      expect(
        AppDateFormatting.yyyyMmDdFromValue('2026-05-22T18:30:45.000Z'),
        '2026-05-22',
      );
    });

    test('keeps date-only values', () {
      expect(AppDateFormatting.yyyyMmDdFromValue('2026-05-22'), '2026-05-22');
    });
  });
}
