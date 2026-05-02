import 'package:flutter/material.dart';

class EditItemDialogResult {
  const EditItemDialogResult({required this.title, this.description});

  final String title;
  final String? description;
}

class EditItemDialog extends StatefulWidget {
  const EditItemDialog({super.key, required this.item});

  final Map<String, dynamic> item;

  @override
  State<EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<EditItemDialog> {
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.item['title'] ?? '');

    descriptionController = TextEditingController(
      text: widget.item['description'] ?? '',
    );
  }

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
      EditItemDialogResult(
        title: title,
        description: description.isEmpty ? null : description,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit item'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            autofocus: false,
            decoration: const InputDecoration(labelText: 'Title'),
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
        ElevatedButton(onPressed: submit, child: const Text('Save')),
      ],
    );
  }
}
