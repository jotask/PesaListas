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

  String get priceCurrency {
    for (final ingredient in ingredients) {
      final value = ingredient[AppRecipeIngredientFields.priceCurrency]
          ?.toString()
          .trim();

      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    return 'EUR';
  }

  double get estimatedRecipeCost {
    return ingredients.fold<double>(0, (total, ingredient) {
      return total + (estimatedIngredientTotal(ingredient) ?? 0);
    });
  }

  bool get hasEstimatedIngredientPrices {
    return ingredients.any((ingredient) {
      return estimatedIngredientTotal(ingredient) != null;
    });
  }

  double? estimatedIngredientTotal(Map<String, dynamic> ingredient) {
    final explicitTotal = doubleOrNull(
      ingredient[AppRecipeIngredientFields.estimatedTotalPrice],
    );

    if (explicitTotal != null) {
      return explicitTotal;
    }

    final unitPrice = doubleOrNull(
      ingredient[AppRecipeIngredientFields.estimatedUnitPrice],
    );

    if (unitPrice == null) {
      return null;
    }

    final quantity = doubleOrNull(
      ingredient[AppRecipeIngredientFields.quantity],
    );

    if (quantity == null) {
      return unitPrice;
    }

    return unitPrice * quantity;
  }

  double? doubleOrNull(dynamic value) {
    if (value == null) return null;

    if (value is num) return value.toDouble();

    return double.tryParse(value.toString().replaceAll(',', '.'));
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
            _RecipeHeaderCard(
              recipeName: recipeName,
              description: description,
              onEdit: () => editInfo(context),
            ),
            const SizedBox(height: 12),
            _RecipeStatsWrap(
              prepTime: prepTime,
              cookTime: cookTime,
              servings: servings,
              hasEstimatedCost: hasEstimatedIngredientPrices,
              estimatedCost: estimatedRecipeCost,
              currency: priceCurrency,
            ),
            const SizedBox(height: 16),
            _InstructionsCard(
              instructions: instructions,
              onEdit: () => editInstructions(context),
            ),
            const SizedBox(height: 16),
            _IngredientsSection(
              ingredients: ingredients,
              onAdd: () => addIngredient(context),
            ),
            const SizedBox(height: 96),
          ],
        ),
      ),
    );
  }
}

class _RecipeHeaderCard extends StatelessWidget {
  const _RecipeHeaderCard({
    required this.recipeName,
    required this.description,
    required this.onEdit,
  });

  final String recipeName;
  final String? description;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 30,
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
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 6),
                    Text(description!, style: theme.textTheme.bodyMedium),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              tooltip: context.l10n.info,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeStatsWrap extends StatelessWidget {
  const _RecipeStatsWrap({
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    required this.hasEstimatedCost,
    required this.estimatedCost,
    required this.currency,
  });

  final int? prepTime;
  final int? cookTime;
  final int? servings;
  final bool hasEstimatedCost;
  final double estimatedCost;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Wrap(
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
        if (hasEstimatedCost)
          _RecipeInfoChip(
            icon: Icons.euro_outlined,
            label: 'Est. ${estimatedCost.toStringAsFixed(2)} $currency',
          ),
      ],
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

    return _RecipeSectionCard(
      icon: Icons.menu_book_outlined,
      title: context.l10n.instructions,
      trailing: IconButton(
        onPressed: onEdit,
        icon: const Icon(Icons.edit_note_outlined),
        tooltip: context.l10n.editInstructions,
      ),
      child: SelectableText(
        instructions ?? context.l10n.noInstructionsYet,
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}

class _IngredientsSection extends StatelessWidget {
  const _IngredientsSection({required this.ingredients, required this.onAdd});

  final List<Map<String, dynamic>> ingredients;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final countLabel = ingredients.length == 1
        ? context.l10n.ingredientCountOne
        : context.l10n.ingredientCountMany(ingredients.length);

    return _RecipeSectionCard(
      icon: Icons.kitchen_outlined,
      title: context.l10n.ingredients,
      subtitle: countLabel,
      trailing: IconButton(
        onPressed: onAdd,
        icon: const Icon(Icons.add),
        tooltip: context.l10n.addIngredient,
      ),
      child: ingredients.isEmpty
          ? Text(
              context.l10n.noIngredientsYet,
              style: theme.textTheme.bodyMedium,
            )
          : Column(
              children: [
                for (final ingredient in ingredients)
                  _IngredientCard(ingredient: ingredient),
              ],
            ),
    );
  }
}

class _RecipeSectionCard extends StatelessWidget {
  const _RecipeSectionCard({
    required this.icon,
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  child: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(subtitle!, style: theme.textTheme.bodySmall),
                      ],
                    ],
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: 14),
            child,
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

  String get priceCurrency {
    final value = ingredient[AppRecipeIngredientFields.priceCurrency]
        ?.toString()
        .trim();

    if (value == null || value.isEmpty) {
      return 'EUR';
    }

    return value;
  }

  double? get estimatedUnitPrice {
    return doubleOrNull(
      ingredient[AppRecipeIngredientFields.estimatedUnitPrice],
    );
  }

  double? get estimatedTotalPrice {
    final explicitTotal = doubleOrNull(
      ingredient[AppRecipeIngredientFields.estimatedTotalPrice],
    );

    if (explicitTotal != null) {
      return explicitTotal;
    }

    final unitPrice = estimatedUnitPrice;

    if (unitPrice == null) {
      return null;
    }

    final quantity = doubleOrNull(
      ingredient[AppRecipeIngredientFields.quantity],
    );

    if (quantity == null) {
      return unitPrice;
    }

    return unitPrice * quantity;
  }

  double? doubleOrNull(dynamic value) {
    if (value == null) return null;

    if (value is num) return value.toDouble();

    return double.tryParse(value.toString().replaceAll(',', '.'));
  }

  String? priceText() {
    final unitPrice = estimatedUnitPrice;
    final totalPrice = estimatedTotalPrice;

    if (unitPrice == null && totalPrice == null) {
      return null;
    }

    if (unitPrice != null && totalPrice != null) {
      return '${totalPrice.toStringAsFixed(2)} $priceCurrency total · '
          '${unitPrice.toStringAsFixed(2)} $priceCurrency each';
    }

    if (totalPrice != null) {
      return '${totalPrice.toStringAsFixed(2)} $priceCurrency total';
    }

    return '${unitPrice!.toStringAsFixed(2)} $priceCurrency each';
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

    final parts = <String>[amountText(context)];

    final price = priceText();

    if (price != null) {
      parts.add(price);
    }

    if (note != null) {
      parts.add(note!);
    }

    final subtitle = parts.join(' • ');

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
        subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: PopupMenuButton<_IngredientAction>(
          onSelected: (action) {
            switch (action) {
              case _IngredientAction.edit:
                editIngredient(context);
                break;
              case _IngredientAction.delete:
                deleteIngredient(context);
                break;
            }
          },
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                value: _IngredientAction.edit,
                child: Row(
                  children: [
                    const Icon(Icons.edit_outlined),
                    const SizedBox(width: 8),
                    Text(context.l10n.editIngredient),
                  ],
                ),
              ),
              PopupMenuItem(
                value: _IngredientAction.delete,
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline),
                    const SizedBox(width: 8),
                    Text(context.l10n.deleteIngredient),
                  ],
                ),
              ),
            ];
          },
        ),
      ),
    );
  }
}

enum _IngredientAction { edit, delete }

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
