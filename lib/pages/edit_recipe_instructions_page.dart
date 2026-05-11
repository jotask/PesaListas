import 'package:flutter/material.dart';
import 'package:pesalistas/core/fields/recipe_fields.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/widgets/common/form_page_layout.dart';

class EditRecipeInstructionsPageResult {
  const EditRecipeInstructionsPageResult({this.instructions});

  final String? instructions;
}

class EditRecipeInstructionsPage extends StatefulWidget {
  const EditRecipeInstructionsPage({super.key, required this.recipe});

  final Map<String, dynamic> recipe;

  @override
  State<EditRecipeInstructionsPage> createState() =>
      _EditRecipeInstructionsPageState();
}

class _EditRecipeInstructionsPageState
    extends State<EditRecipeInstructionsPage> {
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
      EditRecipeInstructionsPageResult(
        instructions: instructions.isEmpty ? null : instructions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.editInstructions)),
      bottomNavigationBar: AppFormBottomActions(
        cancelLabel: context.l10n.cancel,
        primaryLabel: context.l10n.save,
        primaryIcon: Icons.save_outlined,
        onCancel: () => Navigator.of(context).pop(),
        onPrimary: submit,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppFormPageHeaderCard(
              icon: Icons.menu_book_outlined,
              title: context.l10n.cookingInstructions,
              subtitle: context.l10n.addThePreparationStepsForThisRecipe,
            ),
            const SizedBox(height: 16),
            AppFormSectionCard(
              children: [
                TextField(
                  controller: instructionsController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: context.l10n.instructions,
                    hintText: context.l10n.instructionsExampleHint,
                    alignLabelWithHint: true,
                    prefixIcon: const Icon(Icons.edit_note_outlined),
                  ),
                  minLines: 14,
                  maxLines: 24,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                ),
              ],
            ),
            const SizedBox(height: 96),
          ],
        ),
      ),
    );
  }
}
