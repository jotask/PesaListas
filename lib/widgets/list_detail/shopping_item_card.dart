import 'package:flutter/material.dart';
import 'package:pesalistas/core/app_units.dart';
import 'package:pesalistas/core/fields/meal_plan_fields.dart';
import 'package:pesalistas/core/fields/recipe_fields.dart';
import 'package:pesalistas/core/fields/shopping_item_fields.dart';
import 'package:pesalistas/core/meal_types.dart';
import 'package:pesalistas/core/shopping_stores.dart';
import 'package:pesalistas/core/value_parsing.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/widgets/common/app_meta_pill.dart';

class ShoppingItemCard extends StatelessWidget {
  const ShoppingItemCard({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final Map<String, dynamic> item;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  bool get checked => item[AppShoppingItemFields.checked] == true;

  String name(BuildContext context) {
    final value = item[AppShoppingItemFields.name]?.toString();

    if (value == null || value.trim().isEmpty) {
      return context.l10n.unnamedItem;
    }

    return value.trim();
  }

  double? get quantity {
    return AppValueParsing.doubleOrNull(item[AppShoppingItemFields.quantity]);
  }

  String? get unit {
    return AppUnitType.valueOrNull(
      AppValueParsing.textOrNull(item[AppShoppingItemFields.unit]),
    );
  }

  String get amountText {
    final amount = AppUnitType.quantityText(quantity: quantity, unit: unit);

    if (amount.trim().isEmpty) {
      return '1 item';
    }

    return amount;
  }

  String? get storeText {
    final explicitName = AppValueParsing.textOrNull(
      item[AppShoppingItemFields.storeName],
    );

    if (explicitName != null && explicitName.trim().isNotEmpty) {
      return explicitName.trim();
    }

    final key = AppValueParsing.textOrNull(
      item[AppShoppingItemFields.storeKey],
    );

    if (key == null || key.trim().isEmpty) {
      return null;
    }

    return AppShoppingStores.label(key);
  }

  String? get catalogItemId {
    return AppValueParsing.textOrNull(
      item[AppShoppingItemFields.catalogItemId],
    );
  }

  String? get barcode {
    return AppValueParsing.textOrNull(item[AppShoppingItemFields.barcode]);
  }

  String? get productName {
    return AppValueParsing.textOrNull(item[AppShoppingItemFields.productName]);
  }

  bool get hasLinkedProduct {
    return catalogItemId != null || barcode != null || productName != null;
  }

  Map<String, dynamic>? get sourceRecipe {
    final value = item[AppShoppingItemFields.sourceRecipe];

    if (value is Map<String, dynamic>) {
      return value;
    }

    return null;
  }

  Map<String, dynamic>? get sourceMealPlan {
    final value = item[AppShoppingItemFields.sourceMealPlan];

    if (value is Map<String, dynamic>) {
      return value;
    }

    return null;
  }

  bool get generatedFromMealPlan {
    final value = item[AppShoppingItemFields.sourceMealPlanId]?.toString();
    return value != null && value.isNotEmpty;
  }

  String? get recipeName {
    final value = sourceRecipe?[AppRecipeFields.name]?.toString();

    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return value.trim();
  }

  String? get plannedFor {
    final value = sourceMealPlan?[AppMealPlanFields.plannedFor]?.toString();

    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return value.split('T').first;
  }

  String? mealTypeLabel(BuildContext context) {
    final value = sourceMealPlan?[AppMealPlanFields.mealType]?.toString();

    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return AppMealTypes.fromValue(value).label(context);
  }

  String subtitle(BuildContext context) {
    final parts = <String>[amountText];

    final store = storeText;

    if (store != null && store.isNotEmpty) {
      parts.add(store);
    }

    return parts.join(' • ');
  }

  String? sourceContextText(BuildContext context) {
    if (recipeName != null) {
      return context.l10n.recipeSourceLabel(recipeName!);
    }

    if (!generatedFromMealPlan) {
      return null;
    }

    final parts = <String>[];

    if (plannedFor != null) {
      parts.add(plannedFor!);
    }

    final mealType = mealTypeLabel(context);

    if (mealType != null) {
      parts.add(mealType);
    }

    if (parts.isEmpty) {
      return context.l10n.fromMealPlan;
    }

    return '${context.l10n.fromMealPlan} • ${parts.join(' • ')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sourceText = sourceContextText(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
          child: Opacity(
            opacity: checked ? 0.58 : 1,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: onToggle,
                  icon: Icon(
                    checked ? Icons.check_circle : Icons.radio_button_unchecked,
                  ),
                  color: checked
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  tooltip: checked
                      ? context.l10n.markAsNotBought
                      : context.l10n.markAsBought,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name(context),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            decoration: checked
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (sourceText != null) ...[
                          const SizedBox(height: 8),
                          AppMetaPill(
                            label: sourceText,
                            icon: Icons.auto_awesome_outlined,
                          ),
                        ],
                        if (hasLinkedProduct) ...[
                          const SizedBox(height: 8),
                          const AppMetaPill(
                            label: 'Saved product',
                            icon: Icons.inventory_2_outlined,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                PopupMenuButton<_ShoppingItemAction>(
                  onSelected: (action) {
                    switch (action) {
                      case _ShoppingItemAction.edit:
                        onEdit();
                        break;
                      case _ShoppingItemAction.delete:
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        value: _ShoppingItemAction.edit,
                        child: Text(context.l10n.editItem),
                      ),
                      PopupMenuItem(
                        value: _ShoppingItemAction.delete,
                        child: Text(context.l10n.deleteItem),
                      ),
                    ];
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _ShoppingItemAction { edit, delete }
