import 'package:flutter/material.dart';
import 'package:pesalistas/core/recipe_fields.dart';
import 'package:pesalistas/core/value_parsing.dart';
import 'package:pesalistas/widgets/list_detail/empty_items_card.dart';

class RecipesItemsView extends StatelessWidget {
  const RecipesItemsView({
    super.key,
    required this.recipes,
    required this.loading,
    required this.onCreate,
    required this.onViewRecipeDetails,
    required this.onDeleteRecipe,
  });

  final List<Map<String, dynamic>> recipes;
  final bool loading;
  final VoidCallback onCreate;
  final void Function(Map<String, dynamic> recipe) onViewRecipeDetails;
  final void Function(String recipeId) onDeleteRecipe;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (recipes.isEmpty) {
      return EmptyItemsCard(
        icon: Icons.restaurant_menu,
        title: 'No recipes yet',
        subtitle: 'Add your first recipe.',
        onCreate: onCreate,
      );
    }

    return Column(
      children: [
        for (final recipe in recipes)
          _RecipeCard(
            recipe: recipe,
            onDetails: () => onViewRecipeDetails(recipe),
            onDelete: () =>
                onDeleteRecipe(recipe[AppRecipeFields.id].toString()),
          ),
      ],
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({
    required this.recipe,
    required this.onDetails,
    required this.onDelete,
  });

  final Map<String, dynamic> recipe;
  final VoidCallback onDetails;
  final VoidCallback onDelete;

  String get title {
    final value = recipe[AppRecipeFields.name]?.toString();

    if (value == null || value.trim().isEmpty) {
      return 'Untitled recipe';
    }

    return value.trim();
  }

  String get description {
    final value = recipe[AppRecipeFields.description]?.toString();

    if (value == null || value.trim().isEmpty) {
      return 'Recipe details and ingredients';
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

  bool get hasInstructions {
    return instructions != null;
  }

  int? get totalTime {
    final prep = prepTime ?? 0;
    final cook = cookTime ?? 0;

    if (prep == 0 && cook == 0) {
      return null;
    }

    return prep + cook;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onDetails,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.restaurant_menu,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Delete recipe',
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (totalTime != null)
                          _RecipeMetaPill(
                            icon: Icons.schedule_outlined,
                            label: '$totalTime min total',
                          ),
                        if (prepTime != null)
                          _RecipeMetaPill(
                            icon: Icons.timer_outlined,
                            label: 'Prep $prepTime min',
                          ),
                        if (cookTime != null)
                          _RecipeMetaPill(
                            icon: Icons.local_fire_department_outlined,
                            label: 'Cook $cookTime min',
                          ),
                        if (servings != null)
                          _RecipeMetaPill(
                            icon: Icons.people_outline,
                            label: '$servings servings',
                          ),
                        _RecipeMetaPill(
                          icon: hasInstructions
                              ? Icons.menu_book_outlined
                              : Icons.menu_book_outlined,
                          label: hasInstructions
                              ? 'Instructions added'
                              : 'No instructions',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton.icon(
                        onPressed: onDetails,
                        icon: const Icon(Icons.menu_book_outlined),
                        label: const Text('Open recipe'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipeMetaPill extends StatelessWidget {
  const _RecipeMetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
