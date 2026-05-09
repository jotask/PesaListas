import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/widgets/common/form_page_layout.dart';

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
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.generateShoppingList)),
      bottomNavigationBar: AppFormBottomActions(
        cancelLabel: context.l10n.cancel,
        primaryLabel: context.l10n.generate,
        primaryIcon: Icons.auto_awesome_outlined,
        onCancel: () => Navigator.of(context).pop(),
        onPrimary: submit,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppFormPageHeaderCard(
              icon: Icons.auto_awesome_outlined,
              title: context.l10n.fromMealPlans,
              subtitle: context
                  .l10n
                  .ingredientsFromRecipeBasedMealPlansInThisDateRangeWillBeAdde,
            ),
            const SizedBox(height: 16),
            AppFormSectionCard(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text(context.l10n.fromDateLabel(formatDate(fromDate))),
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
                  AppFormValidationMessage(message: validationMessage!),
                ],
              ],
            ),
            const SizedBox(height: 16),
            AppFormInfoCard(
              icon: Icons.info_outline,
              message: context
                  .l10n
                  .noteGeneratingTheSameRangeMoreThanOnceMayCreateDuplicateShop,
            ),
            const SizedBox(height: 96),
          ],
        ),
      ),
    );
  }
}
