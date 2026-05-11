import 'package:flutter_test/flutter_test.dart';
import 'package:pesalistas/core/value_parsing.dart';

void main() {
  group('AppValueParsing.textOrNull', () {
    test('returns trimmed text', () {
      expect(AppValueParsing.textOrNull(' Tomatoes '), 'Tomatoes');
      expect(AppValueParsing.textOrNull(123), '123');
    });

    test('returns null for empty values', () {
      expect(AppValueParsing.textOrNull(null), null);
      expect(AppValueParsing.textOrNull(''), null);
      expect(AppValueParsing.textOrNull('   '), null);
    });
  });

  group('AppValueParsing.doubleOrNull', () {
    test('parses numbers', () {
      expect(AppValueParsing.doubleOrNull(2), 2.0);
      expect(AppValueParsing.doubleOrNull(2.5), 2.5);
      expect(AppValueParsing.doubleOrNull('2.5'), 2.5);
      expect(AppValueParsing.doubleOrNull('2,5'), 2.5);
      expect(AppValueParsing.doubleOrNull(' 2,5 '), 2.5);
    });

    test('returns null for invalid numbers', () {
      expect(AppValueParsing.doubleOrNull(null), null);
      expect(AppValueParsing.doubleOrNull(''), null);
      expect(AppValueParsing.doubleOrNull('abc'), null);
    });
  });

  group('AppValueParsing.intOrNull', () {
    test('parses whole integers', () {
      expect(AppValueParsing.intOrNull(5), 5);
      expect(AppValueParsing.intOrNull(5.0), 5);
      expect(AppValueParsing.intOrNull('5'), 5);
      expect(AppValueParsing.intOrNull(' 5 '), 5);
    });

    test('returns null for invalid integers', () {
      expect(AppValueParsing.intOrNull(null), null);
      expect(AppValueParsing.intOrNull(''), null);
      expect(AppValueParsing.intOrNull('abc'), null);
      expect(AppValueParsing.intOrNull('5.5'), null);
      expect(AppValueParsing.intOrNull(5.5), null);
    });
  });
}
