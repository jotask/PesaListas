class AppEstimatedCostCalculator {
  const AppEstimatedCostCalculator._();

  static double? estimatedTotal({
    required double? quantity,
    required double? unitPrice,
  }) {
    if (unitPrice == null) {
      return null;
    }

    if (quantity == null) {
      return unitPrice;
    }

    return quantity * unitPrice;
  }
}
