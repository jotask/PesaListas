import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';

class AddRecipeIngredientDialogResult {
  const AddRecipeIngredientDialogResult({
    required this.name,
    this.quantity,
    this.unit,
    this.note,
  });

  final String name;
  final double? quantity;
  final String? unit;
  final String? note;
}

class AddRecipeIngredientDialog extends StatefulWidget {
  const AddRecipeIngredientDialog({super.key});

  @override
  State<AddRecipeIngredientDialog> createState() =>
      _AddRecipeIngredientDialogState();
}

class _AddRecipeIngredientDialogState extends State<AddRecipeIngredientDialog> {
  final nameController = TextEditingController();
  final quantityController = TextEditingController();
  final unitController = TextEditingController();
  final noteController = TextEditingController();

  String? validationMessage;

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    unitController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void submit() {
    final name = nameController.text.trim();
    final quantityText = quantityController.text.trim();
    final unit = unitController.text.trim();
    final note = noteController.text.trim();

    setState(() => validationMessage = null);

    if (name.isEmpty) {
      setState(() => validationMessage = context.l10n.ingredientNameIsRequired);
      return;
    }

    final quantity = quantityText.isEmpty
        ? null
        : double.tryParse(quantityText.replaceAll(',', '.'));

    if (quantityText.isNotEmpty && quantity == null) {
      setState(() => validationMessage = context.l10n.quantityMustBeANumber);
      return;
    }

    Navigator.of(context).pop(
      AddRecipeIngredientDialogResult(
        name: name,
        quantity: quantity,
        unit: unit.isEmpty ? null : unit,
        note: note.isEmpty ? null : note,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.addIngredient),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Icon(Icons.kitchen_outlined)),
              title: Text(context.l10n.ingredient),
              subtitle: Text(context.l10n.addOneIngredientForThisRecipe),
            ),
            SizedBox(height: 12),
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: context.l10n.name,
                hintText: context.l10n.tomatoes,
              ),
              textInputAction: TextInputAction.next,
              onChanged: (_) {
                if (validationMessage != null) {
                  setState(() => validationMessage = null);
                }
              },
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: quantityController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: context.l10n.quantity,
                      hintText: '2',
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: unitController,
                    decoration: InputDecoration(
                      labelText: context.l10n.unit,
                      hintText: context.l10n.pcsGMl,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                labelText: context.l10n.note,
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
