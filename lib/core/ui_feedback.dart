import 'package:flutter/material.dart';

void showSuccessSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

void showErrorSnackBar(BuildContext context, String message, [Object? error]) {
  final fullMessage = error == null ? message : '$message: $error';

  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(fullMessage)));
}
