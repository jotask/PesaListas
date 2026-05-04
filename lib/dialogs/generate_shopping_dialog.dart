import 'package:flutter/material.dart';

class GenerateShoppingDialogResult {
  const GenerateShoppingDialogResult({
    required this.fromDate,
    required this.toDate,
  });

  final DateTime fromDate;
  final DateTime toDate;
}

class GenerateShoppingDialog extends StatefulWidget {
  const GenerateShoppingDialog({super.key});

  @override
  State<GenerateShoppingDialog> createState() => _GenerateShoppingDialogState();
}

class _GenerateShoppingDialogState extends State<GenerateShoppingDialog> {
  late DateTime fromDate;
  late DateTime toDate;

  String? validationMessage;

  @override
  void initState() {
    super.initState();

    final today = DateTime.now();

    fromDate = DateTime(today.year, today.month, today.day);
    toDate = fromDate.add(const Duration(days: 6));
  }

  String formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  Future<void> pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fromDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );

    if (picked == null) return;

    setState(() {
      fromDate = picked;

      if (toDate.isBefore(fromDate)) {
        toDate = fromDate;
      }

      validationMessage = null;
    });
  }

  Future<void> pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: toDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );

    if (picked == null) return;

    setState(() {
      toDate = picked;
      validationMessage = null;
    });
  }

  void submit() {
    setState(() => validationMessage = null);

    if (toDate.isBefore(fromDate)) {
      setState(() {
        validationMessage = 'To date cannot be before from date.';
      });
      return;
    }

    Navigator.of(
      context,
    ).pop(GenerateShoppingDialogResult(fromDate: fromDate, toDate: toDate));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Generate shopping list'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Icon(Icons.auto_awesome_outlined)),
              title: Text('From meal plans'),
              subtitle: Text(
                'Ingredients from recipe-based meal plans in this date range will be added to shopping.',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: pickFromDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text('From ${formatDate(fromDate)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: pickToDate,
                    icon: const Icon(Icons.event_outlined),
                    label: Text('To ${formatDate(toDate)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Note: generating the same range more than once may create duplicate shopping items.',
            ),
            if (validationMessage != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.error_outline, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      validationMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: submit,
          icon: const Icon(Icons.auto_awesome_outlined),
          label: const Text('Generate'),
        ),
      ],
    );
  }
}
