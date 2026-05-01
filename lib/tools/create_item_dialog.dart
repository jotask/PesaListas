import 'package:flutter/material.dart';

class CreateItemDialogResult {
  const CreateItemDialogResult({required this.title, this.description});

  final String title;
  final String? description;
}

class CreateItemDialog extends StatefulWidget {
  const CreateItemDialog({super.key});

  @override
  State<CreateItemDialog> createState() => _CreateItemDialogState();
}

class _CreateItemDialogState extends State<CreateItemDialog> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add item'),
      content: Column(
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
        ],
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
