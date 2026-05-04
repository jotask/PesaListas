import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/app_strings.dart';

Future<bool> showConfirmDeleteDialog({
  required BuildContext context,
  required String title,
  required String message,
  String? cancelLabel,
  String? deleteLabel,
}) async {
  final resolvedCancelLabel = cancelLabel ?? S.cancel;
  final resolvedDeleteLabel = deleteLabel ?? S.delete;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(resolvedCancelLabel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(resolvedDeleteLabel),
          ),
        ],
      );
    },
  );

  return confirmed == true;
}
