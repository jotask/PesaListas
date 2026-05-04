import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/core/recipe_fields.dart';

class AddMealPlanDialogResult {
  const AddMealPlanDialogResult({
    required this.plannedFor,
    required this.mealType,
    this.recipeId,
    this.note,
  });

  final DateTime plannedFor;
  final String mealType;
  final String? recipeId;
  final String? note;
}

class AddMealPlanDialog extends StatefulWidget {
  const AddMealPlanDialog({super.key, required this.recipes});

  final List<Map<String, dynamic>> recipes;

  @override
  State<AddMealPlanDialog> createState() => _AddMealPlanDialogState();
}

class _AddMealPlanDialogState extends State<AddMealPlanDialog> {
  static const noRecipeValue = '__no_recipe__';

  final noteController = TextEditingController();

  DateTime plannedFor = DateTime.now();
  String mealType = AppMealTypes.dinner;
  String selectedRecipeValue = noRecipeValue;

  String? validationMessage;

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  String formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      initialDate: plannedFor,
    );

    if (picked == null) return;

    setState(() => plannedFor = picked);
  }

  String recipeNameFor(Map<String, dynamic> recipe) {
    final value = recipe[AppRecipeFields.name]?.toString();

    if (value == null || value.trim().isEmpty) {
      return context.l10n.untitledRecipe;
    }

    return value.trim();
  }

  void submit() {
    final note = noteController.text.trim();

    setState(() => validationMessage = null);

    Navigator.of(context).pop(
      AddMealPlanDialogResult(
        plannedFor: plannedFor,
        mealType: mealType,
        recipeId: selectedRecipeValue == noRecipeValue
            ? null
            : selectedRecipeValue,
        note: note.isEmpty ? null : note,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.addMealPlan),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Icon(Icons.event_note_outlined)),
              title: Text(context.l10n.mealPlan),
              subtitle: Text(context.l10n.planAMealForADateAndOptionallyChooseARecipe),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: pickDate,
                    icon: Icon(Icons.calendar_today),
                    label: Text(formatDate(plannedFor)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: mealType,
              decoration: InputDecoration(labelText: context.l10n.mealType),
              items: AppMealTypes.all.map((config) {
                return DropdownMenuItem<String>(
                  value: config.value,
                  child: Text(config.label(context)),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => mealType = value);
              },
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: selectedRecipeValue,
              decoration: InputDecoration(
                labelText: context.l10n.recipe,
                helperText: context.l10n.optionalYouCanAlsoCreateACustomMealNote,
              ),
              items: [
                DropdownMenuItem<String>(
                  value: noRecipeValue,
                  child: Text(context.l10n.noRecipeCustomMeal),
                ),
                for (final recipe in widget.recipes)
                  DropdownMenuItem<String>(
                    value: recipe[AppRecipeFields.id].toString(),
                    child: Text(recipeNameFor(recipe)),
                  ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => selectedRecipeValue = value);
              },
            ),
            SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                labelText: context.l10n.note,
                hintText: context.l10n.optionalEGFamilyDinnerOrLeftovers,
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

class AppMealTypes {
  const AppMealTypes._();

  static const breakfast = 'breakfast';
  static const lunch = 'lunch';
  static const dinner = 'dinner';
  static const snack = 'snack';

  static const all = [
    AppMealTypeConfig(
      value: breakfast,
      labelKey: 'breakfast',
      icon: Icons.free_breakfast_outlined,
    ),
    AppMealTypeConfig(
      value: lunch,
      labelKey: 'lunch',
      icon: Icons.lunch_dining_outlined,
    ),
    AppMealTypeConfig(
      value: dinner,
      labelKey: 'dinner',
      icon: Icons.dinner_dining_outlined,
    ),
    AppMealTypeConfig(
      value: snack,
      labelKey: 'snack',
      icon: Icons.cookie_outlined,
    ),
  ];

  static AppMealTypeConfig fromValue(String value) {
    for (final config in all) {
      if (config.value == value) return config;
    }

    return all[2];
  }
}

class AppMealTypeConfig {
  const AppMealTypeConfig({
    required this.value,
    required this.labelKey,
    required this.icon,
  });

  final String value;
  final String labelKey;
  final IconData icon;

  String label(BuildContext context) {
    switch (labelKey) {
      case 'breakfast':
        return context.l10n.breakfast;
      case 'lunch':
        return context.l10n.lunch;
      case 'dinner':
        return context.l10n.dinner;
      case 'snack':
        return context.l10n.snack;
      default:
        return context.l10n.dinner;
    }
  }
}
