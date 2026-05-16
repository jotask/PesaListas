import 'package:pesalistas/core/value_parsing.dart';

class AppDateOnly {
  const AppDateOnly._();

  static DateTime? fromValue(dynamic value) {
    final parsed = AppValueParsing.dateTimeOrNull(value);

    if (parsed == null) {
      return null;
    }

    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  static DateTime today() {
    final now = DateTime.now();

    return DateTime(now.year, now.month, now.day);
  }

  static bool isBeforeToday(DateTime? date) {
    if (date == null) return false;

    return date.isBefore(today());
  }

  static bool isToday(DateTime? date) {
    if (date == null) return false;

    return date == today();
  }

  static bool isAfterToday(DateTime? date) {
    if (date == null) return false;

    return date.isAfter(today());
  }
}
