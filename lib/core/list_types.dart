import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';

class AppListTypeConfig {
  const AppListTypeConfig({
    required this.value,
    required this.labelKey,
    required this.icon,
    required this.descriptionKey,
  });

  final String value;
  final String labelKey;
  final IconData icon;
  final String descriptionKey;

  String label(BuildContext context) {
    switch (labelKey) {
      case 'genericList':
        return context.l10n.genericList;
      case 'tasks':
        return context.l10n.tasks;
      case 'chores':
        return context.l10n.chores;
      case 'movies':
        return context.l10n.movies;
      case 'ideas':
        return context.l10n.ideas;
      case 'activities':
        return context.l10n.activities;
      case 'recipes':
        return context.l10n.recipes;
      case 'shopping':
        return context.l10n.shopping;
      case 'mealPlanning':
        return context.l10n.mealPlanning;
      default:
        return context.l10n.genericList;
    }
  }

  String description(BuildContext context) {
    switch (descriptionKey) {
      case 'simpleSharedListForAnything':
        return context.l10n.simpleSharedListForAnything;
      case 'trackOneTimeTasksAndToDos':
        return context.l10n.trackOneTimeTasksAndToDos;
      case 'recurringHouseholdWork':
        return context.l10n.recurringHouseholdWork;
      case 'moviesToWatchAndVoteOn':
        return context.l10n.moviesToWatchAndVoteOn;
      case 'ideasToCollectAndDiscuss':
        return context.l10n.ideasToCollectAndDiscuss;
      case 'thingsToDoTogether':
        return context.l10n.thingsToDoTogether;
      case 'mealsAndCookingIdeas':
        return context.l10n.mealsAndCookingIdeas;
      case 'sharedShoppingList':
        return context.l10n.sharedShoppingList;
      case 'planMealsByDay':
        return context.l10n.planMealsByDay;
      default:
        return context.l10n.simpleSharedListForAnything;
    }
  }
}

class AppListTypes {
  const AppListTypes._();

  static const generic = AppListTypeConfig(
    value: 'generic',
    labelKey: 'genericList',
    icon: Icons.list_alt,
    descriptionKey: 'simpleSharedListForAnything',
  );

  static const tasks = AppListTypeConfig(
    value: 'tasks',
    labelKey: 'tasks',
    icon: Icons.check_circle_outline,
    descriptionKey: 'trackOneTimeTasksAndToDos',
  );

  static const chores = AppListTypeConfig(
    value: 'chores',
    labelKey: 'chores',
    icon: Icons.cleaning_services_outlined,
    descriptionKey: 'recurringHouseholdWork',
  );

  static const movies = AppListTypeConfig(
    value: 'movies',
    labelKey: 'movies',
    icon: Icons.movie_outlined,
    descriptionKey: 'moviesToWatchAndVoteOn',
  );

  static const ideas = AppListTypeConfig(
    value: 'ideas',
    labelKey: 'ideas',
    icon: Icons.lightbulb_outline,
    descriptionKey: 'ideasToCollectAndDiscuss',
  );

  static const activities = AppListTypeConfig(
    value: 'activities',
    labelKey: 'activities',
    icon: Icons.local_activity_outlined,
    descriptionKey: 'thingsToDoTogether',
  );

  static const recipes = AppListTypeConfig(
    value: 'recipes',
    labelKey: 'recipes',
    icon: Icons.restaurant_menu_outlined,
    descriptionKey: 'mealsAndCookingIdeas',
  );

  static const shopping = AppListTypeConfig(
    value: 'shopping',
    labelKey: 'shopping',
    icon: Icons.shopping_cart_outlined,
    descriptionKey: 'sharedShoppingList',
  );

  static const mealPlan = AppListTypeConfig(
    value: 'meal_plan',
    labelKey: 'mealPlanning',
    icon: Icons.calendar_month_outlined,
    descriptionKey: 'planMealsByDay',
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
