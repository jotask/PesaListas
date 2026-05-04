import 'package:flutter/material.dart';
import 'package:pesalistas/core/recipe_fields.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';

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
  final TextEditingController noteController = TextEditingController();
  final TextEditingController recipeSearchController = TextEditingController();

  DateTime plannedFor = DateTime.now();
  String mealType = AppMealTypes.dinner;
  String? selectedRecipeId;
  String recipeSearchQuery = '';

  @override
  void dispose() {
    noteController.dispose();
    recipeSearchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredRecipes {
    final query = recipeSearchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return widget.recipes;
    }

    return widget.recipes.where((recipe) {
      final name = recipe[AppRecipeFields.name]?.toString().toLowerCase() ?? '';
      final description =
          recipe[AppRecipeFields.description]?.toString().toLowerCase() ?? '';

      return name.contains(query) || description.contains(query);
    }).toList();
  }

  String recipeName(BuildContext context, Map<String, dynamic> recipe) {
    final value = recipe[AppRecipeFields.name]?.toString();

    if (value == null || value.trim().isEmpty) {
      return context.l10n.untitledRecipe;
    }

    return value.trim();
  }

  String? recipeDescription(Map<String, dynamic> recipe) {
    final value = recipe[AppRecipeFields.description]?.toString();

    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return value.trim();
  }

  String formatDate(BuildContext context, DateTime date) {
    return MaterialLocalizations.of(context).formatCompactDate(date);
  }

  Future<void> pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: plannedFor,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );

    if (pickedDate == null) return;

    setState(() => plannedFor = pickedDate);
  }

  void updateRecipeSearch(String value) {
    setState(() => recipeSearchQuery = value);
  }

  void clearRecipeSearch() {
    recipeSearchController.clear();
    setState(() => recipeSearchQuery = '');
  }

  void submit() {
    final note = noteController.text.trim();

    Navigator.of(context).pop(
      AddMealPlanDialogResult(
        plannedFor: plannedFor,
        mealType: mealType,
        recipeId: selectedRecipeId,
        note: note.isEmpty ? null : note,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipes = filteredRecipes;

    return AlertDialog(
      title: Text(context.l10n.addMealPlan),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  child: Icon(Icons.calendar_month_outlined),
                ),
                title: Text(context.l10n.mealPlan),
                subtitle: Text(
                  context.l10n.planAMealForADateAndOptionallyChooseARecipe,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: pickDate,
                icon: const Icon(Icons.event_outlined),
                label: Text(formatDate(context, plannedFor)),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: mealType,
                decoration: InputDecoration(labelText: context.l10n.mealType),
                items: AppMealTypes.all.map((config) {
                  return DropdownMenuItem(
                    value: config.value,
                    child: Row(
                      children: [
                        Icon(config.icon, size: 18),
                        const SizedBox(width: 8),
                        Text(config.label(context)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() => mealType = value);
                },
              ),
              const SizedBox(height: 12),
              _RecipePicker(
                recipes: recipes,
                allRecipesEmpty: widget.recipes.isEmpty,
                selectedRecipeId: selectedRecipeId,
                searchController: recipeSearchController,
                searchQuery: recipeSearchQuery,
                recipeName: (recipe) => recipeName(context, recipe),
                recipeDescription: recipeDescription,
                onSearchChanged: updateRecipeSearch,
                onClearSearch: clearRecipeSearch,
                onSelectedRecipe: (recipeId) {
                  setState(() => selectedRecipeId = recipeId);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: context.l10n.note,
                  hintText: context.l10n.optionalEGFamilyDinnerOrLeftovers,
                ),
                minLines: 2,
                maxLines: 4,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
        ElevatedButton(onPressed: submit, child: Text(context.l10n.add)),
      ],
    );
  }
}

class _RecipePicker extends StatelessWidget {
  const _RecipePicker({
    required this.recipes,
    required this.allRecipesEmpty,
    required this.selectedRecipeId,
    required this.searchController,
    required this.searchQuery,
    required this.recipeName,
    required this.recipeDescription,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onSelectedRecipe,
  });

  final List<Map<String, dynamic>> recipes;
  final bool allRecipesEmpty;
  final String? selectedRecipeId;
  final TextEditingController searchController;
  final String searchQuery;
  final String Function(Map<String, dynamic> recipe) recipeName;
  final String? Function(Map<String, dynamic> recipe) recipeDescription;
  final void Function(String value) onSearchChanged;
  final VoidCallback onClearSearch;
  final void Function(String? recipeId) onSelectedRecipe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InputDecorator(
      decoration: InputDecoration(
        labelText: context.l10n.recipe,
        helperText: context.l10n.optionalYouCanAlsoCreateACustomMealNote,
      ),
      child: Column(
        children: [
          RadioListTile<String?>(
            value: null,
            groupValue: selectedRecipeId,
            contentPadding: EdgeInsets.zero,
            title: Text(context.l10n.noRecipeCustomMeal),
            onChanged: onSelectedRecipe,
          ),
          const Divider(height: 1),
          const SizedBox(height: 10),
          SearchBar(
            controller: searchController,
            leading: const Icon(Icons.search),
            hintText: context.l10n.searchRecipesHint,
            onChanged: onSearchChanged,
            trailing: [
              if (searchQuery.isNotEmpty)
                IconButton(
                  onPressed: onClearSearch,
                  icon: const Icon(Icons.close),
                  tooltip: context.l10n.clearFilter,
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (allRecipesEmpty)
            _RecipePickerEmptyMessage(
              icon: Icons.restaurant_menu_outlined,
              title: context.l10n.noRecipesYet,
              subtitle: context.l10n.addYourFirstRecipe,
            )
          else if (recipes.isEmpty)
            _RecipePickerEmptyMessage(
              icon: Icons.search_off_outlined,
              title: context.l10n.noRecipeResults,
              subtitle: context.l10n.noRecipeResultsSubtitle,
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: recipes.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final recipe = recipes[index];
                  final recipeId = recipe[AppRecipeFields.id]?.toString();
                  final description = recipeDescription(recipe);

                  return RadioListTile<String?>(
                    value: recipeId,
                    groupValue: selectedRecipeId,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      recipeName(recipe),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: description == null
                        ? null
                        : Text(
                            description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                    onChanged: onSelectedRecipe,
                  );
                },
              ),
            ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              selectedRecipeId == null
                  ? context.l10n.noRecipeCustomMeal
                  : context.l10n.recipe,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipePickerEmptyMessage extends StatelessWidget {
  const _RecipePickerEmptyMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppMealTypeConfig {
  const AppMealTypeConfig({
    required this.value,
    required this.labelKey,
    required this.icon,
  });

  final String value;
  final String labelKey;
  final IconData icon;

  String label(BuildContext context) {
    switch (labelKey) {
      case 'breakfast':
        return context.l10n.breakfast;
      case 'lunch':
        return context.l10n.lunch;
      case 'dinner':
        return context.l10n.dinner;
      case 'snack':
        return context.l10n.snack;
      default:
        return context.l10n.dinner;
    }
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
      labelKey: 'breakfast',
      icon: Icons.free_breakfast_outlined,
    ),
    AppMealTypeConfig(
      value: lunch,
      labelKey: 'lunch',
      icon: Icons.lunch_dining_outlined,
    ),
    AppMealTypeConfig(
      value: dinner,
      labelKey: 'dinner',
      icon: Icons.dinner_dining_outlined,
    ),
    AppMealTypeConfig(
      value: snack,
      labelKey: 'snack',
      icon: Icons.cookie_outlined,
    ),
  ];

  static AppMealTypeConfig fromValue(String? value) {
    for (final config in all) {
      if (config.value == value) return config;
    }

    return all.firstWhere((config) => config.value == dinner);
  }
}
