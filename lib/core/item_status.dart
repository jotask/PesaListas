import 'package:flutter/widgets.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';

class AppItemStatus {
  const AppItemStatus._();

  static const open = 'open';
  static const done = 'done';

  static bool isDone(dynamic value) {
    return value?.toString() == done;
  }

  static String label(BuildContext context, dynamic value) {
    return isDone(value) ? context.l10n.done : context.l10n.open;
  }
}
