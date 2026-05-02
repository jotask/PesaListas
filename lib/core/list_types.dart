import 'package:flutter/material.dart';

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

  static const generic = AppListTypeConfig(
    value: 'generic',
    label: 'Generic list',
    icon: Icons.list_alt,
    description: 'Simple shared list for anything.',
  );

  static const tasks = AppListTypeConfig(
    value: 'tasks',
    label: 'Tasks',
    icon: Icons.check_circle_outline,
    description: 'Track one-time tasks and to-dos.',
  );

  static const chores = AppListTypeConfig(
    value: 'chores',
    label: 'Chores',
    icon: Icons.cleaning_services_outlined,
    description: 'Recurring household work.',
  );

  static const movies = AppListTypeConfig(
    value: 'movies',
    label: 'Movies',
    icon: Icons.movie_outlined,
    description: 'Movies to watch and vote on.',
  );

  static const ideas = AppListTypeConfig(
    value: 'ideas',
    label: 'Ideas',
    icon: Icons.lightbulb_outline,
    description: 'Ideas to collect and discuss.',
  );

  static const activities = AppListTypeConfig(
    value: 'activities',
    label: 'Activities',
    icon: Icons.local_activity_outlined,
    description: 'Things to do together.',
  );

  static const recipes = AppListTypeConfig(
    value: 'recipes',
    label: 'Recipes',
    icon: Icons.restaurant_menu_outlined,
    description: 'Meals and cooking ideas.',
  );

  static const shopping = AppListTypeConfig(
    value: 'shopping',
    label: 'Shopping',
    icon: Icons.shopping_cart_outlined,
    description: 'Shared shopping list.',
  );

  static const mealPlan = AppListTypeConfig(
    value: 'meal_plan',
    label: 'Meal planning',
    icon: Icons.calendar_month_outlined,
    description: 'Plan meals by day.',
  );

  static const all = [
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
