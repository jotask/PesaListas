import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/app_strings.dart';

class AppListTypeConfig {
  const AppListTypeConfig({
    required this.value,
    required this.label,
    required this.icon,
    required this.description,
  });

  final String value;
  final String label;
  final IconData icon;
  final String description;
}

class AppListTypes {
  const AppListTypes._();

  static AppListTypeConfig get generic => AppListTypeConfig(
        value: 'generic',
        label: S.genericList,
        icon: Icons.list_alt,
        description: S.simpleSharedListForAnything,
      );

  static AppListTypeConfig get tasks => AppListTypeConfig(
        value: 'tasks',
        label: S.tasks,
        icon: Icons.check_circle_outline,
        description: S.trackOneTimeTasksAndToDos,
      );

  static AppListTypeConfig get chores => AppListTypeConfig(
        value: 'chores',
        label: S.chores,
        icon: Icons.cleaning_services_outlined,
        description: S.recurringHouseholdWork,
      );

  static AppListTypeConfig get movies => AppListTypeConfig(
        value: 'movies',
        label: S.movies,
        icon: Icons.movie_outlined,
        description: S.moviesToWatchAndVoteOn,
      );

  static AppListTypeConfig get ideas => AppListTypeConfig(
        value: 'ideas',
        label: S.ideas,
        icon: Icons.lightbulb_outline,
        description: S.ideasToCollectAndDiscuss,
      );

  static AppListTypeConfig get activities => AppListTypeConfig(
        value: 'activities',
        label: S.activities,
        icon: Icons.local_activity_outlined,
        description: S.thingsToDoTogether,
      );

  static AppListTypeConfig get recipes => AppListTypeConfig(
        value: 'recipes',
        label: S.recipes,
        icon: Icons.restaurant_menu_outlined,
        description: S.mealsAndCookingIdeas,
      );

  static AppListTypeConfig get shopping => AppListTypeConfig(
        value: 'shopping',
        label: S.shopping,
        icon: Icons.shopping_cart_outlined,
        description: S.sharedShoppingList,
      );

  static AppListTypeConfig get mealPlan => AppListTypeConfig(
        value: 'meal_plan',
        label: S.mealPlanning,
        icon: Icons.calendar_month_outlined,
        description: S.planMealsByDay,
      );

  static List<AppListTypeConfig> get all => [
        generic,
        tasks,
        chores,
        movies,
        ideas,
        activities,
        recipes,
        shopping,
        mealPlan,
      ];

  static AppListTypeConfig fromValue(String? value) {
    if (value == null) return generic;

    for (final config in all) {
      if (config.value == value) return config;
    }

    return generic;
  }
}
