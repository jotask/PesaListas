import 'package:flutter_test/flutter_test.dart';
import 'package:pesalistas/core/estimated_cost_calculator.dart';

void main() {
  group('AppEstimatedCostCalculator.estimatedTotal', () {
    test('returns null when unit price is missing', () {
      expect(
        AppEstimatedCostCalculator.estimatedTotal(quantity: 2, unitPrice: null),
        null,
      );
    });

    test('returns unit price when quantity is missing', () {
      expect(
        AppEstimatedCostCalculator.estimatedTotal(
          quantity: null,
          unitPrice: 3.5,
        ),
        3.5,
      );
    });

    test('multiplies quantity by unit price', () {
      expect(
        AppEstimatedCostCalculator.estimatedTotal(quantity: 4, unitPrice: 2.5),
        10.0,
      );
    });
  });
}
