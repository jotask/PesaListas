import 'package:flutter/material.dart';
import 'package:pesalistas/core/item_fields.dart';
import 'package:pesalistas/widgets/list_detail/empty_items_card.dart';

class RecipesItemsView extends StatelessWidget {
  const RecipesItemsView({
    super.key,
    required this.items,
    required this.loading,
    required this.onCreate,
    required this.onComplete,
    required this.onEdit,
    required this.onDelete,
    required this.onViewRecipeDetails,
  });

  final List<Map<String, dynamic>> items;
  final bool loading;
  final VoidCallback onCreate;
  final void Function(String itemId) onComplete;
  final void Function(Map<String, dynamic> item) onEdit;
  final void Function(String itemId) onDelete;
  final void Function(Map<String, dynamic> item) onViewRecipeDetails;

  String titleFor(Map<String, dynamic> item) {
    final value = item[AppItemFields.title]?.toString();

    if (value == null || value.trim().isEmpty) {
      return 'Untitled recipe';
    }

    return value.trim();
  }

  String subtitleFor(Map<String, dynamic> item) {
    final value = item[AppItemFields.description]?.toString();

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

    if (items.isEmpty) {
      return EmptyItemsCard(
        icon: Icons.restaurant_menu,
        title: 'No recipes yet',
        subtitle: 'Add your first recipe.',
        onCreate: onCreate,
      );
    }

    return Column(
      children: [
        for (final item in items)
          _RecipeItemCard(
            title: titleFor(item),
            subtitle: subtitleFor(item),
            onDetails: () => onViewRecipeDetails(item),
            onEdit: () => onEdit(item),
            onDelete: () => onDelete(item[AppItemFields.id].toString()),
          ),
      ],
    );
  }
}

class _RecipeItemCard extends StatelessWidget {
  const _RecipeItemCard({
    required this.title,
    required this.subtitle,
    required this.onDetails,
    required this.onEdit,
    required this.onDelete,
  });

  final String title;
  final String subtitle;
  final VoidCallback onDetails;
  final VoidCallback onEdit;
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
                        OutlinedButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit'),
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
