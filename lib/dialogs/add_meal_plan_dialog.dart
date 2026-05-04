import 'package:flutter/material.dart';
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
      return 'Untitled recipe';
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
      title: const Text('Add meal plan'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Icon(Icons.event_note_outlined)),
              title: Text('Meal plan'),
              subtitle: Text(
                'Plan a meal for a date and optionally choose a recipe.',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: pickDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(formatDate(plannedFor)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: mealType,
              decoration: const InputDecoration(labelText: 'Meal type'),
              items: AppMealTypes.all.map((config) {
                return DropdownMenuItem<String>(
                  value: config.value,
                  child: Text(config.label),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => mealType = value);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedRecipeValue,
              decoration: const InputDecoration(
                labelText: 'Recipe',
                helperText: 'Optional. You can also create a custom meal note.',
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: noRecipeValue,
                  child: Text('No recipe / custom meal'),
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
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Note',
                hintText: 'Optional, e.g. family dinner or leftovers',
              ),
              minLines: 1,
              maxLines: 3,
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
        ElevatedButton(onPressed: submit, child: const Text('Add')),
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
      label: 'Breakfast',
      icon: Icons.free_breakfast_outlined,
    ),
    AppMealTypeConfig(
      value: lunch,
      label: 'Lunch',
      icon: Icons.lunch_dining_outlined,
    ),
    AppMealTypeConfig(
      value: dinner,
      label: 'Dinner',
      icon: Icons.dinner_dining_outlined,
    ),
    AppMealTypeConfig(
      value: snack,
      label: 'Snack',
      icon: Icons.cookie_outlined,
    ),
  ];

  static AppMealTypeConfig fromValue(String value) {
    for (final config in all) {
      if (config.value == value) return config;
    }

    return const AppMealTypeConfig(
      value: dinner,
      label: 'Dinner',
      icon: Icons.dinner_dining_outlined,
    );
  }
}

class AppMealTypeConfig {
  const AppMealTypeConfig({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;
}
