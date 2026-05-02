import 'package:flutter/material.dart';
import 'package:pesalistas/core/list_types.dart';

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

  String listType = AppListTypes.generic.value;

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
    final selectedConfig = AppListTypes.fromValue(listType);

    return AlertDialog(
      title: const Text('Create list'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'List name',
                hintText: 'Movies to watch',
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => submit(),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: listType,
              decoration: const InputDecoration(labelText: 'List type'),
              items: AppListTypes.all.map((config) {
                return DropdownMenuItem<String>(
                  value: config.value,
                  child: Row(
                    children: [
                      Icon(config.icon, size: 20),
                      const SizedBox(width: 12),
                      Text(config.label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => listType = value);
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Icon(selectedConfig.icon)),
              title: Text(selectedConfig.label),
              subtitle: Text(selectedConfig.description),
            ),
          ],
        ),
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
