import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';

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
      setState(() => validationMessage = context.l10n.recipeNameIsRequired);
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
      title: Text(context.l10n.addRecipe),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Icon(Icons.restaurant_menu)),
              title: Text(context.l10n.recipe),
              subtitle: Text(context.l10n.saveMealsYouCanPlanAndShopFromLater),
            ),
            SizedBox(height: 12),
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: context.l10n.recipeName,
                hintText: context.l10n.spaghettiCarbonara,
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
                labelText: context.l10n.description,
                hintText: context.l10n.optional,
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
          child: Text(context.l10n.cancel),
        ),
        ElevatedButton(onPressed: submit, child: Text(context.l10n.add)),
      ],
    );
  }
}
