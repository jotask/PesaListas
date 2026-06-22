import 'package:flutter/material.dart';
import 'package:pesalistas/core/design/app_colors.dart';
import 'package:pesalistas/core/list_types.dart';

@immutable
class ListTypeStyle {
  const ListTypeStyle({
    required this.accent,
    required this.soft,
    required this.onSoft,
    required this.gradientStart,
    required this.gradientEnd,
  });

  final Color accent;
  final Color soft;
  final Color onSoft;
  final Color gradientStart;
  final Color gradientEnd;

  LinearGradient get gradient {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [gradientStart, gradientEnd],
    );
  }

  static ListTypeStyle of(String listType) {
    if (listType == AppListTypes.tasks.value) {
      return const ListTypeStyle(
        accent: AppColors.blue,
        soft: Color(0xFFEAF2FF),
        onSoft: Color(0xFF174EA6),
        gradientStart: Color(0xFFEAF2FF),
        gradientEnd: Color(0xFFF7FAFF),
      );
    }

    if (listType == AppListTypes.chores.value) {
      return const ListTypeStyle(
        accent: AppColors.amber,
        soft: Color(0xFFFFF4DB),
        onSoft: Color(0xFF8A5200),
        gradientStart: Color(0xFFFFF4DB),
        gradientEnd: Color(0xFFFFFBF2),
      );
    }

    if (listType == AppListTypes.shopping.value) {
      return const ListTypeStyle(
        accent: AppColors.green,
        soft: Color(0xFFE6F7EF),
        onSoft: Color(0xFF12633E),
        gradientStart: Color(0xFFE6F7EF),
        gradientEnd: Color(0xFFF6FCF9),
      );
    }

    if (listType == AppListTypes.movies.value) {
      return const ListTypeStyle(
        accent: AppColors.purple,
        soft: Color(0xFFF1EAFE),
        onSoft: Color(0xFF5B2BC8),
        gradientStart: Color(0xFFF1EAFE),
        gradientEnd: Color(0xFFFBF8FF),
      );
    }

    if (listType == AppListTypes.books.value) {
      return const ListTypeStyle(
        accent: Color(0xFF2563EB),
        soft: Color(0xFFEAF1FF),
        onSoft: Color(0xFF1E40AF),
        gradientStart: Color(0xFFEAF1FF),
        gradientEnd: Color(0xFFF8FBFF),
      );
    }

    if (listType == AppListTypes.ideas.value) {
      return const ListTypeStyle(
        accent: Color(0xFFEAA300),
        soft: Color(0xFFFFF5D6),
        onSoft: Color(0xFF845400),
        gradientStart: Color(0xFFFFF5D6),
        gradientEnd: Color(0xFFFFFCF1),
      );
    }

    if (listType == AppListTypes.activities.value) {
      return const ListTypeStyle(
        accent: AppColors.coral,
        soft: Color(0xFFFFECE6),
        onSoft: Color(0xFF9A3412),
        gradientStart: Color(0xFFFFECE6),
        gradientEnd: Color(0xFFFFFAF7),
      );
    }

    if (listType == AppListTypes.recipes.value) {
      return const ListTypeStyle(
        accent: Color(0xFFF97316),
        soft: Color(0xFFFFEEE1),
        onSoft: Color(0xFF9A3412),
        gradientStart: Color(0xFFFFEEE1),
        gradientEnd: Color(0xFFFFFAF5),
      );
    }

    if (listType == AppListTypes.mealPlan.value) {
      return const ListTypeStyle(
        accent: Color(0xFF7C3AED),
        soft: Color(0xFFF1E8FF),
        onSoft: Color(0xFF5B21B6),
        gradientStart: Color(0xFFF1E8FF),
        gradientEnd: Color(0xFFFCF8FF),
      );
    }

    return const ListTypeStyle(
      accent: AppColors.brand,
      soft: Color(0xFFE8F7F3),
      onSoft: Color(0xFF0F6F63),
      gradientStart: Color(0xFFE8F7F3),
      gradientEnd: Color(0xFFF7FCFA),
    );
  }
}
