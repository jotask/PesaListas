import 'package:pesalistas/l10n/app_strings.dart';

class AppItemStatus {
  const AppItemStatus._();

  static const open = 'open';
  static const done = 'done';

  static bool isDone(dynamic value) {
    return value?.toString() == done;
  }

  static String label(dynamic value) {
    return isDone(value) ? S.done : S.open;
  }
}
