import 'package:flutter/material.dart';

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

  int priority = 0;
  DateTime? deadlineAt;

  String? recurrenceType;
  int recurrenceInterval = 1;
  DateTime? nextDueAt;

  bool get isChoreList => widget.listType == 'chores';
  bool get isTaskList => widget.listType == 'tasks';

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void submit() {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    if (title.isEmpty) return;

    Navigator.of(context).pop(
      CreateItemDialogResult(
        title: title,
        description: description.isEmpty ? null : description,
        priority: priority,
        deadlineAt: deadlineAt,
        recurrenceType: recurrenceType,
        recurrenceInterval: recurrenceType == 'every_n_days'
            ? recurrenceInterval
            : null,
        nextDueAt: nextDueAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              autofocus: false,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Buy milk / Watch movie / Clean kitchen',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              autofocus: false,
              decoration: const InputDecoration(labelText: 'Description'),
            ),

            if (isChoreList) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: recurrenceType,
                decoration: const InputDecoration(labelText: 'Recurrence'),
                items: const [
                  DropdownMenuItem(value: null, child: Text('None')),
                  DropdownMenuItem(value: 'daily', child: Text('Daily')),
                  DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                  DropdownMenuItem(
                    value: 'every_n_days',
                    child: Text('Every N days'),
                  ),
                ],
                onChanged: (value) {
                  setState(() => recurrenceType = value);
                },
              ),

              if (recurrenceType == 'every_n_days') ...[
                const SizedBox(height: 12),
                TextField(
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
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                    initialDate: nextDueAt ?? DateTime.now(),
                  );

                  if (picked == null) return;

                  setState(() => nextDueAt = picked);
                },
                icon: const Icon(Icons.event_repeat),
                label: Text(
                  nextDueAt == null
                      ? 'Set next due date'
                      : 'Next due: ${nextDueAt!.toIso8601String().split('T').first}',
                ),
              ),
            ],

            if (isTaskList) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('None')),
                  DropdownMenuItem(value: 1, child: Text('Low')),
                  DropdownMenuItem(value: 2, child: Text('Medium')),
                  DropdownMenuItem(value: 3, child: Text('High')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => priority = value);
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                    initialDate: deadlineAt ?? DateTime.now(),
                  );

                  if (picked == null) return;

                  setState(() => deadlineAt = picked);
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  deadlineAt == null
                      ? 'Add deadline'
                      : 'Deadline: ${deadlineAt!.toIso8601String().split('T').first}',
                ),
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
        ElevatedButton(onPressed: submit, child: const Text('Add')),
      ],
    );
  }
}
