import 'package:flutter/material.dart';
import 'package:pesalistas/core/item_fields.dart';
import 'package:pesalistas/core/recipe_fields.dart';
import 'package:pesalistas/core/value_parsing.dart';

class RecipeDetailsDialog extends StatelessWidget {
  const RecipeDetailsDialog({
    super.key,
    required this.item,
    required this.recipe,
  });

  final Map<String, dynamic> item;
  final Map<String, dynamic>? recipe;

  String get title {
    final value = item[AppItemFields.title]?.toString();

    if (value == null || value.trim().isEmpty) {
      return 'Untitled recipe';
    }

    return value.trim();
  }

  String? get description {
    final value = item[AppItemFields.description]?.toString();

    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return value.trim();
  }

  String? get instructions {
    final value = recipe?[AppRecipeFields.instructions]?.toString();

    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return value.trim();
  }

  int? get prepTime {
    return AppValueParsing.intOrNull(recipe?[AppRecipeFields.prepTimeMinutes]);
  }

  int? get cookTime {
    return AppValueParsing.intOrNull(recipe?[AppRecipeFields.cookTimeMinutes]);
  }

  int? get servings {
    return AppValueParsing.intOrNull(recipe?[AppRecipeFields.servings]);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (description != null) ...[
                Text(description!),
                const SizedBox(height: 16),
              ],
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _RecipeInfoChip(
                    icon: Icons.timer_outlined,
                    label: prepTime == null
                        ? 'Prep not set'
                        : 'Prep $prepTime min',
                  ),
                  _RecipeInfoChip(
                    icon: Icons.local_fire_department_outlined,
                    label: cookTime == null
                        ? 'Cook not set'
                        : 'Cook $cookTime min',
                  ),
                  _RecipeInfoChip(
                    icon: Icons.people_outline,
                    label: servings == null
                        ? 'Servings not set'
                        : '$servings servings',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Instructions',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(instructions ?? 'No instructions yet.'),
              const SizedBox(height: 18),
              const Text(
                'Ingredients',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text('Ingredient editing will be added in the next step.'),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
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
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
