import 'package:flutter/material.dart';
import 'package:pesalistas/core/recipe_fields.dart';
import 'package:pesalistas/core/value_parsing.dart';

class EditRecipeDialogResult {
  const EditRecipeDialogResult({
    required this.name,
    this.description,
    this.prepTimeMinutes,
    this.cookTimeMinutes,
    this.servings,
  });

  final String name;
  final String? description;
  final int? prepTimeMinutes;
  final int? cookTimeMinutes;
  final int? servings;
}

class EditRecipeDialog extends StatefulWidget {
  const EditRecipeDialog({super.key, required this.recipe});

  final Map<String, dynamic> recipe;

  @override
  State<EditRecipeDialog> createState() => _EditRecipeDialogState();
}

class _EditRecipeDialogState extends State<EditRecipeDialog> {
  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  late final TextEditingController prepTimeController;
  late final TextEditingController cookTimeController;
  late final TextEditingController servingsController;

  String? validationMessage;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.recipe[AppRecipeFields.name]?.toString() ?? '',
    );

    descriptionController = TextEditingController(
      text: widget.recipe[AppRecipeFields.description]?.toString() ?? '',
    );

    prepTimeController = TextEditingController(
      text: _intText(widget.recipe[AppRecipeFields.prepTimeMinutes]),
    );

    cookTimeController = TextEditingController(
      text: _intText(widget.recipe[AppRecipeFields.cookTimeMinutes]),
    );

    servingsController = TextEditingController(
      text: _intText(widget.recipe[AppRecipeFields.servings]),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    prepTimeController.dispose();
    cookTimeController.dispose();
    servingsController.dispose();
    super.dispose();
  }

  String _intText(dynamic value) {
    final parsed = AppValueParsing.intOrNull(value);

    if (parsed == null) return '';

    return parsed.toString();
  }

  int? parseOptionalPositiveInt({
    required String value,
    required String fieldName,
    bool allowZero = true,
  }) {
    final text = value.trim();

    if (text.isEmpty) {
      return null;
    }

    final parsed = int.tryParse(text);

    if (parsed == null) {
      throw '$fieldName must be a whole number.';
    }

    if (allowZero && parsed < 0) {
      throw '$fieldName cannot be negative.';
    }

    if (!allowZero && parsed <= 0) {
      throw '$fieldName must be greater than 0.';
    }

    return parsed;
  }

  void submit() {
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();

    setState(() => validationMessage = null);

    if (name.isEmpty) {
      setState(() => validationMessage = 'Recipe name is required.');
      return;
    }

    try {
      final prepTime = parseOptionalPositiveInt(
        value: prepTimeController.text,
        fieldName: 'Prep time',
      );

      final cookTime = parseOptionalPositiveInt(
        value: cookTimeController.text,
        fieldName: 'Cook time',
      );

      final servings = parseOptionalPositiveInt(
        value: servingsController.text,
        fieldName: 'Servings',
        allowZero: false,
      );

      Navigator.of(context).pop(
        EditRecipeDialogResult(
          name: name,
          description: description.isEmpty ? null : description,
          prepTimeMinutes: prepTime,
          cookTimeMinutes: cookTime,
          servings: servings,
        ),
      );
    } catch (error) {
      setState(() => validationMessage = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit recipe info'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Icon(Icons.restaurant_menu)),
              title: Text('Recipe info'),
              subtitle: Text('Update name, description, time, and servings.'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Recipe name'),
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
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Optional',
              ),
              minLines: 1,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: prepTimeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Prep',
                      suffixText: 'min',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: cookTimeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Cook',
                      suffixText: 'min',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: servingsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Servings',
                hintText: 'Optional',
              ),
            ),
            if (validationMessage != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.error_outline, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      validationMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
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
        ElevatedButton(onPressed: submit, child: const Text('Save')),
      ],
    );
  }
}
