import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';

class GenerateShoppingPageResult {
  const GenerateShoppingPageResult({
    required this.fromDate,
    required this.toDate,
  });

  final DateTime fromDate;
  final DateTime toDate;
}

class GenerateShoppingPage extends StatefulWidget {
  const GenerateShoppingPage({super.key});

  @override
  State<GenerateShoppingPage> createState() => _GenerateShoppingPageState();
}

class _GenerateShoppingPageState extends State<GenerateShoppingPage> {
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
      fromDate = DateTime(picked.year, picked.month, picked.day);

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
      toDate = DateTime(picked.year, picked.month, picked.day);
      validationMessage = null;
    });
  }

  void submit() {
    setState(() => validationMessage = null);

    if (toDate.isBefore(fromDate)) {
      setState(() {
        validationMessage = context.l10n.toDateCannotBeBeforeFromDate;
      });
      return;
    }

    Navigator.of(
      context,
    ).pop(GenerateShoppingPageResult(fromDate: fromDate, toDate: toDate));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.generateShoppingList)),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(context.l10n.cancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: submit,
                  icon: const Icon(Icons.auto_awesome_outlined),
                  label: Text(context.l10n.generate),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.auto_awesome_outlined,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.fromMealPlans,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context
                                .l10n
                                .ingredientsFromRecipeBasedMealPlansInThisDateRangeWillBeAdde,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: Text(
                        context.l10n.fromDateLabel(formatDate(fromDate)),
                      ),
                      subtitle: Text(formatDate(fromDate)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: pickFromDate,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.event_outlined),
                      title: Text(context.l10n.toDateLabel(formatDate(toDate))),
                      subtitle: Text(formatDate(toDate)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: pickToDate,
                    ),
                    if (validationMessage != null) ...[
                      const SizedBox(height: 16),
                      _ValidationMessage(message: validationMessage!),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        context
                            .l10n
                            .noteGeneratingTheSameRangeMoreThanOnceMayCreateDuplicateShop,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 96),
          ],
        ),
      ),
    );
  }
}

class _ValidationMessage extends StatelessWidget {
  const _ValidationMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: theme.colorScheme.onErrorContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
