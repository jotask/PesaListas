import 'package:flutter/material.dart';
import 'package:pesalistas/core/meal_plan_fields.dart';
import 'package:pesalistas/core/recipe_fields.dart';
import 'package:pesalistas/core/shopping_item_fields.dart';
import 'package:pesalistas/dialogs/add_meal_plan_dialog.dart';
import 'package:pesalistas/l10n/app_strings.dart';
import 'package:pesalistas/widgets/list_detail/empty_items_card.dart';

class ShoppingItemsView extends StatelessWidget {
  const ShoppingItemsView({
    super.key,
    required this.items,
    required this.loading,
    required this.onCreate,
    required this.onComplete,
    required this.onReopen,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Map<String, dynamic>> items;
  final bool loading;
  final VoidCallback onCreate;
  final void Function(String itemId) onComplete;
  final void Function(String itemId) onReopen;
  final void Function(Map<String, dynamic> item) onEdit;
  final void Function(String itemId) onDelete;

  List<Map<String, dynamic>> get toBuyItems {
    return items.where((item) {
      return item[AppShoppingItemFields.checked] != true;
    }).toList();
  }

  List<Map<String, dynamic>> get boughtItems {
    return items.where((item) {
      return item[AppShoppingItemFields.checked] == true;
    }).toList();
  }

  int get generatedCount {
    return items.where((item) {
      final value = item[AppShoppingItemFields.sourceMealPlanId]?.toString();
      return value != null && value.isNotEmpty;
    }).length;
  }

  bool isChecked(Map<String, dynamic> item) {
    return item[AppShoppingItemFields.checked] == true;
  }

  void toggleItem(Map<String, dynamic> item) {
    final itemId = item[AppShoppingItemFields.id].toString();

    if (isChecked(item)) {
      onReopen(itemId);
    } else {
      onComplete(itemId);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return EmptyItemsCard(
        icon: Icons.shopping_cart_outlined,
        title: S.noShoppingItemsYet,
        subtitle: S.addYourFirstItem,
        onCreate: onCreate,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ShoppingSummaryCard(
          totalCount: items.length,
          toBuyCount: toBuyItems.length,
          boughtCount: boughtItems.length,
          generatedCount: generatedCount,
        ),
        const SizedBox(height: 12),
        if (toBuyItems.isNotEmpty)
          _ShoppingSection(
            title: S.toBuy,
            icon: Icons.shopping_cart_outlined,
            items: toBuyItems,
            onToggle: toggleItem,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
        if (toBuyItems.isNotEmpty && boughtItems.isNotEmpty)
          const SizedBox(height: 16),
        if (boughtItems.isNotEmpty)
          _ShoppingSection(
            title: S.bought,
            icon: Icons.shopping_cart_checkout,
            items: boughtItems,
            onToggle: toggleItem,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
      ],
    );
  }
}

class _ShoppingSummaryCard extends StatelessWidget {
  const _ShoppingSummaryCard({
    required this.totalCount,
    required this.toBuyCount,
    required this.boughtCount,
    required this.generatedCount,
  });

  final int totalCount;
  final int toBuyCount;
  final int boughtCount;
  final int generatedCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.shopping_basket_outlined,
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
                    label: S.toBuySummary(toBuyCount),
                    icon: Icons.shopping_cart_outlined,
                  ),
                  _SummaryPill(
                    label: S.boughtSummary(boughtCount),
                    icon: Icons.shopping_cart_checkout,
                  ),
                  _SummaryPill(
                    label: S.generatedSummary(generatedCount),
                    icon: Icons.auto_awesome_outlined,
                  ),
                  _SummaryPill(
                    label: S.totalCountSummary(totalCount),
                    icon: Icons.list_alt_outlined,
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

class _ShoppingSection extends StatelessWidget {
  const _ShoppingSection({
    required this.title,
    required this.icon,
    required this.items,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final String title;
  final IconData icon;
  final List<Map<String, dynamic>> items;
  final void Function(Map<String, dynamic> item) onToggle;
  final void Function(Map<String, dynamic> item) onEdit;
  final void Function(String itemId) onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              S.sectionCount(title, items.length),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final item in items)
          _ShoppingItemCard(
            item: item,
            onToggle: () => onToggle(item),
            onEdit: () => onEdit(item),
            onDelete: () => onDelete(item[AppShoppingItemFields.id].toString()),
          ),
      ],
    );
  }
}

class _ShoppingItemCard extends StatelessWidget {
  const _ShoppingItemCard({
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
      return S.unnamedItem;
    }

    return value.trim();
  }

  String? get quantity {
    final value = item[AppShoppingItemFields.quantity];

    if (value == null || value.toString().trim().isEmpty) {
      return null;
    }

    return value.toString();
  }

  String? get unit {
    final value = item[AppShoppingItemFields.unit]?.toString();

    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return value.trim();
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

  String get amountText {
    final parts = <String>[];

    if (quantity != null) {
      parts.add(quantity!);
    }

    if (unit != null) {
      parts.add(unit!);
    }

    if (parts.isEmpty) {
      return checked ? S.bought : S.toBuy;
    }

    return parts.join(' ');
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

  String? get mealTypeLabel {
    final value = sourceMealPlan?[AppMealPlanFields.mealType]?.toString();

    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return AppMealTypes.fromValue(value).label;
  }

  String get subtitle {
    final parts = <String>[amountText];

    if (recipeName != null) {
      parts.add(S.recipeSourceLabel(recipeName!));
    } else if (generatedFromMealPlan) {
      parts.add(S.fromMealPlan);
    }

    return parts.join(' • ');
  }

  String? get sourceContextText {
    if (!generatedFromMealPlan) {
      return null;
    }

    final parts = <String>[];

    if (plannedFor != null) {
      parts.add(plannedFor!);
    }

    if (mealTypeLabel != null) {
      parts.add(mealTypeLabel!);
    }

    if (parts.isEmpty) {
      return null;
    }

    return parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                    CircleAvatar(
                      backgroundColor: checked
                          ? theme.colorScheme.secondaryContainer
                          : theme.colorScheme.primaryContainer,
                      child: Icon(
                        checked
                            ? Icons.shopping_cart_checkout
                            : Icons.shopping_cart_outlined,
                        color: checked
                            ? theme.colorScheme.onSecondaryContainer
                            : theme.colorScheme.onPrimaryContainer,
                      ),
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
                                  name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    decoration: checked
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                              _ShoppingStatePill(checked: checked),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(subtitle, style: theme.textTheme.bodyMedium),
                          if (sourceContextText != null) ...[
                            const SizedBox(height: 8),
                            _SourceContextPill(text: sourceContextText!),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
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
                          checked ? S.markAsNotBought : S.markAsBought,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: S.editItem,
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline),
                      tooltip: S.deleteItem,
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

class _SourceContextPill extends StatelessWidget {
  const _SourceContextPill({required this.text});

  final String text;

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
          Icon(
            Icons.event_note_outlined,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShoppingStatePill extends StatelessWidget {
  const _ShoppingStatePill({required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final backgroundColor = checked
        ? theme.colorScheme.secondaryContainer
        : theme.colorScheme.primaryContainer;

    final foregroundColor = checked
        ? theme.colorScheme.onSecondaryContainer
        : theme.colorScheme.onPrimaryContainer;

    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        checked ? S.bought : S.toBuy,
        style: TextStyle(
          color: foregroundColor,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
