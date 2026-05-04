import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/app_strings.dart';

class CreateRecipeDialogResult {
  const CreateRecipeDialogResult({required this.name, this.description});

  final String name;
  final String? description;
}

class CreateRecipeDialog extends StatefulWidget {
  const CreateRecipeDialog({super.key});

  @override
  State<CreateRecipeDialog> createState() => _CreateRecipeDialogState();
}

class _CreateRecipeDialogState extends State<CreateRecipeDialog> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  String? validationMessage;

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void submit() {
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();

    setState(() => validationMessage = null);

    if (name.isEmpty) {
      setState(() => validationMessage = S.recipeNameIsRequired);
      return;
    }

    Navigator.of(context).pop(
      CreateRecipeDialogResult(
        name: name,
        description: description.isEmpty ? null : description,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.addRecipe),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Icon(Icons.restaurant_menu)),
              title: Text(S.recipe),
              subtitle: Text(S.saveMealsYouCanPlanAndShopFromLater),
            ),
            SizedBox(height: 12),
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: S.recipeName,
                hintText: S.spaghettiCarbonara,
              ),
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
              decoration: InputDecoration(
                labelText: S.description,
                hintText: S.optional,
              ),
              minLines: 1,
              maxLines: 3,
            ),
            if (validationMessage != null) ...[
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.error_outline, size: 18),
                  SizedBox(width: 8),
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
          child: Text(S.cancel),
        ),
        ElevatedButton(onPressed: submit, child: Text(S.add)),
      ],
    );
  }
}
