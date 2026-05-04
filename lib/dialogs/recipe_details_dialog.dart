import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/app_strings.dart';
import 'package:pesalistas/core/recipe_fields.dart';
import 'package:pesalistas/core/recipe_ingredient_fields.dart';
import 'package:pesalistas/core/value_parsing.dart';

enum RecipeDetailsDialogAction {
  addIngredient,
  editIngredient,
  deleteIngredient,
  editRecipeInfo,
  editRecipeInstructions,
}

class RecipeDetailsDialogResult {
  const RecipeDetailsDialogResult({
    required this.action,
    this.ingredientId,
    this.ingredientName,
    this.ingredient,
  });

  final RecipeDetailsDialogAction action;
  final String? ingredientId;
  final String? ingredientName;
  final Map<String, dynamic>? ingredient;
}

class RecipeDetailsDialog extends StatelessWidget {
  const RecipeDetailsDialog({
    super.key,
    required this.recipe,
    required this.ingredients,
  });

  final Map<String, dynamic> recipe;
  final List<Map<String, dynamic>> ingredients;

  String get name {
    final value = recipe[AppRecipeFields.name]?.toString();

    if (value == null || value.trim().isEmpty) {
      return S.untitledRecipe;
    }

    return value.trim();
  }

  String? get description {
    final value = recipe[AppRecipeFields.description]?.toString();

    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return value.trim();
  }

  String? get instructions {
    final value = recipe[AppRecipeFields.instructions]?.toString();

    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return value.trim();
  }

  int? get prepTime {
    return AppValueParsing.intOrNull(recipe[AppRecipeFields.prepTimeMinutes]);
  }

  int? get cookTime {
    return AppValueParsing.intOrNull(recipe[AppRecipeFields.cookTimeMinutes]);
  }

  int? get servings {
    return AppValueParsing.intOrNull(recipe[AppRecipeFields.servings]);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(name),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (description != null) ...[
                Text(description!),
                SizedBox(height: 16),
              ],
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _RecipeInfoChip(
                    icon: Icons.timer_outlined,
                    label: prepTime == null
                        ? S.prepNotSet
                        : S.prepMinutes(prepTime!),
                  ),
                  _RecipeInfoChip(
                    icon: Icons.local_fire_department_outlined,
                    label: cookTime == null
                        ? S.cookNotSet
                        : S.cookMinutes(cookTime!),
                  ),
                  _RecipeInfoChip(
                    icon: Icons.people_outline,
                    label: servings == null
                        ? S.servingsNotSet
                        : S.servingsCount(servings!),
                  ),
                ],
              ),
              SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      S.instructions,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop(
                        const RecipeDetailsDialogResult(
                          action:
                              RecipeDetailsDialogAction.editRecipeInstructions,
                        ),
                      );
                    },
                    icon: Icon(Icons.edit_note_outlined),
                    tooltip: S.editInstructions,
                  ),
                ],
              ),
              Text(instructions ?? S.noInstructionsYet),
              SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      S.ingredients,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    ingredients.length == 1
                        ? S.ingredientCountOne
                        : S.ingredientCountMany(ingredients.length),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              SizedBox(height: 8),
              if (ingredients.isEmpty)
                Text(S.noIngredientsYet)
              else
                Column(
                  children: [
                    for (final ingredient in ingredients)
                      _IngredientRow(ingredient: ingredient),
                  ],
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () {
            Navigator.of(context).pop(
              const RecipeDetailsDialogResult(
                action: RecipeDetailsDialogAction.editRecipeInfo,
              ),
            );
          },
          icon: Icon(Icons.tune_outlined),
          label: Text(S.info),
        ),
        TextButton.icon(
          onPressed: () {
            Navigator.of(context).pop(
              const RecipeDetailsDialogResult(
                action: RecipeDetailsDialogAction.addIngredient,
              ),
            );
          },
          icon: Icon(Icons.add),
          label: Text(S.ingredient),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(S.close),
        ),
      ],
    );
  }
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({required this.ingredient});

  final Map<String, dynamic> ingredient;

  String get id {
    return ingredient[AppRecipeIngredientFields.id].toString();
  }

  String get name {
    final value = ingredient[AppRecipeIngredientFields.name]?.toString();

    if (value == null || value.trim().isEmpty) {
      return S.unnamedIngredient;
    }

    return value.trim();
  }

  String? get unit {
    final value = ingredient[AppRecipeIngredientFields.unit]?.toString();

    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return value.trim();
  }

  String? get note {
    final value = ingredient[AppRecipeIngredientFields.note]?.toString();

    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return value.trim();
  }

  String? get quantityText {
    final value = ingredient[AppRecipeIngredientFields.quantity];

    if (value == null) {
      return null;
    }

    final text = value.toString();

    if (text.trim().isEmpty) {
      return null;
    }

    return text;
  }

  String get amountText {
    final parts = <String>[];

    if (quantityText != null) {
      parts.add(quantityText!);
    }

    if (unit != null) {
      parts.add(unit!);
    }

    if (parts.isEmpty) {
      return S.amountNotSet;
    }

    return parts.join(' ');
  }

  void editIngredient(BuildContext context) {
    Navigator.of(context).pop(
      RecipeDetailsDialogResult(
        action: RecipeDetailsDialogAction.editIngredient,
        ingredientId: id,
        ingredientName: name,
        ingredient: ingredient,
      ),
    );
  }

  void deleteIngredient(BuildContext context) {
    Navigator.of(context).pop(
      RecipeDetailsDialogResult(
        action: RecipeDetailsDialogAction.deleteIngredient,
        ingredientId: id,
        ingredientName: name,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        dense: true,
        leading: CircleAvatar(child: Icon(Icons.kitchen_outlined)),
        title: Text(name),
        subtitle: Text(note == null ? amountText : '$amountText • $note'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => editIngredient(context),
              icon: Icon(Icons.edit_outlined),
              tooltip: S.editIngredient,
            ),
            IconButton(
              onPressed: () => deleteIngredient(context),
              icon: Icon(Icons.delete_outline),
              tooltip: S.deleteIngredient,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeInfoChip extends StatelessWidget {
  const _RecipeInfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: theme.colorScheme.onSurfaceVariant),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
