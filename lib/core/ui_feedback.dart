import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void showSuccessSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

void showInfoSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

void showErrorSnackBar(BuildContext context, String message, [Object? error]) {
  final fullMessage = error == null ? message : '$message: $error';

  debugPrint('================ APP ERROR ================', wrapWidth: 1024);

  debugPrint(fullMessage, wrapWidth: 1024);

  if (error != null) {
    debugPrint('Error type: ${error.runtimeType}', wrapWidth: 1024);
  }

  debugPrint('===========================================', wrapWidth: 1024);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Theme.of(context).colorScheme.error,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
