class AppMoneyFormatting {
  const AppMoneyFormatting._();

  static String format(double value, String currency, {int decimals = 2}) {
    return '${value.toStringAsFixed(decimals)} $currency';
  }
}
