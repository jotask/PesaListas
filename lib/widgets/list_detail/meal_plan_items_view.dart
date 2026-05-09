import 'package:flutter/material.dart';
import 'package:pesalistas/core/meal_plan_cost_fields.dart';
import 'package:pesalistas/core/meal_plan_fields.dart';
import 'package:pesalistas/core/recipe_fields.dart';
import 'package:pesalistas/core/meal_types.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/widgets/list_detail/empty_items_card.dart';

class MealPlanItemsView extends StatefulWidget {
  const MealPlanItemsView({
    super.key,
    required this.mealPlans,
    required this.loading,
    required this.onCreate,
    required this.onEdit,
    required this.onDelete,
    required this.onGenerateShopping,
  });

  final List<Map<String, dynamic>> mealPlans;
  final bool loading;
  final VoidCallback onCreate;
  final void Function(Map<String, dynamic> mealPlan) onEdit;
  final void Function(String mealPlanId) onDelete;
  final VoidCallback onGenerateShopping;

  @override
  State<MealPlanItemsView> createState() => _MealPlanItemsViewState();
}

class _MealPlanItemsViewState extends State<MealPlanItemsView> {
  MealPlanFilter selectedFilter = MealPlanFilter.all;
  String? selectedMealType;

  DateTime get today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime get weekEnd {
    return today.add(const Duration(days: 6));
  }

  DateTime? plannedDateFor(Map<String, dynamic> mealPlan) {
    final value = mealPlan[AppMealPlanFields.plannedFor]?.toString();

    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final parsed = DateTime.tryParse(value.split('T').first);

    if (parsed == null) {
      return null;
    }

    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  String mealTypeFor(Map<String, dynamic> mealPlan) {
    final value = mealPlan[AppMealPlanFields.mealType]?.toString();

    if (value == null || value.trim().isEmpty) {
      return AppMealTypes.dinner;
    }

    return value.trim();
  }

  bool isUpcoming(Map<String, dynamic> mealPlan) {
    final date = plannedDateFor(mealPlan);

    if (date == null) return false;

    return !date.isBefore(today);
  }

  bool isThisWeek(Map<String, dynamic> mealPlan) {
    final date = plannedDateFor(mealPlan);

    if (date == null) return false;

    return !date.isBefore(today) && !date.isAfter(weekEnd);
  }

  bool isPast(Map<String, dynamic> mealPlan) {
    final date = plannedDateFor(mealPlan);

    if (date == null) return false;

    return date.isBefore(today);
  }

  bool matchesDateFilter(Map<String, dynamic> mealPlan) {
    switch (selectedFilter) {
      case MealPlanFilter.all:
        return true;

      case MealPlanFilter.upcoming:
        return isUpcoming(mealPlan);

      case MealPlanFilter.thisWeek:
        return isThisWeek(mealPlan);

      case MealPlanFilter.past:
        return isPast(mealPlan);
    }
  }

  bool matchesMealTypeFilter(Map<String, dynamic> mealPlan) {
    final filter = selectedMealType;

    if (filter == null) {
      return true;
    }

    return mealTypeFor(mealPlan) == filter;
  }

  List<Map<String, dynamic>> get filteredMealPlans {
    return widget.mealPlans.where((mealPlan) {
      return matchesDateFilter(mealPlan) && matchesMealTypeFilter(mealPlan);
    }).toList();
  }

  int get upcomingCount {
    return widget.mealPlans.where(isUpcoming).length;
  }

  int get thisWeekCount {
    return widget.mealPlans.where(isThisWeek).length;
  }

  int get pastCount {
    return widget.mealPlans.where(isPast).length;
  }

  int get recipeMealCount {
    return widget.mealPlans.where((mealPlan) {
      final recipeId = mealPlan[AppMealPlanFields.recipeId]?.toString();
      return recipeId != null && recipeId.isNotEmpty;
    }).length;
  }

  bool get hasEstimatedCosts {
    return widget.mealPlans.any(mealPlanHasEstimatedCost);
  }

  double get totalEstimatedCost {
    return widget.mealPlans.fold<double>(0, (total, mealPlan) {
      return total + (mealPlanEstimatedCost(mealPlan) ?? 0);
    });
  }

  String get priceCurrency {
    for (final mealPlan in widget.mealPlans) {
      final value = mealPlan[AppMealPlanCostFields.priceCurrency]?.toString();

      if (value != null && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return 'EUR';
  }

  bool mealPlanHasEstimatedCost(Map<String, dynamic> mealPlan) {
    return mealPlan[AppMealPlanCostFields.hasEstimatedCost] == true;
  }

  double? mealPlanEstimatedCost(Map<String, dynamic> mealPlan) {
    final value = mealPlan[AppMealPlanCostFields.estimatedCost];

    if (value == null) return null;

    if (value is num) return value.toDouble();

    return double.tryParse(value.toString().replaceAll(',', '.'));
  }

  int countForMealType(String mealType) {
    return widget.mealPlans.where((mealPlan) {
      return mealTypeFor(mealPlan) == mealType;
    }).length;
  }

  bool get hasActiveFilters {
    return selectedFilter != MealPlanFilter.all || selectedMealType != null;
  }

  Map<String, List<Map<String, dynamic>>> groupByDate(
    List<Map<String, dynamic>> mealPlans,
  ) {
    final grouped = <String, List<Map<String, dynamic>>>{};

    for (final mealPlan in mealPlans) {
      final date = mealPlan[AppMealPlanFields.plannedFor]?.toString();
      final key = date == null || date.trim().isEmpty
          ? context.l10n.noDate
          : date.split('T').first;

      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(mealPlan);
    }

    return grouped;
  }

  String emptyTitleForFilter() {
    if (hasActiveFilters) {
      return context.l10n.noMealsForFilters;
    }

    switch (selectedFilter) {
      case MealPlanFilter.all:
        return context.l10n.noMealPlansYet;

      case MealPlanFilter.upcoming:
        return context.l10n.noUpcomingMeals;

      case MealPlanFilter.thisWeek:
        return context.l10n.noMealsThisWeek;

      case MealPlanFilter.past:
        return context.l10n.noPastMeals;
    }
  }

  String emptySubtitleForFilter() {
    if (hasActiveFilters) {
      return context.l10n.noMealsForFiltersSubtitle;
    }

    switch (selectedFilter) {
      case MealPlanFilter.all:
        return context.l10n.planYourFirstMeal;

      case MealPlanFilter.upcoming:
        return context.l10n.planAMealForTodayOrLater;

      case MealPlanFilter.thisWeek:
        return context.l10n.nothingPlannedForTheNext7Days;

      case MealPlanFilter.past:
        return context.l10n.pastMealsWillAppearHere;
    }
  }

  void selectDateFilter(MealPlanFilter filter) {
    setState(() => selectedFilter = filter);
  }

  void selectMealType(String? mealType) {
    setState(() => selectedMealType = mealType);
  }

  void clearFilters() {
    setState(() {
      selectedFilter = MealPlanFilter.all;
      selectedMealType = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final visibleMealPlans = filteredMealPlans;
    final groupedMealPlans = groupByDate(visibleMealPlans);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GenerateShoppingCard(onGenerateShopping: widget.onGenerateShopping),
        const SizedBox(height: 12),
        if (widget.mealPlans.isNotEmpty) ...[
          _MealPlanSummaryCard(
            totalCount: widget.mealPlans.length,
            upcomingCount: upcomingCount,
            thisWeekCount: thisWeekCount,
            pastCount: pastCount,
            recipeMealCount: recipeMealCount,
            hasEstimatedCosts: hasEstimatedCosts,
            totalEstimatedCost: totalEstimatedCost,
            currency: priceCurrency,
          ),
          const SizedBox(height: 12),
          _MealPlanFilterChips(
            selectedFilter: selectedFilter,
            totalCount: widget.mealPlans.length,
            upcomingCount: upcomingCount,
            thisWeekCount: thisWeekCount,
            pastCount: pastCount,
            onSelected: selectDateFilter,
          ),
          const SizedBox(height: 8),
          _MealTypeFilterChips(
            selectedMealType: selectedMealType,
            totalCount: widget.mealPlans.length,
            countForMealType: countForMealType,
            onSelected: selectMealType,
          ),
          const SizedBox(height: 12),
        ],
        if (visibleMealPlans.isEmpty)
          EmptyItemsCard(
            icon: Icons.event_note_outlined,
            title: emptyTitleForFilter(),
            subtitle: emptySubtitleForFilter(),
            onCreate: hasActiveFilters ? clearFilters : widget.onCreate,
          )
        else
          for (final entry in groupedMealPlans.entries)
            _MealPlanDateSection(
              dateLabel: entry.key,
              mealPlans: entry.value,
              onEdit: widget.onEdit,
              onDelete: widget.onDelete,
            ),
      ],
    );
  }
}

enum MealPlanFilter { all, upcoming, thisWeek, past }

class _MealPlanFilterChips extends StatelessWidget {
  const _MealPlanFilterChips({
    required this.selectedFilter,
    required this.totalCount,
    required this.upcomingCount,
    required this.thisWeekCount,
    required this.pastCount,
    required this.onSelected,
  });

  final MealPlanFilter selectedFilter;
  final int totalCount;
  final int upcomingCount;
  final int thisWeekCount;
  final int pastCount;
  final void Function(MealPlanFilter filter) onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          selected: selectedFilter == MealPlanFilter.all,
          label: Text(context.l10n.allCount(totalCount)),
          onSelected: (_) => onSelected(MealPlanFilter.all),
        ),
        FilterChip(
          selected: selectedFilter == MealPlanFilter.upcoming,
          label: Text(context.l10n.upcomingCount(upcomingCount)),
          onSelected: (_) => onSelected(MealPlanFilter.upcoming),
        ),
        FilterChip(
          selected: selectedFilter == MealPlanFilter.thisWeek,
          label: Text(context.l10n.thisWeekCount(thisWeekCount)),
          onSelected: (_) => onSelected(MealPlanFilter.thisWeek),
        ),
        FilterChip(
          selected: selectedFilter == MealPlanFilter.past,
          label: Text(context.l10n.pastCount(pastCount)),
          onSelected: (_) => onSelected(MealPlanFilter.past),
        ),
      ],
    );
  }
}

class _MealTypeFilterChips extends StatelessWidget {
  const _MealTypeFilterChips({
    required this.selectedMealType,
    required this.totalCount,
    required this.countForMealType,
    required this.onSelected,
  });

  final String? selectedMealType;
  final int totalCount;
  final int Function(String mealType) countForMealType;
  final void Function(String? mealType) onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          selected: selectedMealType == null,
          label: Text('${context.l10n.allMeals} $totalCount'),
          onSelected: (_) => onSelected(null),
        ),
        for (final config in AppMealTypes.all)
          FilterChip(
            selected: selectedMealType == config.value,
            avatar: Icon(config.icon, size: 16),
            label: Text(
              '${config.label(context)} ${countForMealType(config.value)}',
            ),
            onSelected: (_) => onSelected(config.value),
          ),
      ],
    );
  }
}

class _MealPlanSummaryCard extends StatelessWidget {
  const _MealPlanSummaryCard({
    required this.totalCount,
    required this.upcomingCount,
    required this.thisWeekCount,
    required this.pastCount,
    required this.recipeMealCount,
    required this.hasEstimatedCosts,
    required this.totalEstimatedCost,
    required this.currency,
  });

  final int totalCount;
  final int upcomingCount;
  final int thisWeekCount;
  final int pastCount;
  final int recipeMealCount;
  final bool hasEstimatedCosts;
  final double totalEstimatedCost;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.calendar_month_outlined,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _SummaryPill(
                    label: context.l10n.thisWeekSummary(thisWeekCount),
                    icon: Icons.today_outlined,
                  ),
                  _SummaryPill(
                    label: context.l10n.upcomingSummary(upcomingCount),
                    icon: Icons.event_available_outlined,
                  ),
                  _SummaryPill(
                    label: context.l10n.withRecipesSummary(recipeMealCount),
                    icon: Icons.restaurant_menu,
                  ),
                  _SummaryPill(
                    label: context.l10n.totalCountSummary(totalCount),
                    icon: Icons.list_alt_outlined,
                  ),
                  if (hasEstimatedCosts)
                    _SummaryPill(
                      label:
                          'Est. ${totalEstimatedCost.toStringAsFixed(2)} $currency',
                      icon: Icons.euro_outlined,
                    ),
                  if (pastCount > 0)
                    _SummaryPill(
                      label: context.l10n.pastSummary(pastCount),
                      icon: Icons.history,
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

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({required this.label, required this.icon});

  final String label;
  final IconData icon;

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

class _GenerateShoppingCard extends StatelessWidget {
  const _GenerateShoppingCard({required this.onGenerateShopping});

  final VoidCallback onGenerateShopping;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onGenerateShopping,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.secondaryContainer,
                child: Icon(
                  Icons.auto_awesome_outlined,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.generateShoppingList,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(context.l10n.addIngredientsFromPlannedRecipeMeals),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: onGenerateShopping,
                icon: const Icon(Icons.shopping_cart_outlined),
                label: Text(context.l10n.generate),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MealPlanDateSection extends StatelessWidget {
  const _MealPlanDateSection({
    required this.dateLabel,
    required this.mealPlans,
    required this.onEdit,
    required this.onDelete,
  });

  final String dateLabel;
  final List<Map<String, dynamic>> mealPlans;
  final void Function(Map<String, dynamic> mealPlan) onEdit;
  final void Function(String mealPlanId) onDelete;

  DateTime? get parsedDate {
    final parsed = DateTime.tryParse(dateLabel);

    if (parsed == null) return null;

    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  String friendlyDateLabel(BuildContext context) {
    final date = parsedDate;

    if (date == null) return dateLabel;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) return context.l10n.today;
    if (date == tomorrow) return context.l10n.tomorrow;
    if (date == yesterday) return context.l10n.yesterday;

    return dateLabel;
  }

  bool shouldShowRawDate(BuildContext context) {
    return friendlyDateLabel(context) != dateLabel;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event_outlined,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.sectionCount(
                  friendlyDateLabel(context),
                  mealPlans.length,
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (shouldShowRawDate(context)) ...[
                const SizedBox(width: 8),
                Text(dateLabel, style: theme.textTheme.bodySmall),
              ],
            ],
          ),
          const SizedBox(height: 8),
          for (final mealPlan in mealPlans)
            _MealPlanCard(
              mealPlan: mealPlan,
              onEdit: () => onEdit(mealPlan),
              onDelete: () {
                onDelete(mealPlan[AppMealPlanFields.id].toString());
              },
            ),
        ],
      ),
    );
  }
}

class _MealPlanCard extends StatelessWidget {
  const _MealPlanCard({
    required this.mealPlan,
    required this.onEdit,
    required this.onDelete,
  });

  final Map<String, dynamic> mealPlan;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  String get mealType {
    final value = mealPlan[AppMealPlanFields.mealType]?.toString();

    if (value == null || value.trim().isEmpty) {
      return AppMealTypes.dinner;
    }

    return value.trim();
  }

  AppMealTypeConfig get mealTypeConfig {
    return AppMealTypes.fromValue(mealType);
  }

  Map<String, dynamic>? get recipe {
    final value = mealPlan[AppMealPlanFields.recipes];

    if (value is Map<String, dynamic>) {
      return value;
    }

    return null;
  }

  bool get hasRecipe {
    return recipe != null;
  }

  bool get hasEstimatedCost {
    return mealPlan[AppMealPlanCostFields.hasEstimatedCost] == true;
  }

  double? get estimatedCost {
    final value = mealPlan[AppMealPlanCostFields.estimatedCost];

    if (value == null) return null;

    if (value is num) return value.toDouble();

    return double.tryParse(value.toString().replaceAll(',', '.'));
  }

  String get priceCurrency {
    final value = mealPlan[AppMealPlanCostFields.priceCurrency]?.toString();

    if (value == null || value.trim().isEmpty) {
      return 'EUR';
    }

    return value.trim();
  }

  String title(BuildContext context) {
    final recipeName = recipe?[AppRecipeFields.name]?.toString();

    if (recipeName != null && recipeName.trim().isNotEmpty) {
      return recipeName.trim();
    }

    final note = mealPlan[AppMealPlanFields.note]?.toString();

    if (note != null && note.trim().isNotEmpty) {
      return note.trim();
    }

    return context.l10n.customMeal;
  }

  String? note(BuildContext context) {
    final value = mealPlan[AppMealPlanFields.note]?.toString();

    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final trimmed = value.trim();

    if (trimmed == title(context)) {
      return null;
    }

    return trimmed;
  }

  String helperText(BuildContext context) {
    if (hasRecipe) {
      return context.l10n.recipeMealCanGenerateShoppingItems;
    }

    return context.l10n.customMealWillNotGenerateShoppingItems;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final noteText = note(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: hasRecipe
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  mealTypeConfig.icon,
                  color: hasRecipe
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _MealTypePill(config: mealTypeConfig),
                        _MealSourcePill(hasRecipe: hasRecipe),
                        if (hasEstimatedCost && estimatedCost != null)
                          _MealEstimatedCostPill(
                            amount: estimatedCost!,
                            currency: priceCurrency,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      helperText(context),
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (noteText != null) ...[
                      const SizedBox(height: 8),
                      _MealNoteBox(note: noteText),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onEdit,
                            icon: const Icon(Icons.edit_outlined),
                            label: Text(context.l10n.edit),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete_outline),
                          tooltip: context.l10n.deleteMealPlan,
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

class _MealSourcePill extends StatelessWidget {
  const _MealSourcePill({required this.hasRecipe});

  final bool hasRecipe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final backgroundColor = hasRecipe
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surfaceContainerHighest;

    final foregroundColor = hasRecipe
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasRecipe ? Icons.restaurant_menu : Icons.edit_note_outlined,
            size: 14,
            color: foregroundColor,
          ),
          const SizedBox(width: 5),
          Text(
            hasRecipe ? context.l10n.recipe : context.l10n.custom,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: foregroundColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _MealNoteBox extends StatelessWidget {
  const _MealNoteBox({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.55,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.notes_outlined,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(note, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }
}

class _MealTypePill extends StatelessWidget {
  const _MealTypePill({required this.config});

  final AppMealTypeConfig config;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config.icon,
            size: 14,
            color: theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 5),
          Text(
            config.label(context),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _MealEstimatedCostPill extends StatelessWidget {
  const _MealEstimatedCostPill({required this.amount, required this.currency});

  final double amount;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.euro_outlined,
            size: 14,
            color: theme.colorScheme.onTertiaryContainer,
          ),
          const SizedBox(width: 5),
          Text(
            'Est. ${amount.toStringAsFixed(2)} $currency',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onTertiaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
