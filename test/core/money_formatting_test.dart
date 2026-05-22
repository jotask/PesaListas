import 'package:flutter_test/flutter_test.dart';
import 'package:pesalistas/core/money_formatting.dart';

void main() {
  group('AppMoneyFormatting.format', () {
    test('formats with two decimals by default', () {
      expect(AppMoneyFormatting.format(2, 'EUR'), '2.00 EUR');
      expect(AppMoneyFormatting.format(2.345, 'EUR'), '2.35 EUR');
    });

    test('supports custom decimal count', () {
      expect(AppMoneyFormatting.format(2.345, 'EUR', decimals: 1), '2.3 EUR');
      expect(AppMoneyFormatting.format(2.345, 'EUR', decimals: 0), '2 EUR');
    });
  });
}
