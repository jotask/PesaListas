import 'package:flutter/material.dart';
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
  int recurrenceInterval = 1;
  DateTime? nextDueAt;

  bool get isTaskList => widget.listType == AppListTypes.tasks.value;

  bool get isChoreList => widget.listType == AppListTypes.chores.value;

  bool get usesCustomInterval =>
      recurrenceType == AppRecurrenceTypes.everyNDays.value;

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
        1;

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

    if (title.isEmpty) return;

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

  Widget buildTaskFields() {
    return Column(
      children: [
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(
          value: priority,
          decoration: const InputDecoration(labelText: 'Priority'),
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
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: pickDeadline,
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  deadlineAt == null
                      ? 'Add deadline'
                      : 'Deadline: ${AppDateFormatting.yyyyMmDd(deadlineAt!)}',
                ),
              ),
            ),
            if (deadlineAt != null) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => setState(() => deadlineAt = null),
                icon: const Icon(Icons.close),
                tooltip: 'Remove deadline',
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget buildChoreFields() {
    return Column(
      children: [
        const SizedBox(height: 16),
        DropdownButtonFormField<String?>(
          value: recurrenceType,
          decoration: const InputDecoration(labelText: 'Recurrence'),
          items: AppRecurrenceTypes.all.map((config) {
            return DropdownMenuItem<String?>(
              value: config.value,
              child: Text(config.label),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => recurrenceType = value);
          },
        ),
        if (usesCustomInterval) ...[
          const SizedBox(height: 12),
          TextField(
            controller: recurrenceIntervalController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Repeat every how many days?',
            ),
            onChanged: (value) {
              recurrenceInterval = int.tryParse(value) ?? 1;
            },
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: pickNextDueDate,
                icon: const Icon(Icons.event_repeat),
                label: Text(
                  nextDueAt == null
                      ? 'Set next due date'
                      : 'Next due: ${AppDateFormatting.yyyyMmDd(nextDueAt!)}',
                ),
              ),
            ),
            if (nextDueAt != null) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => setState(() => nextDueAt = null),
                icon: const Icon(Icons.close),
                tooltip: 'Remove next due date',
              ),
            ],
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              autofocus: false,
              decoration: const InputDecoration(labelText: 'Title'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              autofocus: false,
              decoration: const InputDecoration(labelText: 'Description'),
              minLines: 1,
              maxLines: 3,
            ),
            if (isTaskList) buildTaskFields(),
            if (isChoreList) buildChoreFields(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: submit, child: const Text('Save')),
      ],
    );
  }
}
