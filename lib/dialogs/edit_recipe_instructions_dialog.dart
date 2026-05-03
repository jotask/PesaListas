import 'package:flutter/material.dart';
import 'package:pesalistas/core/recipe_fields.dart';

class EditRecipeInstructionsDialogResult {
  const EditRecipeInstructionsDialogResult({this.instructions});

  final String? instructions;
}

class EditRecipeInstructionsDialog extends StatefulWidget {
  const EditRecipeInstructionsDialog({super.key, required this.recipe});

  final Map<String, dynamic> recipe;

  @override
  State<EditRecipeInstructionsDialog> createState() =>
      _EditRecipeInstructionsDialogState();
}

class _EditRecipeInstructionsDialogState
    extends State<EditRecipeInstructionsDialog> {
  late final TextEditingController instructionsController;

  @override
  void initState() {
    super.initState();

    instructionsController = TextEditingController(
      text: widget.recipe[AppRecipeFields.instructions]?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    instructionsController.dispose();
    super.dispose();
  }

  void submit() {
    final instructions = instructionsController.text.trim();

    Navigator.of(context).pop(
      EditRecipeInstructionsDialogResult(
        instructions: instructions.isEmpty ? null : instructions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit instructions'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Icon(Icons.menu_book_outlined)),
              title: Text('Cooking instructions'),
              subtitle: Text('Add the preparation steps for this recipe.'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: instructionsController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Instructions',
                hintText:
                    '1. Chop vegetables\n2. Cook pasta\n3. Mix everything',
                alignLabelWithHint: true,
              ),
              minLines: 8,
              maxLines: 14,
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
            ),
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
