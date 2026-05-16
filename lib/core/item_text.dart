import 'package:flutter/widgets.dart';
import 'package:pesalistas/core/fields/item_fields.dart';

class AppItemText {
  const AppItemText._();

  static String? textOrNull(dynamic value) {
    final text = value?.toString().trim();

    if (text == null || text.isEmpty) {
      return null;
    }

    return text;
  }

  static String title(Map<String, dynamic> item, {required String fallback}) {
    return textOrNull(item[AppItemFields.title]) ?? fallback;
  }

  static String? description(Map<String, dynamic> item) {
    return textOrNull(item[AppItemFields.description]);
  }

  static String titleFromContext(
    BuildContext context,
    Map<String, dynamic> item, {
    required String fallback,
  }) {
    return title(item, fallback: fallback);
  }
}
