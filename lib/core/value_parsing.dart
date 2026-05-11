class AppValueParsing {
  const AppValueParsing._();

  static int? intOrNull(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    if (value is num && value % 1 == 0) {
      return value.toInt();
    }

    return int.tryParse(value.toString().trim());
  }

  static DateTime? dateTimeOrNull(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;

    return DateTime.tryParse(value.toString());
  }

  static String? textOrNull(dynamic value) {
    final text = value?.toString().trim();

    if (text == null || text.isEmpty) {
      return null;
    }

    return text;
  }

  static double? doubleOrNull(dynamic value) {
    if (value == null) return null;

    if (value is num) return value.toDouble();

    return double.tryParse(value.toString().trim().replaceAll(',', '.'));
  }
}
