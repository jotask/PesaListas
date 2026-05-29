import 'package:flutter/material.dart';
import 'package:pesalistas/core/app_config.dart';
import 'package:pesalistas/core/money_formatting.dart';
import 'package:pesalistas/core/shopping_item_cost.dart';
import 'package:pesalistas/core/fields/shopping_item_fields.dart';
import 'package:pesalistas/core/value_parsing.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/widgets/common/app_meta_pill.dart';
import 'package:pesalistas/widgets/list_detail/empty_items_card.dart';
import 'package:pesalistas/widgets/list_detail/shopping_item_card.dart';
import 'package:pesalistas/widgets/list_detail/unread_item_highlight.dart';

class ShoppingItemsView extends StatefulWidget {
  const ShoppingItemsView({
    super.key,
    required this.items,
    required this.loading,
    required this.onCreate,
    required this.onComplete,
    required this.onReopen,
    required this.onEdit,
    required this.onDelete,
    required this.onClearBought,
    required this.onClearAll,
  });

  final List<Map<String, dynamic>> items;
  final bool loading;
  final VoidCallback onCreate;
  final void Function(String itemId) onComplete;
  final void Function(String itemId) onReopen;
  final void Function(Map<String, dynamic> item) onEdit;
  final void Function(String itemId) onDelete;
  final VoidCallback onClearBought;
  final VoidCallback onClearAll;

  @override
  State<ShoppingItemsView> createState() => _ShoppingItemsViewState();
}

class _ShoppingItemsViewState extends State<ShoppingItemsView> {
  ShoppingSourceFilter selectedSourceFilter = ShoppingSourceFilter.all;

  List<Map<String, dynamic>> get filteredItems {
    switch (selectedSourceFilter) {
      case ShoppingSourceFilter.all:
        return widget.items;

      case ShoppingSourceFilter.manual:
        return widget.items.where((item) => !isGeneratedItem(item)).toList();

      case ShoppingSourceFilter.generated:
        return widget.items.where(isGeneratedItem).toList();
    }
  }

  List<Map<String, dynamic>> get toBuyItems {
    return filteredItems.where((item) {
      return item[AppShoppingItemFields.checked] != true;
    }).toList();
  }

  List<Map<String, dynamic>> get boughtItems {
    return filteredItems.where((item) {
      return item[AppShoppingItemFields.checked] == true;
    }).toList();
  }

  int get manualCount {
    return widget.items.where((item) => !isGeneratedItem(item)).length;
  }

  int get generatedCount {
    return widget.items.where(isGeneratedItem).length;
  }

  int get boughtCountForAllItems {
    return widget.items.where((item) {
      return item[AppShoppingItemFields.checked] == true;
    }).length;
  }

  String get priceCurrency {
    for (final item in widget.items) {
      final value = AppValueParsing.textOrNull(
        item[AppShoppingItemFields.priceCurrency],
      );

      if (value != null) {
        return value;
      }
    }

    return AppConfig.defaultCurrency;
  }

  double get totalEstimatedCost {
    return widget.items.fold<double>(0, (total, item) {
      return total + (AppShoppingItemCost.estimatedTotal(item) ?? 0);
    });
  }

  double get toBuyEstimatedCost {
    return widget.items
        .where((item) => item[AppShoppingItemFields.checked] != true)
        .fold<double>(0, (total, item) {
          return total + (AppShoppingItemCost.estimatedTotal(item) ?? 0);
        });
  }

  bool get hasEstimatedPrices {
    return widget.items.any(
      (item) => AppShoppingItemCost.estimatedTotal(item) != null,
    );
  }

  bool isGeneratedItem(Map<String, dynamic> item) {
    final value = item[AppShoppingItemFields.sourceMealPlanId]?.toString();
    return value != null && value.isNotEmpty;
  }

  bool isChecked(Map<String, dynamic> item) {
    return item[AppShoppingItemFields.checked] == true;
  }

  void selectSourceFilter(ShoppingSourceFilter filter) {
    setState(() => selectedSourceFilter = filter);
  }

  void clearSourceFilter() {
    setState(() => selectedSourceFilter = ShoppingSourceFilter.all);
  }

  void toggleItem(Map<String, dynamic> item) {
    final itemId = item[AppShoppingItemFields.id].toString();

    if (isChecked(item)) {
      widget.onReopen(itemId);
    } else {
      widget.onComplete(itemId);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.items.isEmpty) {
      return EmptyItemsCard(
        icon: Icons.shopping_cart_outlined,
        title: context.l10n.noShoppingItemsYet,
        subtitle: context.l10n.addYourFirstItem,
        onCreate: widget.onCreate,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ShoppingSummaryCard(
          totalCount: widget.items.length,
          toBuyCount: widget.items.length - boughtCountForAllItems,
          boughtCount: boughtCountForAllItems,
          generatedCount: generatedCount,
          hasEstimatedPrices: hasEstimatedPrices,
          totalEstimatedCost: totalEstimatedCost,
          toBuyEstimatedCost: toBuyEstimatedCost,
          currency: priceCurrency,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (boughtCountForAllItems > 0)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onClearBought,
                  icon: const Icon(Icons.cleaning_services_outlined),
                  label: Text(context.l10n.clearBought),
                ),
              ),
            if (boughtCountForAllItems > 0) const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.onClearAll,
                icon: const Icon(Icons.delete_sweep_outlined),
                label: Text(context.l10n.clearAll),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ShoppingSourceFilterChips(
          selectedFilter: selectedSourceFilter,
          totalCount: widget.items.length,
          manualCount: manualCount,
          generatedCount: generatedCount,
          onSelected: selectSourceFilter,
        ),
        const SizedBox(height: 12),
        if (filteredItems.isEmpty)
          _NoShoppingFilterResultsCard(onClear: clearSourceFilter)
        else ...[
          if (toBuyItems.isNotEmpty)
            _ShoppingSection(
              title: context.l10n.toBuy,
              icon: Icons.shopping_cart_outlined,
              items: toBuyItems,
              onToggle: toggleItem,
              onEdit: widget.onEdit,
              onDelete: widget.onDelete,
            ),
          if (toBuyItems.isNotEmpty && boughtItems.isNotEmpty)
            const SizedBox(height: 16),
          if (boughtItems.isNotEmpty)
            _ShoppingSection(
              title: context.l10n.bought,
              icon: Icons.shopping_cart_checkout,
              items: boughtItems,
              onToggle: toggleItem,
              onEdit: widget.onEdit,
              onDelete: widget.onDelete,
            ),
        ],
      ],
    );
  }
}

enum ShoppingSourceFilter { all, manual, generated }

class _ShoppingSourceFilterChips extends StatelessWidget {
  const _ShoppingSourceFilterChips({
    required this.selectedFilter,
    required this.totalCount,
    required this.manualCount,
    required this.generatedCount,
    required this.onSelected,
  });

  final ShoppingSourceFilter selectedFilter;
  final int totalCount;
  final int manualCount;
  final int generatedCount;
  final void Function(ShoppingSourceFilter filter) onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          selected: selectedFilter == ShoppingSourceFilter.all,
          label: Text('${context.l10n.allShoppingItems} $totalCount'),
          onSelected: (_) => onSelected(ShoppingSourceFilter.all),
        ),
        FilterChip(
          selected: selectedFilter == ShoppingSourceFilter.manual,
          label: Text('${context.l10n.manual} $manualCount'),
          onSelected: (_) => onSelected(ShoppingSourceFilter.manual),
        ),
        FilterChip(
          selected: selectedFilter == ShoppingSourceFilter.generated,
          label: Text('${context.l10n.generated} $generatedCount'),
          onSelected: (_) => onSelected(ShoppingSourceFilter.generated),
        ),
      ],
    );
  }
}

class _NoShoppingFilterResultsCard extends StatelessWidget {
  const _NoShoppingFilterResultsCard({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.filter_alt_off_outlined,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.noShoppingItemsForFilter,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.noShoppingItemsForFilterSubtitle,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: onClear,
                    icon: const Icon(Icons.clear),
                    label: Text(context.l10n.clearFilter),
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

class _ShoppingSummaryCard extends StatelessWidget {
  const _ShoppingSummaryCard({
    required this.totalCount,
    required this.toBuyCount,
    required this.boughtCount,
    required this.generatedCount,
    required this.hasEstimatedPrices,
    required this.totalEstimatedCost,
    required this.toBuyEstimatedCost,
    required this.currency,
  });

  final int totalCount;
  final int toBuyCount;
  final int boughtCount;
  final int generatedCount;
  final bool hasEstimatedPrices;
  final double totalEstimatedCost;
  final double toBuyEstimatedCost;
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
                  AppMetaPill(
                    label: context.l10n.toBuySummary(toBuyCount),
                    icon: Icons.shopping_cart_outlined,
                  ),
                  AppMetaPill(
                    label: context.l10n.boughtSummary(boughtCount),
                    icon: Icons.shopping_cart_checkout,
                  ),
                  AppMetaPill(
                    label: context.l10n.generatedSummary(generatedCount),
                    icon: Icons.auto_awesome_outlined,
                  ),
                  AppMetaPill(
                    label: context.l10n.totalCountSummary(totalCount),
                    icon: Icons.list_alt_outlined,
                  ),
                  if (hasEstimatedPrices)
                    AppMetaPill(
                      label: context.l10n.toBuyEstimated(
                        AppMoneyFormatting.format(toBuyEstimatedCost, currency),
                      ),
                      icon: Icons.euro_outlined,
                    ),
                  if (hasEstimatedPrices)
                    AppMetaPill(
                      label: context.l10n.totalEstimated(
                        AppMoneyFormatting.format(totalEstimatedCost, currency),
                      ),
                      icon: Icons.receipt_long_outlined,
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

  List<Map<String, dynamic>> get manualItems {
    return items.where((item) => !isGeneratedItem(item)).toList();
  }

  List<Map<String, dynamic>> get generatedItems {
    return items.where(isGeneratedItem).toList();
  }

  bool isGeneratedItem(Map<String, dynamic> item) {
    final value = item[AppShoppingItemFields.sourceMealPlanId]?.toString();
    return value != null && value.isNotEmpty;
  }

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
              context.l10n.sectionCount(title, items.length),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (manualItems.isNotEmpty)
          _ShoppingSourceGroup(
            title: context.l10n.manualShoppingItems,
            icon: Icons.edit_note_outlined,
            items: manualItems,
            onToggle: onToggle,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
        if (manualItems.isNotEmpty && generatedItems.isNotEmpty)
          const SizedBox(height: 10),
        if (generatedItems.isNotEmpty)
          _ShoppingSourceGroup(
            title: context.l10n.generatedShoppingItems,
            icon: Icons.auto_awesome_outlined,
            items: generatedItems,
            onToggle: onToggle,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
      ],
    );
  }
}

class _ShoppingSourceGroup extends StatelessWidget {
  const _ShoppingSourceGroup({
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.32,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 8),
            child: Row(
              children: [
                Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  context.l10n.sectionCount(title, items.length),
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          for (final item in items)
            UnreadItemHighlight(
              item: item,
              child: ShoppingItemCard(
                item: item,
                onToggle: () => onToggle(item),
                onEdit: () => onEdit(item),
                onDelete: () {
                  onDelete(item[AppShoppingItemFields.id].toString());
                },
              ),
            ),
        ],
      ),
    );
  }
}
