class AppValueParsing {
  const AppValueParsing._();

  static int? intOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;

    return int.tryParse(value.toString());
  }

  static DateTime? dateTimeOrNull(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;

    return DateTime.tryParse(value.toString());
  }
}
