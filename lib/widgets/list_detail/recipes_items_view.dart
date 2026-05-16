import 'package:flutter/material.dart';
import 'package:pesalistas/core/fields/recipe_fields.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/widgets/list_detail/empty_items_card.dart';

class RecipesItemsView extends StatefulWidget {
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
  State<RecipesItemsView> createState() => _RecipesItemsViewState();
}

class _RecipesItemsViewState extends State<RecipesItemsView> {
  final TextEditingController searchController = TextEditingController();

  String searchQuery = '';
  RecipeFilter selectedFilter = RecipeFilter.all;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get visibleRecipes {
    return widget.recipes.where((recipe) {
      return matchesSearch(recipe) && matchesFilter(recipe);
    }).toList();
  }

  bool matchesSearch(Map<String, dynamic> recipe) {
    final query = searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return true;
    }

    final name = recipe[AppRecipeFields.name]?.toString().toLowerCase() ?? '';
    final description =
        recipe[AppRecipeFields.description]?.toString().toLowerCase() ?? '';
    final instructions =
        recipe[AppRecipeFields.instructions]?.toString().toLowerCase() ?? '';

    return name.contains(query) ||
        description.contains(query) ||
        instructions.contains(query);
  }

  bool matchesFilter(Map<String, dynamic> recipe) {
    switch (selectedFilter) {
      case RecipeFilter.all:
        return true;

      case RecipeFilter.withInstructions:
        return hasInstructions(recipe);

      case RecipeFilter.missingInstructions:
        return !hasInstructions(recipe);

      case RecipeFilter.withTiming:
        return hasTiming(recipe);
    }
  }

  bool hasInstructions(Map<String, dynamic> recipe) {
    final value = recipe[AppRecipeFields.instructions]?.toString();
    return value != null && value.trim().isNotEmpty;
  }

  bool hasTiming(Map<String, dynamic> recipe) {
    return intValue(recipe[AppRecipeFields.prepTimeMinutes]) != null ||
        intValue(recipe[AppRecipeFields.cookTimeMinutes]) != null;
  }

  int? intValue(dynamic value) {
    if (value is int) return value;

    return int.tryParse(value?.toString() ?? '');
  }

  int get withInstructionsCount {
    return widget.recipes.where(hasInstructions).length;
  }

  int get missingInstructionsCount {
    return widget.recipes.where((recipe) => !hasInstructions(recipe)).length;
  }

  int get withTimingCount {
    return widget.recipes.where(hasTiming).length;
  }

  void updateSearch(String value) {
    setState(() => searchQuery = value);
  }

  void clearSearch() {
    searchController.clear();
    setState(() => searchQuery = '');
  }

  void selectFilter(RecipeFilter filter) {
    setState(() => selectedFilter = filter);
  }

  void resetFilters() {
    searchController.clear();
    setState(() {
      searchQuery = '';
      selectedFilter = RecipeFilter.all;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.recipes.isEmpty) {
      return EmptyItemsCard(
        icon: Icons.restaurant_menu_outlined,
        title: context.l10n.noRecipesYet,
        subtitle: context.l10n.addYourFirstRecipe,
        onCreate: widget.onCreate,
      );
    }

    final recipes = visibleRecipes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RecipeSearchField(
          controller: searchController,
          query: searchQuery,
          onChanged: updateSearch,
          onClear: clearSearch,
        ),
        const SizedBox(height: 12),
        _RecipeFilterChips(
          selectedFilter: selectedFilter,
          totalCount: widget.recipes.length,
          withInstructionsCount: withInstructionsCount,
          missingInstructionsCount: missingInstructionsCount,
          withTimingCount: withTimingCount,
          onSelected: selectFilter,
        ),
        const SizedBox(height: 12),
        if (recipes.isEmpty)
          _NoRecipeResultsCard(
            hasActiveFilter:
                searchQuery.trim().isNotEmpty ||
                selectedFilter != RecipeFilter.all,
            onClear: resetFilters,
          )
        else
          for (final recipe in recipes)
            _RecipeCard(
              recipe: recipe,
              onTap: () => widget.onViewRecipeDetails(recipe),
              onDelete: () {
                widget.onDeleteRecipe(recipe[AppRecipeFields.id].toString());
              },
            ),
      ],
    );
  }
}

enum RecipeFilter { all, withInstructions, missingInstructions, withTiming }

class _RecipeSearchField extends StatelessWidget {
  const _RecipeSearchField({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String query;
  final void Function(String value) onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      controller: controller,
      leading: const Icon(Icons.search),
      hintText: context.l10n.searchRecipesHint,
      onChanged: onChanged,
      trailing: [
        if (query.isNotEmpty)
          IconButton(
            onPressed: onClear,
            icon: const Icon(Icons.close),
            tooltip: context.l10n.clearFilter,
          ),
      ],
    );
  }
}

class _RecipeFilterChips extends StatelessWidget {
  const _RecipeFilterChips({
    required this.selectedFilter,
    required this.totalCount,
    required this.withInstructionsCount,
    required this.missingInstructionsCount,
    required this.withTimingCount,
    required this.onSelected,
  });

  final RecipeFilter selectedFilter;
  final int totalCount;
  final int withInstructionsCount;
  final int missingInstructionsCount;
  final int withTimingCount;
  final void Function(RecipeFilter filter) onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          selected: selectedFilter == RecipeFilter.all,
          label: Text('${context.l10n.allRecipes} $totalCount'),
          onSelected: (_) => onSelected(RecipeFilter.all),
        ),
        FilterChip(
          selected: selectedFilter == RecipeFilter.withInstructions,
          label: Text(
            '${context.l10n.recipesWithInstructions} $withInstructionsCount',
          ),
          onSelected: (_) => onSelected(RecipeFilter.withInstructions),
        ),
        FilterChip(
          selected: selectedFilter == RecipeFilter.missingInstructions,
          label: Text(
            '${context.l10n.recipesMissingInstructions} $missingInstructionsCount',
          ),
          onSelected: (_) => onSelected(RecipeFilter.missingInstructions),
        ),
        FilterChip(
          selected: selectedFilter == RecipeFilter.withTiming,
          label: Text('${context.l10n.recipesWithTiming} $withTimingCount'),
          onSelected: (_) => onSelected(RecipeFilter.withTiming),
        ),
      ],
    );
  }
}

class _NoRecipeResultsCard extends StatelessWidget {
  const _NoRecipeResultsCard({
    required this.hasActiveFilter,
    required this.onClear,
  });

  final bool hasActiveFilter;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.search_off_outlined,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasActiveFilter
                        ? context.l10n.noRecipesForFilter
                        : context.l10n.noRecipeResults,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasActiveFilter
                        ? context.l10n.noRecipesForFilterSubtitle
                        : context.l10n.noRecipeResultsSubtitle,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: onClear,
                    icon: const Icon(Icons.clear),
                    label: Text(context.l10n.clearFilter),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({
    required this.recipe,
    required this.onTap,
    required this.onDelete,
  });

  final Map<String, dynamic> recipe;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  String title(BuildContext context) {
    final value = recipe[AppRecipeFields.name]?.toString();

    if (value == null || value.trim().isEmpty) {
      return context.l10n.untitledRecipe;
    }

    return value.trim();
  }

  String description(BuildContext context) {
    final value = recipe[AppRecipeFields.description]?.toString();

    if (value == null || value.trim().isEmpty) {
      return context.l10n.recipeDetailsAndIngredients;
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
    final value = recipe[AppRecipeFields.prepTimeMinutes];

    if (value is int) return value;

    return int.tryParse(value?.toString() ?? '');
  }

  int? get cookTime {
    final value = recipe[AppRecipeFields.cookTimeMinutes];

    if (value is int) return value;

    return int.tryParse(value?.toString() ?? '');
  }

  int? get servings {
    final value = recipe[AppRecipeFields.servings];

    if (value is int) return value;

    return int.tryParse(value?.toString() ?? '');
  }

  int? get totalTime {
    final total = (prepTime ?? 0) + (cookTime ?? 0);

    if (total <= 0) return null;

    return total;
  }

  bool get hasInstructions {
    return instructions != null;
  }

  List<String> get instructionSteps {
    final text = instructions;

    if (text == null || text.isEmpty) {
      return [];
    }

    return text
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map((line) {
          return line
              .replaceFirst(RegExp(r'^\s*(?:\d+[\.)]|[-*•])\s*'), '')
              .trim();
        })
        .where((line) => line.isNotEmpty)
        .toList();
  }

  int get instructionStepCount {
    return instructionSteps.length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
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
                      title(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description(context),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (totalTime != null)
                          _RecipeMetaPill(
                            icon: Icons.schedule,
                            label: context.l10n.minutesTotal(totalTime!),
                          ),
                        if (prepTime != null)
                          _RecipeMetaPill(
                            icon: Icons.kitchen_outlined,
                            label: context.l10n.prepMinutes(prepTime!),
                          ),
                        if (cookTime != null)
                          _RecipeMetaPill(
                            icon: Icons.local_fire_department_outlined,
                            label: context.l10n.cookMinutes(cookTime!),
                          ),
                        if (servings != null)
                          _RecipeMetaPill(
                            icon: Icons.people_outline,
                            label: context.l10n.servingsCount(servings!),
                          ),
                        _RecipeMetaPill(
                          icon: hasInstructions
                              ? Icons.format_list_numbered_outlined
                              : Icons.notes_outlined,
                          label: hasInstructions
                              ? '$instructionStepCount steps'
                              : context.l10n.noInstructions,
                          filled: hasInstructions,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onTap,
                            icon: const Icon(Icons.open_in_new),
                            label: Text(context.l10n.openRecipe),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete_outline),
                          tooltip: context.l10n.deleteRecipe,
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

class _RecipeMetaPill extends StatelessWidget {
  const _RecipeMetaPill({
    required this.icon,
    required this.label,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: filled
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: filled
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: filled
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
