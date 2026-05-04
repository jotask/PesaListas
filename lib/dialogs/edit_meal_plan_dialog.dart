import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/app_strings.dart';
import 'package:pesalistas/core/meal_plan_fields.dart';
import 'package:pesalistas/core/recipe_fields.dart';
import 'package:pesalistas/dialogs/add_meal_plan_dialog.dart';

class EditMealPlanDialogResult {
  const EditMealPlanDialogResult({
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

class EditMealPlanDialog extends StatefulWidget {
  const EditMealPlanDialog({
    super.key,
    required this.mealPlan,
    required this.recipes,
  });

  final Map<String, dynamic> mealPlan;
  final List<Map<String, dynamic>> recipes;

  @override
  State<EditMealPlanDialog> createState() => _EditMealPlanDialogState();
}

class _EditMealPlanDialogState extends State<EditMealPlanDialog> {
  static const noRecipeValue = '__no_recipe__';

  late final TextEditingController noteController;

  late DateTime plannedFor;
  late String mealType;
  late String selectedRecipeValue;

  @override
  void initState() {
    super.initState();

    plannedFor = _parseDate(widget.mealPlan[AppMealPlanFields.plannedFor]);

    mealType =
        widget.mealPlan[AppMealPlanFields.mealType]?.toString() ??
        AppMealTypes.dinner;

    final recipeId = widget.mealPlan[AppMealPlanFields.recipeId]?.toString();

    selectedRecipeValue = recipeId == null || recipeId.isEmpty
        ? noRecipeValue
        : recipeId;

    noteController = TextEditingController(
      text: widget.mealPlan[AppMealPlanFields.note]?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  DateTime _parseDate(dynamic value) {
    final text = value?.toString();

    if (text == null || text.trim().isEmpty) {
      return DateTime.now();
    }

    return DateTime.tryParse(text.split('T').first) ?? DateTime.now();
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
      return S.untitledRecipe;
    }

    return value.trim();
  }

  void submit() {
    final note = noteController.text.trim();

    Navigator.of(context).pop(
      EditMealPlanDialogResult(
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
      title: Text(S.editMealPlan),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Icon(Icons.event_note_outlined)),
              title: Text(S.mealPlan),
              subtitle: Text(S.updateDateMealTypeRecipeOrNote),
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
              decoration: InputDecoration(labelText: S.mealType),
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
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: selectedRecipeValue,
              decoration: InputDecoration(
                labelText: S.recipe,
                helperText: S.optional2,
              ),
              items: [
                DropdownMenuItem<String>(
                  value: noRecipeValue,
                  child: Text(S.noRecipeCustomMeal),
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
                labelText: S.note,
                hintText: S.optional,
              ),
              minLines: 1,
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(S.cancel),
        ),
        ElevatedButton(onPressed: submit, child: Text(S.save)),
      ],
    );
  }
}
