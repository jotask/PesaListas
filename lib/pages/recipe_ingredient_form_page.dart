import 'package:flutter/material.dart';
import 'package:pesalistas/core/recipe_ingredient_fields.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/widgets/common/form_page_layout.dart';

class RecipeIngredientFormPageResult {
  const RecipeIngredientFormPageResult({
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

class RecipeIngredientFormPage extends StatefulWidget {
  const RecipeIngredientFormPage({super.key, this.ingredient});

  final Map<String, dynamic>? ingredient;

  @override
  State<RecipeIngredientFormPage> createState() =>
      _RecipeIngredientFormPageState();
}

class _RecipeIngredientFormPageState extends State<RecipeIngredientFormPage> {
  late final TextEditingController nameController;
  late final TextEditingController quantityController;
  late final TextEditingController unitController;
  late final TextEditingController noteController;

  String? validationMessage;

  bool get isEditing => widget.ingredient != null;

  @override
  void initState() {
    super.initState();

    final ingredient = widget.ingredient;

    nameController = TextEditingController(
      text: ingredient?[AppRecipeIngredientFields.name]?.toString() ?? '',
    );

    quantityController = TextEditingController(
      text: ingredient?[AppRecipeIngredientFields.quantity]?.toString() ?? '',
    );

    unitController = TextEditingController(
      text: ingredient?[AppRecipeIngredientFields.unit]?.toString() ?? '',
    );

    noteController = TextEditingController(
      text: ingredient?[AppRecipeIngredientFields.note]?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    unitController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void clearValidation() {
    if (validationMessage == null) return;

    setState(() => validationMessage = null);
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
      RecipeIngredientFormPageResult(
        name: name,
        quantity: quantity,
        unit: unit.isEmpty ? null : unit,
        note: note.isEmpty ? null : note,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? context.l10n.editIngredient : context.l10n.addIngredient,
        ),
      ),
      bottomNavigationBar: AppFormBottomActions(
        cancelLabel: context.l10n.cancel,
        primaryLabel: isEditing ? context.l10n.save : context.l10n.add,
        primaryIcon: isEditing ? Icons.save_outlined : Icons.add,
        onCancel: () => Navigator.of(context).pop(),
        onPrimary: submit,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppFormPageHeaderCard(
              icon: Icons.kitchen_outlined,
              title: context.l10n.ingredient,
              subtitle: isEditing
                  ? context.l10n.updateThisRecipeIngredient
                  : context.l10n.addOneIngredientForThisRecipe,
            ),
            const SizedBox(height: 16),
            AppFormSectionCard(
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: context.l10n.name,
                    hintText: context.l10n.tomatoes,
                    prefixIcon: const Icon(Icons.kitchen_outlined),
                  ),
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => clearValidation(),
                ),
                const SizedBox(height: 16),
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
                          prefixIcon: const Icon(Icons.numbers_outlined),
                        ),
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => clearValidation(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: unitController,
                        decoration: InputDecoration(
                          labelText: context.l10n.unit,
                          hintText: context.l10n.pcsGMl,
                          prefixIcon: const Icon(Icons.scale_outlined),
                        ),
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => clearValidation(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: noteController,
                  decoration: InputDecoration(
                    labelText: context.l10n.note,
                    hintText: context.l10n.optional,
                    prefixIcon: const Icon(Icons.notes_outlined),
                  ),
                  minLines: 3,
                  maxLines: 6,
                  textInputAction: TextInputAction.newline,
                ),
                if (validationMessage != null) ...[
                  const SizedBox(height: 16),
                  AppFormValidationMessage(message: validationMessage!),
                ],
              ],
            ),
            const SizedBox(height: 96),
          ],
        ),
      ),
    );
  }
}
