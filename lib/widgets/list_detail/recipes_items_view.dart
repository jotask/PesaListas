import 'package:flutter/material.dart';
import 'package:pesalistas/core/recipe_fields.dart';
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

  String titleFor(Map<String, dynamic> recipe) {
    final value = recipe[AppRecipeFields.name]?.toString();

    if (value == null || value.trim().isEmpty) {
      return 'Untitled recipe';
    }

    return value.trim();
  }

  String subtitleFor(Map<String, dynamic> recipe) {
    final value = recipe[AppRecipeFields.description]?.toString();

    if (value == null || value.trim().isEmpty) {
      return 'Recipe details and ingredients';
    }

    return value.trim();
  }

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
            title: titleFor(recipe),
            subtitle: subtitleFor(recipe),
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
    required this.title,
    required this.subtitle,
    required this.onDetails,
    required this.onDelete,
  });

  final String title;
  final String subtitle;
  final VoidCallback onDetails;
  final VoidCallback onDelete;

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
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: onDetails,
                          icon: const Icon(Icons.menu_book_outlined),
                          label: const Text('Details'),
                        ),
                        IconButton(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Delete recipe',
                        ),
                      ],
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
