import 'package:flutter/material.dart';
import 'package:pesalistas/core/recipe_fields.dart';
import 'package:pesalistas/core/recipe_ingredient_fields.dart';
import 'package:pesalistas/core/value_parsing.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';

enum RecipeDetailsPageAction {
  addIngredient,
  editIngredient,
  deleteIngredient,
  editRecipeInfo,
  editRecipeInstructions,
}

class RecipeDetailsPageResult {
  const RecipeDetailsPageResult({
    required this.action,
    this.ingredientId,
    this.ingredientName,
    this.ingredient,
  });

  final RecipeDetailsPageAction action;
  final String? ingredientId;
  final String? ingredientName;
  final Map<String, dynamic>? ingredient;
}

class RecipeDetailsPage extends StatelessWidget {
  const RecipeDetailsPage({
    super.key,
    required this.recipe,
    required this.ingredients,
  });

  final Map<String, dynamic> recipe;
  final List<Map<String, dynamic>> ingredients;

  String name(BuildContext context) {
    final value = recipe[AppRecipeFields.name]?.toString();

    if (value == null || value.trim().isEmpty) {
      return context.l10n.untitledRecipe;
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

  void editInfo(BuildContext context) {
    Navigator.of(context).pop(
      const RecipeDetailsPageResult(
        action: RecipeDetailsPageAction.editRecipeInfo,
      ),
    );
  }

  void editInstructions(BuildContext context) {
    Navigator.of(context).pop(
      const RecipeDetailsPageResult(
        action: RecipeDetailsPageAction.editRecipeInstructions,
      ),
    );
  }

  void addIngredient(BuildContext context) {
    Navigator.of(context).pop(
      const RecipeDetailsPageResult(
        action: RecipeDetailsPageAction.addIngredient,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recipeName = name(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(recipeName),
        actions: [
          IconButton(
            onPressed: () => editInfo(context),
            icon: const Icon(Icons.tune_outlined),
            tooltip: context.l10n.info,
          ),
          IconButton(
            onPressed: () => addIngredient(context),
            icon: const Icon(Icons.add),
            tooltip: context.l10n.ingredient,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => addIngredient(context),
        icon: const Icon(Icons.add),
        label: Text(context.l10n.ingredient),
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
                        Icons.restaurant_menu,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recipeName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (description != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              description!,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _RecipeInfoChip(
                  icon: Icons.timer_outlined,
                  label: prepTime == null
                      ? context.l10n.prepNotSet
                      : context.l10n.prepMinutes(prepTime!),
                ),
                _RecipeInfoChip(
                  icon: Icons.local_fire_department_outlined,
                  label: cookTime == null
                      ? context.l10n.cookNotSet
                      : context.l10n.cookMinutes(cookTime!),
                ),
                _RecipeInfoChip(
                  icon: Icons.people_outline,
                  label: servings == null
                      ? context.l10n.servingsNotSet
                      : context.l10n.servingsCount(servings!),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InstructionsCard(
              instructions: instructions,
              onEdit: () => editInstructions(context),
            ),
            const SizedBox(height: 16),
            _IngredientsSection(ingredients: ingredients),
            const SizedBox(height: 96),
          ],
        ),
      ),
    );
  }
}

class _InstructionsCard extends StatelessWidget {
  const _InstructionsCard({required this.instructions, required this.onEdit});

  final String? instructions;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  child: Icon(
                    Icons.menu_book_outlined,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.l10n.instructions,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_note_outlined),
                  tooltip: context.l10n.editInstructions,
                ),
              ],
            ),
            const SizedBox(height: 12),
            SelectableText(
              instructions ?? context.l10n.noInstructionsYet,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _IngredientsSection extends StatelessWidget {
  const _IngredientsSection({required this.ingredients});

  final List<Map<String, dynamic>> ingredients;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.tertiaryContainer,
                  child: Icon(
                    Icons.kitchen_outlined,
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.l10n.ingredients,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  ingredients.length == 1
                      ? context.l10n.ingredientCountOne
                      : context.l10n.ingredientCountMany(ingredients.length),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (ingredients.isEmpty)
              Text(
                context.l10n.noIngredientsYet,
                style: theme.textTheme.bodyMedium,
              )
            else
              for (final ingredient in ingredients)
                _IngredientCard(ingredient: ingredient),
          ],
        ),
      ),
    );
  }
}

class _IngredientCard extends StatelessWidget {
  const _IngredientCard({required this.ingredient});

  final Map<String, dynamic> ingredient;

  String get id {
    return ingredient[AppRecipeIngredientFields.id].toString();
  }

  String name(BuildContext context) {
    final value = ingredient[AppRecipeIngredientFields.name]?.toString();

    if (value == null || value.trim().isEmpty) {
      return context.l10n.unnamedIngredient;
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

  String amountText(BuildContext context) {
    final parts = <String>[];

    if (quantityText != null) {
      parts.add(quantityText!);
    }

    if (unit != null) {
      parts.add(unit!);
    }

    if (parts.isEmpty) {
      return context.l10n.amountNotSet;
    }

    return parts.join(' ');
  }

  void editIngredient(BuildContext context) {
    Navigator.of(context).pop(
      RecipeDetailsPageResult(
        action: RecipeDetailsPageAction.editIngredient,
        ingredientId: id,
        ingredientName: name(context),
        ingredient: ingredient,
      ),
    );
  }

  void deleteIngredient(BuildContext context) {
    Navigator.of(context).pop(
      RecipeDetailsPageResult(
        action: RecipeDetailsPageAction.deleteIngredient,
        ingredientId: id,
        ingredientName: name(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.kitchen_outlined,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        title: Text(
          name(context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          note == null ? amountText(context) : '${amountText(context)} • $note',
        ),
        trailing: Wrap(
          spacing: 0,
          children: [
            IconButton(
              onPressed: () => editIngredient(context),
              icon: const Icon(Icons.edit_outlined),
              tooltip: context.l10n.editIngredient,
            ),
            IconButton(
              onPressed: () => deleteIngredient(context),
              icon: const Icon(Icons.delete_outline),
              tooltip: context.l10n.deleteIngredient,
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
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
