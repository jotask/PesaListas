import 'package:flutter/material.dart';
import 'package:pesalistas/core/app_units.dart';
import 'package:pesalistas/core/design/app_radius.dart';
import 'package:pesalistas/core/design/app_spacing.dart';
import 'package:pesalistas/core/fields/meal_plan_fields.dart';
import 'package:pesalistas/core/fields/recipe_fields.dart';
import 'package:pesalistas/core/fields/shopping_item_fields.dart';
import 'package:pesalistas/core/shopping_stores.dart';
import 'package:pesalistas/core/value_parsing.dart';
import 'package:pesalistas/widgets/common/app_meta_pill.dart';
import 'package:pesalistas/widgets/design/app_surface.dart';

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

  String get name {
    final value = item[AppShoppingItemFields.name]?.toString();

    if (value == null || value.trim().isEmpty) {
      return 'Unnamed item';
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

  String? get productImageUrl {
    return AppValueParsing.textOrNull(
      item[AppShoppingItemFields.productImageUrl],
    );
  }

  double? get estimatedTotalPrice {
    return AppValueParsing.doubleOrNull(
      item[AppShoppingItemFields.estimatedTotalPrice],
    );
  }

  String get priceCurrency {
    final value = AppValueParsing.textOrNull(
      item[AppShoppingItemFields.priceCurrency],
    );

    if (value == null || value.trim().isEmpty) {
      return 'EUR';
    }

    return value.trim().toUpperCase();
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

  String? get mealTypeText {
    final value = sourceMealPlan?[AppMealPlanFields.mealType]?.toString();

    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return value
        .trim()
        .replaceAll('_', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  String get subtitle {
    final parts = <String>[amountText];

    final store = storeText;

    if (store != null && store.isNotEmpty) {
      parts.add(store);
    }

    return parts.join(' • ');
  }

  String? get sourceContextText {
    if (recipeName != null) {
      return 'From recipe: $recipeName';
    }

    if (!generatedFromMealPlan) {
      return null;
    }

    final parts = <String>[];

    if (plannedFor != null) {
      parts.add(plannedFor!);
    }

    final mealType = mealTypeText;

    if (mealType != null) {
      parts.add(mealType);
    }

    if (parts.isEmpty) {
      return 'From meal plan';
    }

    return 'From meal plan • ${parts.join(' • ')}';
  }

  String? get priceText {
    final price = estimatedTotalPrice;

    if (price == null || price <= 0) {
      return null;
    }

    final formatted = price == price.roundToDouble()
        ? price.toStringAsFixed(0)
        : price.toStringAsFixed(2);

    return '$priceCurrency $formatted';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sourceText = sourceContextText;
    final imageUrl = productImageUrl;
    final price = priceText;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: AppSurface(
        onTap: onEdit,
        padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
        borderColor: checked
            ? theme.colorScheme.outlineVariant.withValues(alpha: 0.36)
            : theme.colorScheme.primary.withValues(alpha: 0.16),
        child: Opacity(
          opacity: checked ? 0.56 : 1,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ShoppingCheckButton(checked: checked, onPressed: onToggle),
              const SizedBox(width: AppSpacing.sm),
              _ProductThumb(imageUrl: imageUrl, checked: checked),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          decoration: checked
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: [
                          if (price != null)
                            AppMetaPill(
                              label: price,
                              icon: Icons.payments_outlined,
                              filled: true,
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              foregroundColor:
                                  theme.colorScheme.onPrimaryContainer,
                            ),
                          if (sourceText != null)
                            AppMetaPill(
                              label: sourceText,
                              icon: Icons.auto_awesome_outlined,
                            ),
                          if (hasLinkedProduct)
                            const AppMetaPill(
                              label: 'Saved product',
                              icon: Icons.inventory_2_outlined,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              PopupMenuButton<_ShoppingItemAction>(
                tooltip: 'More options',
                icon: Icon(
                  Icons.more_horiz,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
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
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: _ShoppingItemAction.edit,
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined),
                        SizedBox(width: AppSpacing.sm),
                        Text('Edit item'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: _ShoppingItemAction.delete,
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline),
                        SizedBox(width: AppSpacing.sm),
                        Text('Delete item'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShoppingCheckButton extends StatelessWidget {
  const _ShoppingCheckButton({required this.checked, required this.onPressed});

  final bool checked;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: checked ? 'Mark as not bought' : 'Mark as bought',
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: checked
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: checked
                  ? theme.colorScheme.primary.withValues(alpha: 0.24)
                  : theme.colorScheme.outlineVariant,
            ),
          ),
          child: Icon(
            checked ? Icons.check_circle : Icons.radio_button_unchecked,
            color: checked
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _ProductThumb extends StatelessWidget {
  const _ProductThumb({required this.imageUrl, required this.checked});

  final String? imageUrl;
  final bool checked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = imageUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        width: 46,
        height: 46,
        color: theme.colorScheme.surfaceContainerHighest,
        child: url == null || url.isEmpty
            ? Icon(
                checked
                    ? Icons.shopping_cart_checkout_rounded
                    : Icons.shopping_bag_outlined,
                color: theme.colorScheme.onSurfaceVariant,
              )
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) {
                  return Icon(
                    Icons.shopping_bag_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                  );
                },
              ),
      ),
    );
  }
}

enum _ShoppingItemAction { edit, delete }
