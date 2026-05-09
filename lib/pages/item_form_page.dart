import 'package:flutter/material.dart';
import 'package:pesalistas/core/date_formatting.dart';
import 'package:pesalistas/core/item_fields.dart';
import 'package:pesalistas/core/list_types.dart';
import 'package:pesalistas/core/priority_types.dart';
import 'package:pesalistas/core/recurrence_types.dart';
import 'package:pesalistas/core/value_parsing.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';

class ItemFormPageResult {
  const ItemFormPageResult({
    required this.title,
    this.description,
    this.priority = 0,
    this.deadlineAt,
    this.recurrenceType,
    this.recurrenceInterval,
    this.nextDueAt,
  });

  final String title;
  final String? description;
  final int priority;
  final DateTime? deadlineAt;
  final String? recurrenceType;
  final int? recurrenceInterval;
  final DateTime? nextDueAt;
}

class ItemFormPage extends StatefulWidget {
  const ItemFormPage({super.key, required this.listType, this.item});

  final String listType;
  final Map<String, dynamic>? item;

  @override
  State<ItemFormPage> createState() => _ItemFormPageState();
}

class _ItemFormPageState extends State<ItemFormPage> {
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  late final TextEditingController recurrenceIntervalController;

  int priority = 0;
  DateTime? deadlineAt;

  String? recurrenceType;
  int recurrenceInterval = 2;
  DateTime? nextDueAt;

  String? validationMessage;

  bool get isEditing => widget.item != null;

  AppListTypeConfig get listTypeConfig =>
      AppListTypes.fromValue(widget.listType);

  bool get isTaskList => widget.listType == AppListTypes.tasks.value;

  bool get isChoreList => widget.listType == AppListTypes.chores.value;

  bool get usesCustomInterval {
    return recurrenceType == AppRecurrenceTypes.everyNDays.value;
  }

  bool get hasRecurrence => recurrenceType != null;

  @override
  void initState() {
    super.initState();

    final item = widget.item;

    titleController = TextEditingController(
      text: item?[AppItemFields.title]?.toString() ?? '',
    );

    descriptionController = TextEditingController(
      text: item?[AppItemFields.description]?.toString() ?? '',
    );

    priority = AppValueParsing.intOrNull(item?[AppItemFields.priority]) ?? 0;

    deadlineAt = AppValueParsing.dateTimeOrNull(
      item?[AppItemFields.deadlineAt],
    );

    recurrenceType = item?[AppItemFields.recurrenceType]?.toString();

    recurrenceInterval =
        AppValueParsing.intOrNull(item?[AppItemFields.recurrenceInterval]) ?? 2;

    if (recurrenceInterval < 2) {
      recurrenceInterval = 2;
    }

    nextDueAt = AppValueParsing.dateTimeOrNull(item?[AppItemFields.nextDueAt]);

    recurrenceIntervalController = TextEditingController(
      text: recurrenceInterval.toString(),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    recurrenceIntervalController.dispose();
    super.dispose();
  }

  void clearValidation() {
    if (validationMessage == null) return;

    setState(() => validationMessage = null);
  }

  void submit() {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    setState(() => validationMessage = null);

    if (title.isEmpty) {
      setState(() => validationMessage = context.l10n.titleIsRequired);
      return;
    }

    if (isChoreList && usesCustomInterval && recurrenceInterval < 2) {
      setState(
        () =>
            validationMessage = context.l10n.customRecurrenceMustBeAtLeast2Days,
      );
      return;
    }

    Navigator.of(context).pop(
      ItemFormPageResult(
        title: title,
        description: description.isEmpty ? null : description,
        priority: priority,
        deadlineAt: deadlineAt,
        recurrenceType: recurrenceType,
        recurrenceInterval: usesCustomInterval ? recurrenceInterval : null,
        nextDueAt: nextDueAt,
      ),
    );
  }

  Future<void> pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: isEditing ? DateTime(2020) : DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      initialDate: deadlineAt ?? DateTime.now(),
    );

    if (picked == null) return;

    setState(() => deadlineAt = picked);
  }

  Future<void> pickNextDueDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: isEditing ? DateTime(2020) : DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      initialDate: nextDueAt ?? DateTime.now(),
    );

    if (picked == null) return;

    setState(() => nextDueAt = picked);
  }

  void updateRecurrenceType(String? value) {
    setState(() {
      recurrenceType = value;
      validationMessage = null;

      if (value == null) {
        nextDueAt = null;
      } else {
        nextDueAt ??= DateTime.now();

        if (value == AppRecurrenceTypes.everyNDays.value &&
            recurrenceInterval < 2) {
          recurrenceInterval = 2;
          recurrenceIntervalController.text = '2';
        }
      }
    });
  }

  void updateRecurrenceInterval(String value) {
    setState(() {
      recurrenceInterval = int.tryParse(value) ?? 2;
      validationMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = listTypeConfig;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? context.l10n.editItem
              : context.l10n.addListTypeItem(
                  config.label(context).toLowerCase(),
                ),
        ),
      ),
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
                child: FilledButton(
                  onPressed: submit,
                  child: Text(isEditing ? context.l10n.save : context.l10n.add),
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
                        config.icon,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            config.label(context),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            config.description(context),
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
                    TextField(
                      controller: titleController,
                      autofocus: !isEditing,
                      decoration: InputDecoration(
                        labelText: context.l10n.title,
                        hintText: context.l10n.buyMilkWatchMovieCleanKitchen,
                        prefixIcon: const Icon(Icons.title_outlined),
                      ),
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => clearValidation(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: context.l10n.description,
                        prefixIcon: const Icon(Icons.notes_outlined),
                      ),
                      minLines: 3,
                      maxLines: 6,
                      textInputAction: TextInputAction.newline,
                    ),
                    if (isTaskList) ...[
                      const SizedBox(height: 16),
                      _TaskFieldsSection(
                        priority: priority,
                        deadlineAt: deadlineAt,
                        onPriorityChanged: (value) {
                          setState(() => priority = value);
                        },
                        onPickDeadline: pickDeadline,
                        onRemoveDeadline: () {
                          setState(() => deadlineAt = null);
                        },
                      ),
                    ],
                    if (isChoreList) ...[
                      const SizedBox(height: 16),
                      _ChoreFieldsSection(
                        recurrenceType: recurrenceType,
                        recurrenceIntervalController:
                            recurrenceIntervalController,
                        usesCustomInterval: usesCustomInterval,
                        hasRecurrence: hasRecurrence,
                        nextDueAt: nextDueAt,
                        onRecurrenceTypeChanged: updateRecurrenceType,
                        onRecurrenceIntervalChanged: updateRecurrenceInterval,
                        onPickNextDueDate: pickNextDueDate,
                        onRemoveNextDueDate: () {
                          setState(() => nextDueAt = null);
                        },
                      ),
                    ],
                    if (validationMessage != null) ...[
                      const SizedBox(height: 16),
                      _ValidationMessage(message: validationMessage!),
                    ],
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

class _TaskFieldsSection extends StatelessWidget {
  const _TaskFieldsSection({
    required this.priority,
    required this.deadlineAt,
    required this.onPriorityChanged,
    required this.onPickDeadline,
    required this.onRemoveDeadline,
  });

  final int priority;
  final DateTime? deadlineAt;
  final void Function(int value) onPriorityChanged;
  final VoidCallback onPickDeadline;
  final VoidCallback onRemoveDeadline;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<int>(
          initialValue: priority,
          decoration: InputDecoration(
            labelText: context.l10n.priority,
            prefixIcon: const Icon(Icons.flag_outlined),
          ),
          items: AppPriorityTypes.all.map((config) {
            return DropdownMenuItem<int>(
              value: config.value,
              child: Text(config.label(context)),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) return;

            onPriorityChanged(value);
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPickDeadline,
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  deadlineAt == null
                      ? context.l10n.addDeadline
                      : context.l10n.deadlineDate(
                          AppDateFormatting.yyyyMmDd(deadlineAt!),
                        ),
                ),
              ),
            ),
            if (deadlineAt != null) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: onRemoveDeadline,
                icon: const Icon(Icons.close),
                tooltip: context.l10n.removeDeadline,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _ChoreFieldsSection extends StatelessWidget {
  const _ChoreFieldsSection({
    required this.recurrenceType,
    required this.recurrenceIntervalController,
    required this.usesCustomInterval,
    required this.hasRecurrence,
    required this.nextDueAt,
    required this.onRecurrenceTypeChanged,
    required this.onRecurrenceIntervalChanged,
    required this.onPickNextDueDate,
    required this.onRemoveNextDueDate,
  });

  final String? recurrenceType;
  final TextEditingController recurrenceIntervalController;
  final bool usesCustomInterval;
  final bool hasRecurrence;
  final DateTime? nextDueAt;
  final void Function(String? value) onRecurrenceTypeChanged;
  final void Function(String value) onRecurrenceIntervalChanged;
  final VoidCallback onPickNextDueDate;
  final VoidCallback onRemoveNextDueDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String?>(
          initialValue: recurrenceType,
          decoration: InputDecoration(
            labelText: context.l10n.recurrence,
            helperText: context.l10n.chooseHowOftenThisChoreRepeats,
            prefixIcon: const Icon(Icons.repeat_outlined),
          ),
          items: AppRecurrenceTypes.all.map((config) {
            return DropdownMenuItem<String?>(
              value: config.value,
              child: Text(config.label(context)),
            );
          }).toList(),
          onChanged: onRecurrenceTypeChanged,
        ),
        if (usesCustomInterval) ...[
          const SizedBox(height: 12),
          TextField(
            controller: recurrenceIntervalController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: context.l10n.repeatEvery,
              suffixText: context.l10n.days,
              helperText: context.l10n.minimum2Days,
              prefixIcon: const Icon(Icons.pin_outlined),
            ),
            onChanged: onRecurrenceIntervalChanged,
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: hasRecurrence ? onPickNextDueDate : null,
                icon: const Icon(Icons.event_repeat),
                label: Text(
                  nextDueAt == null
                      ? context.l10n.setNextDueDate
                      : context.l10n.nextDueDate(
                          AppDateFormatting.yyyyMmDd(nextDueAt!),
                        ),
                ),
              ),
            ),
            if (nextDueAt != null) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: onRemoveNextDueDate,
                icon: const Icon(Icons.close),
                tooltip: context.l10n.removeNextDueDate,
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Text(
          hasRecurrence
              ? context
                    .l10n
                    .whenYouCompleteThisChoreTheAppWillScheduleTheNextDueDate
              : context.l10n.nonRecurringChoresCanStillBeCompletedManually,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
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
