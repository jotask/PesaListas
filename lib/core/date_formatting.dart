class AppDateFormatting {
  const AppDateFormatting._();

  static String yyyyMmDd(DateTime date) {
    return date.toIso8601String().split('T').first;
  }

  static String yyyyMmDdFromValue(dynamic value) {
    if (value == null) return '';

    final text = value.toString();

    if (text.isEmpty) return '';

    return text.split('T').first;
  }
}
