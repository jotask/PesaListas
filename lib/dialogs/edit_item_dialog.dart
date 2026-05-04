import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/app_strings.dart';
import 'package:pesalistas/core/date_formatting.dart';
import 'package:pesalistas/core/item_fields.dart';
import 'package:pesalistas/core/list_types.dart';
import 'package:pesalistas/core/priority_types.dart';
import 'package:pesalistas/core/recurrence_types.dart';
import 'package:pesalistas/core/value_parsing.dart';

class EditItemDialogResult {
  const EditItemDialogResult({
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

class EditItemDialog extends StatefulWidget {
  const EditItemDialog({super.key, required this.item, required this.listType});

  final Map<String, dynamic> item;
  final String listType;

  @override
  State<EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<EditItemDialog> {
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  late final TextEditingController recurrenceIntervalController;

  int priority = 0;
  DateTime? deadlineAt;

  String? recurrenceType;
  int recurrenceInterval = 2;
  DateTime? nextDueAt;

  String? validationMessage;

  bool get isTaskList => widget.listType == AppListTypes.tasks.value;

  bool get isChoreList => widget.listType == AppListTypes.chores.value;

  bool get usesCustomInterval =>
      recurrenceType == AppRecurrenceTypes.everyNDays.value;

  bool get hasRecurrence => recurrenceType != null;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(
      text: widget.item[AppItemFields.title]?.toString() ?? '',
    );

    descriptionController = TextEditingController(
      text: widget.item[AppItemFields.description]?.toString() ?? '',
    );

    priority =
        AppValueParsing.intOrNull(widget.item[AppItemFields.priority]) ?? 0;

    deadlineAt = AppValueParsing.dateTimeOrNull(
      widget.item[AppItemFields.deadlineAt],
    );

    recurrenceType = widget.item[AppItemFields.recurrenceType]?.toString();

    recurrenceInterval =
        AppValueParsing.intOrNull(
          widget.item[AppItemFields.recurrenceInterval],
        ) ??
        2;

    if (recurrenceInterval < 2) {
      recurrenceInterval = 2;
    }

    nextDueAt = AppValueParsing.dateTimeOrNull(
      widget.item[AppItemFields.nextDueAt],
    );

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

  void submit() {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    setState(() => validationMessage = null);

    if (title.isEmpty) {
      setState(() => validationMessage = S.titleIsRequired);
      return;
    }

    if (isChoreList && usesCustomInterval && recurrenceInterval < 2) {
      setState(() => validationMessage = S.customRecurrenceMustBeAtLeast2Days);
      return;
    }

    Navigator.of(context).pop(
      EditItemDialogResult(
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
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      initialDate: deadlineAt ?? DateTime.now(),
    );

    if (picked == null) return;

    setState(() => deadlineAt = picked);
  }

  Future<void> pickNextDueDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
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

  Widget buildValidationMessage() {
    final message = validationMessage;

    if (message == null) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTaskFields() {
    return Column(
      children: [
        SizedBox(height: 16),
        DropdownButtonFormField<int>(
          initialValue: priority,
          decoration: InputDecoration(labelText: S.priority),
          items: AppPriorityTypes.all.map((config) {
            return DropdownMenuItem<int>(
              value: config.value,
              child: Text(config.label),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => priority = value);
          },
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: pickDeadline,
                icon: Icon(Icons.calendar_today),
                label: Text(
                  deadlineAt == null
                      ? S.addDeadline
                      : 'Deadline: ${AppDateFormatting.yyyyMmDd(deadlineAt!)}',
                ),
              ),
            ),
            if (deadlineAt != null) ...[
              SizedBox(width: 8),
              IconButton(
                onPressed: () => setState(() => deadlineAt = null),
                icon: Icon(Icons.close),
                tooltip: S.removeDeadline,
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget buildChoreFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        DropdownButtonFormField<String?>(
          initialValue: recurrenceType,
          decoration: InputDecoration(
            labelText: S.recurrence,
            helperText: S.chooseHowOftenThisChoreRepeats,
          ),
          items: AppRecurrenceTypes.all.map((config) {
            return DropdownMenuItem<String?>(
              value: config.value,
              child: Text(config.label),
            );
          }).toList(),
          onChanged: updateRecurrenceType,
        ),
        if (usesCustomInterval) ...[
          SizedBox(height: 12),
          TextField(
            controller: recurrenceIntervalController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: S.repeatEvery,
              suffixText: 'days',
              helperText: S.minimum2Days,
            ),
            onChanged: updateRecurrenceInterval,
          ),
        ],
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: hasRecurrence ? pickNextDueDate : null,
                icon: Icon(Icons.event_repeat),
                label: Text(
                  nextDueAt == null
                      ? S.setNextDueDate
                      : 'Next due: ${AppDateFormatting.yyyyMmDd(nextDueAt!)}',
                ),
              ),
            ),
            if (nextDueAt != null) ...[
              SizedBox(width: 8),
              IconButton(
                onPressed: () => setState(() => nextDueAt = null),
                icon: Icon(Icons.close),
                tooltip: S.removeNextDueDate,
              ),
            ],
          ],
        ),
        SizedBox(height: 8),
        Text(
          hasRecurrence
              ? S.whenYouCompleteThisChoreTheAppWillScheduleTheNextDueDate
              : S.nonRecurringChoresCanStillBeCompletedManually,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.editItem),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              autofocus: false,
              decoration: InputDecoration(labelText: S.title),
              textInputAction: TextInputAction.next,
              onChanged: (_) {
                if (validationMessage != null) {
                  setState(() => validationMessage = null);
                }
              },
            ),
            SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              autofocus: false,
              decoration: InputDecoration(labelText: S.description),
              minLines: 1,
              maxLines: 3,
            ),
            if (isTaskList) buildTaskFields(),
            if (isChoreList) buildChoreFields(),
            buildValidationMessage(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(S.cancel),
        ),
        ElevatedButton(onPressed: submit, child: Text(S.save)),
      ],
    );
  }
}
