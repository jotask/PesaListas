import 'package:flutter/material.dart';
import 'package:pesalistas/core/meal_plan_fields.dart';
import 'package:pesalistas/core/meal_types.dart';
import 'package:pesalistas/core/recipe_fields.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';

class MealPlanFormPageResult {
  const MealPlanFormPageResult({
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

class MealPlanFormPage extends StatefulWidget {
  const MealPlanFormPage({super.key, required this.recipes, this.mealPlan});

  final List<Map<String, dynamic>> recipes;
  final Map<String, dynamic>? mealPlan;

  @override
  State<MealPlanFormPage> createState() => _MealPlanFormPageState();
}

class _MealPlanFormPageState extends State<MealPlanFormPage> {
  final TextEditingController noteController = TextEditingController();
  final TextEditingController recipeSearchController = TextEditingController();

  late DateTime plannedFor;
  late String mealType;
  String? selectedRecipeId;
  String recipeSearchQuery = '';

  bool get isEditing => widget.mealPlan != null;

  @override
  void initState() {
    super.initState();

    plannedFor = initialPlannedFor();
    mealType = initialMealType();
    selectedRecipeId = initialRecipeId();

    noteController.text =
        widget.mealPlan?[AppMealPlanFields.note]?.toString() ?? '';
  }

  @override
  void dispose() {
    noteController.dispose();
    recipeSearchController.dispose();
    super.dispose();
  }

  DateTime initialPlannedFor() {
    final value = widget.mealPlan?[AppMealPlanFields.plannedFor]?.toString();
    final parsed = DateTime.tryParse(value?.split('T').first ?? '');

    if (parsed == null) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day);
    }

    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  String initialMealType() {
    final value = widget.mealPlan?[AppMealPlanFields.mealType]?.toString();

    if (value == null || value.trim().isEmpty) {
      return AppMealTypes.dinner;
    }

    return value.trim();
  }

  String? initialRecipeId() {
    final value = widget.mealPlan?[AppMealPlanFields.recipeId]?.toString();

    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return value.trim();
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
      MealPlanFormPageResult(
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? context.l10n.editMealPlan : context.l10n.addMealPlan,
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(context.l10n.cancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: submit,
                  child: Text(isEditing ? context.l10n.save : context.l10n.add),
                ),
              ),
            ],
          ),
        ),
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
                        Icons.calendar_month_outlined,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.mealPlan,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isEditing
                                ? context.l10n.updateDateMealTypeRecipeOrNote
                                : context
                                      .l10n
                                      .planAMealForADateAndOptionallyChooseARecipe,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.event_outlined),
                      title: Text(formatDate(context, plannedFor)),
                      subtitle: Text(context.l10n.mealPlan),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: pickDate,
                    ),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: mealType,
                      decoration: InputDecoration(
                        labelText: context.l10n.mealType,
                        prefixIcon: const Icon(Icons.restaurant_menu_outlined),
                      ),
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _RecipePickerCard(
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
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: TextField(
                  controller: noteController,
                  decoration: InputDecoration(
                    labelText: context.l10n.note,
                    hintText: isEditing
                        ? context.l10n.optional
                        : context.l10n.optionalEGFamilyDinnerOrLeftovers,
                    prefixIcon: const Icon(Icons.notes_outlined),
                  ),
                  minLines: 3,
                  maxLines: 6,
                  textInputAction: TextInputAction.newline,
                ),
              ),
            ),
            const SizedBox(height: 96),
          ],
        ),
      ),
    );
  }
}

class _RecipePickerCard extends StatelessWidget {
  const _RecipePickerCard({
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

  static const noRecipeValue = '__no_recipe__';

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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: RadioGroup<String>(
          groupValue: selectedRecipeId ?? noRecipeValue,
          onChanged: (value) {
            if (value == null) return;

            onSelectedRecipe(value == noRecipeValue ? null : value);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.recipe,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.optionalYouCanAlsoCreateACustomMealNote,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              RadioListTile<String>(
                value: noRecipeValue,
                contentPadding: EdgeInsets.zero,
                title: Text(context.l10n.noRecipeCustomMeal),
              ),
              const Divider(height: 1),
              const SizedBox(height: 12),
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
              const SizedBox(height: 12),
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
                for (final recipe in recipes)
                  _RecipeRadioTile(
                    recipe: recipe,
                    recipeName: recipeName,
                    recipeDescription: recipeDescription,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipeRadioTile extends StatelessWidget {
  const _RecipeRadioTile({
    required this.recipe,
    required this.recipeName,
    required this.recipeDescription,
  });

  final Map<String, dynamic> recipe;
  final String Function(Map<String, dynamic> recipe) recipeName;
  final String? Function(Map<String, dynamic> recipe) recipeDescription;

  @override
  Widget build(BuildContext context) {
    final recipeId = recipe[AppRecipeFields.id]?.toString() ?? '';
    final description = recipeDescription(recipe);

    return RadioListTile<String>(
      value: recipeId,
      contentPadding: EdgeInsets.zero,
      title: Text(
        recipeName(recipe),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: description == null
          ? null
          : Text(description, maxLines: 2, overflow: TextOverflow.ellipsis),
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
