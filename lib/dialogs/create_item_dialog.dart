import 'package:flutter/material.dart';
import 'package:pesalistas/core/date_formatting.dart';
import 'package:pesalistas/core/list_types.dart';
import 'package:pesalistas/core/priority_types.dart';
import 'package:pesalistas/core/recurrence_types.dart';

class CreateItemDialogResult {
  const CreateItemDialogResult({
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

class CreateItemDialog extends StatefulWidget {
  const CreateItemDialog({super.key, required this.listType});

  final String listType;

  @override
  State<CreateItemDialog> createState() => _CreateItemDialogState();
}

class _CreateItemDialogState extends State<CreateItemDialog> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final recurrenceIntervalController = TextEditingController(text: '2');

  int priority = 0;
  DateTime? deadlineAt;

  String? recurrenceType;
  int recurrenceInterval = 2;
  DateTime? nextDueAt;

  String? validationMessage;

  AppListTypeConfig get listTypeConfig =>
      AppListTypes.fromValue(widget.listType);

  bool get isTaskList => widget.listType == AppListTypes.tasks.value;

  bool get isChoreList => widget.listType == AppListTypes.chores.value;

  bool get usesCustomInterval =>
      recurrenceType == AppRecurrenceTypes.everyNDays.value;

  bool get hasRecurrence => recurrenceType != null;

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
      setState(() => validationMessage = 'Title is required.');
      return;
    }

    if (isChoreList && usesCustomInterval && recurrenceInterval < 2) {
      setState(
        () => validationMessage = 'Custom recurrence must be at least 2 days.',
      );
      return;
    }

    Navigator.of(context).pop(
      CreateItemDialogResult(
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
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      initialDate: deadlineAt ?? DateTime.now(),
    );

    if (picked == null) return;

    setState(() => deadlineAt = picked);
  }

  Future<void> pickNextDueDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
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
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 18),
          const SizedBox(width: 8),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        DropdownButtonFormField<String?>(
          value: recurrenceType,
          decoration: const InputDecoration(
            labelText: 'Recurrence',
            helperText: 'Choose how often this chore repeats.',
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
          const SizedBox(height: 12),
          TextField(
            controller: recurrenceIntervalController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Repeat every',
              suffixText: 'days',
              helperText: 'Minimum 2 days.',
            ),
            onChanged: updateRecurrenceInterval,
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: hasRecurrence ? pickNextDueDate : null,
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
        const SizedBox(height: 8),
        Text(
          hasRecurrence
              ? 'When you complete this chore, the app will schedule the next due date.'
              : 'Non-recurring chores can still be completed manually.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = listTypeConfig;

    return AlertDialog(
      title: Text('Add ${config.label.toLowerCase()} item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Icon(config.icon)),
              title: Text(config.label),
              subtitle: Text(config.description),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: titleController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Buy milk / Watch movie / Clean kitchen',
              ),
              textInputAction: TextInputAction.next,
              onChanged: (_) {
                if (validationMessage != null) {
                  setState(() => validationMessage = null);
                }
              },
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
            buildValidationMessage(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: submit, child: const Text('Add')),
      ],
    );
  }
}
