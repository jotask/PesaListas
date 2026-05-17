import 'package:flutter/widgets.dart';
import 'package:pesalistas/core/fields/item_fields.dart';
import 'package:pesalistas/core/value_parsing.dart';

class AppItemText {
  const AppItemText._();

  static String title(Map<String, dynamic> item, {required String fallback}) {
    return AppValueParsing.textOrNull(item[AppItemFields.title]) ?? fallback;
  }

  static String? description(Map<String, dynamic> item) {
    return AppValueParsing.textOrNull(item[AppItemFields.description]);
  }

  static String titleFromContext(
    BuildContext context,
    Map<String, dynamic> item, {
    required String fallback,
  }) {
    return title(item, fallback: fallback);
  }
}
