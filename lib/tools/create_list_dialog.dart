import 'package:flutter/material.dart';

class CreateListDialogResult {
  const CreateListDialogResult({required this.name, required this.listType});

  final String name;
  final String listType;
}

class CreateListDialog extends StatefulWidget {
  const CreateListDialog({super.key});

  @override
  State<CreateListDialog> createState() => _CreateListDialogState();
}

class _CreateListDialogState extends State<CreateListDialog> {
  final nameController = TextEditingController();
  String listType = 'generic';

  final listTypes = const [
    'generic',
    'movies',
    'tasks',
    'chores',
    'ideas',
    'activities',
    'recipes',
    'shopping',
    'meal_plan',
  ];

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void submit() {
    final name = nameController.text.trim();

    if (name.isEmpty) return;

    Navigator.of(
      context,
    ).pop(CreateListDialogResult(name: name, listType: listType));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create list'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            autofocus: false,
            decoration: const InputDecoration(
              labelText: 'List name',
              hintText: 'Movies to watch',
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: listType,
            decoration: const InputDecoration(labelText: 'List type'),
            items: listTypes.map((type) {
              return DropdownMenuItem(value: type, child: Text(type));
            }).toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => listType = value);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: submit, child: const Text('Create')),
      ],
    );
  }
}
