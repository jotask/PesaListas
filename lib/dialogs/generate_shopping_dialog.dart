import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/app_strings.dart';

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
        validationMessage = S.toDateCannotBeBeforeFromDate;
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
      title: Text(S.generateShoppingList),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Icon(Icons.auto_awesome_outlined)),
              title: Text(S.fromMealPlans),
              subtitle: Text(
                S.ingredientsFromRecipeBasedMealPlansInThisDateRangeWillBeAdde,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: pickFromDate,
                    icon: Icon(Icons.calendar_today),
                    label: Text(S.fromDateLabel(formatDate(fromDate))),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: pickToDate,
                    icon: Icon(Icons.event_outlined),
                    label: Text(S.toDateLabel(formatDate(toDate))),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              S.noteGeneratingTheSameRangeMoreThanOnceMayCreateDuplicateShop,
            ),
            if (validationMessage != null) ...[
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.error_outline, size: 18),
                  SizedBox(width: 8),
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
          child: Text(S.cancel),
        ),
        ElevatedButton.icon(
          onPressed: submit,
          icon: Icon(Icons.auto_awesome_outlined),
          label: Text(S.generate),
        ),
      ],
    );
  }
}
