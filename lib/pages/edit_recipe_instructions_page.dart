import 'package:flutter/material.dart';
import 'package:pesalistas/core/recipe_fields.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';

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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.editInstructions)),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(context.l10n.cancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: submit,
                  child: Text(context.l10n.save),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.menu_book_outlined,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.cookingInstructions,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.l10n.addThePreparationStepsForThisRecipe,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: TextField(
                  controller: instructionsController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: context.l10n.instructions,
                    hintText:
                        '1. Chop vegetables\n2. Cook pasta\n3. Mix everything',
                    alignLabelWithHint: true,
                    prefixIcon: const Icon(Icons.edit_note_outlined),
                  ),
                  minLines: 14,
                  maxLines: 24,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                ),
              ),
            ),
            const SizedBox(height: 96),
          ],
        ),
      ),
    );
  }
}
