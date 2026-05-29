import 'package:flutter/material.dart';
import 'package:pesalistas/core/app_units.dart';
import 'package:pesalistas/core/fields/meal_plan_fields.dart';
import 'package:pesalistas/core/fields/recipe_fields.dart';
import 'package:pesalistas/core/fields/shopping_item_fields.dart';
import 'package:pesalistas/core/meal_types.dart';
import 'package:pesalistas/core/money_formatting.dart';
import 'package:pesalistas/core/shopping_item_cost.dart';
import 'package:pesalistas/core/value_parsing.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/widgets/common/app_meta_pill.dart';
import 'package:pesalistas/widgets/common/app_network_image_thumbnail.dart';
import 'package:pesalistas/widgets/common/app_state_pill.dart';

class ShoppingItemCard extends StatelessWidget {
  const ShoppingItemCard({
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

  String? get catalogItemId {
    final value = item[AppShoppingItemFields.catalogItemId]?.toString();

    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return value.trim();
  }

  bool get isLinkedProduct {
    return barcode != null;
  }

  bool get isLinkedGenericItem {
    return catalogItemId != null && barcode == null;
  }

  String? sourceText(BuildContext context) {
    if (isLinkedProduct) {
      return 'Product';
    }

    if (isLinkedGenericItem) {
      return 'Generic item';
    }

    return null;
  }

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

  String? get barcode {
    return AppValueParsing.textOrNull(item[AppShoppingItemFields.barcode]);
  }

  String? get productName {
    return AppValueParsing.textOrNull(item[AppShoppingItemFields.productName]);
  }

  String? get productImageUrl {
    return AppValueParsing.textOrNull(
      item[AppShoppingItemFields.productImageUrl],
    );
  }

  String get priceCurrency {
    return AppShoppingItemCost.priceCurrency(item);
  }

  double? get estimatedUnitPrice {
    return AppShoppingItemCost.estimatedUnitPrice(item);
  }

  double? get estimatedTotalPrice {
    return AppShoppingItemCost.estimatedTotal(item);
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

  bool get hasProductData {
    return barcode != null || productImageUrl != null || productName != null;
  }

  String amountText(BuildContext context) {
    final amount = AppUnitType.quantityText(quantity: quantity, unit: unit);

    if (amount.isEmpty) {
      return checked ? context.l10n.bought : context.l10n.toBuy;
    }

    return amount;
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
    final parts = <String>[amountText(context)];

    final source = sourceText(context);

    if (source != null) {
      parts.add(source);
    }

    if (recipeName != null) {
      parts.add(context.l10n.recipeSourceLabel(recipeName!));
    } else if (generatedFromMealPlan) {
      parts.add(context.l10n.fromMealPlan);
    }

    return parts.join(' • ');
  }

  String? sourceContextText(BuildContext context) {
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
      return null;
    }

    return parts.join(' • ');
  }

  String? priceSummaryText(BuildContext context) {
    final total = estimatedTotalPrice;
    final unitPrice = estimatedUnitPrice;

    if (total == null && unitPrice == null) {
      return null;
    }

    if (total != null && unitPrice != null) {
      return context.l10n.priceTotalEach(
        AppMoneyFormatting.format(total, priceCurrency),
        AppMoneyFormatting.format(unitPrice, priceCurrency),
      );
    }

    if (total != null) {
      return context.l10n.priceTotal(
        AppMoneyFormatting.format(total, priceCurrency),
      );
    }

    return context.l10n.priceEach(
      AppMoneyFormatting.format(unitPrice!, priceCurrency),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sourceText = sourceContextText(context);
    final priceText = priceSummaryText(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Opacity(
            opacity: checked ? 0.72 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppNetworkImageThumbnail(
                      imageUrl: productImageUrl,
                      width: 54,
                      height: 54,
                      borderRadius: 14,
                      fallbackIcon: Icons.inventory_2_outlined,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  name(context),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    decoration: checked
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                              AppStatePill(
                                active: checked,
                                label: checked
                                    ? context.l10n.bought
                                    : context.l10n.toBuy,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle(context),
                            style: theme.textTheme.bodyMedium,
                          ),
                          if (sourceText != null) ...[
                            const SizedBox(height: 8),
                            AppMetaPill(
                              label: sourceText,
                              icon: Icons.event_note_outlined,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if (hasProductData || priceText != null) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (productName != null && productName != name(context))
                        AppMetaPill(
                          label: productName!,
                          icon: Icons.inventory_2_outlined,
                        ),
                      if (barcode != null)
                        AppMetaPill(
                          label: barcode!,
                          icon: Icons.qr_code_2_outlined,
                        ),
                      if (priceText != null)
                        AppMetaPill(
                          label: priceText,
                          icon: Icons.euro_outlined,
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onToggle,
                        icon: Icon(
                          checked ? Icons.undo : Icons.check_circle_outline,
                        ),
                        label: Text(
                          checked
                              ? context.l10n.markAsNotBought
                              : context.l10n.markAsBought,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: context.l10n.editItem,
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline),
                      tooltip: context.l10n.deleteItem,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
