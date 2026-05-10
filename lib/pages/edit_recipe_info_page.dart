import 'package:flutter/material.dart';
import 'package:pesalistas/core/recipe_fields.dart';
import 'package:pesalistas/core/value_parsing.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/widgets/common/form_page_layout.dart';

class EditRecipeInfoPageResult {
  const EditRecipeInfoPageResult({
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

class EditRecipeInfoPage extends StatefulWidget {
  const EditRecipeInfoPage({super.key, required this.recipe});

  final Map<String, dynamic> recipe;

  @override
  State<EditRecipeInfoPage> createState() => _EditRecipeInfoPageState();
}

class _EditRecipeInfoPageState extends State<EditRecipeInfoPage> {
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
      text: intText(widget.recipe[AppRecipeFields.prepTimeMinutes]),
    );

    cookTimeController = TextEditingController(
      text: intText(widget.recipe[AppRecipeFields.cookTimeMinutes]),
    );

    servingsController = TextEditingController(
      text: intText(widget.recipe[AppRecipeFields.servings]),
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

  String intText(dynamic value) {
    final parsed = AppValueParsing.intOrNull(value);

    if (parsed == null) return '';

    return parsed.toString();
  }

  void clearValidation() {
    if (validationMessage == null) return;

    setState(() => validationMessage = null);
  }

  int? parseOptionalPositiveInt({
    required BuildContext context,
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
      throw context.l10n.fieldMustBeWholeNumber(fieldName);
    }

    if (allowZero && parsed < 0) {
      throw context.l10n.fieldCannotBeNegative(fieldName);
    }

    if (!allowZero && parsed <= 0) {
      throw context.l10n.fieldMustBeGreaterThanZero(fieldName);
    }

    return parsed;
  }

  void submit() {
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();

    setState(() => validationMessage = null);

    if (name.isEmpty) {
      setState(() => validationMessage = context.l10n.recipeNameIsRequired);
      return;
    }

    try {
      final prepTime = parseOptionalPositiveInt(
        context: context,
        value: prepTimeController.text,
        fieldName: context.l10n.prepTime,
      );

      final cookTime = parseOptionalPositiveInt(
        context: context,
        value: cookTimeController.text,
        fieldName: context.l10n.cookTime,
      );

      final servings = parseOptionalPositiveInt(
        context: context,
        value: servingsController.text,
        fieldName: context.l10n.servings,
        allowZero: false,
      );

      Navigator.of(context).pop(
        EditRecipeInfoPageResult(
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
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.editRecipeInfo)),
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
              icon: Icons.restaurant_menu,
              title: context.l10n.recipeInfo,
              subtitle: context.l10n.updateNameDescriptionTimeAndServings,
            ),
            const SizedBox(height: 16),
            AppFormSectionCard(
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: context.l10n.recipeName,
                    prefixIcon: const Icon(Icons.restaurant_menu),
                  ),
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => clearValidation(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: context.l10n.description,
                    hintText: context.l10n.optional,
                    prefixIcon: const Icon(Icons.notes_outlined),
                  ),
                  minLines: 3,
                  maxLines: 6,
                  textInputAction: TextInputAction.newline,
                  onChanged: (_) => clearValidation(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: prepTimeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: context.l10n.prep,
                          suffixText: context.l10n.minutesAbbreviation,
                          prefixIcon: const Icon(Icons.timer_outlined),
                        ),
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => clearValidation(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: cookTimeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: context.l10n.cook,
                          suffixText: context.l10n.minutesAbbreviation,
                          prefixIcon: const Icon(
                            Icons.local_fire_department_outlined,
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => clearValidation(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: servingsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: context.l10n.servings,
                    hintText: context.l10n.optional,
                    prefixIcon: const Icon(Icons.people_outline),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => submit(),
                  onChanged: (_) => clearValidation(),
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
