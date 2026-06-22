import 'package:flutter/material.dart';
import 'package:pesalistas/core/design/app_radius.dart';
import 'package:pesalistas/core/design/app_spacing.dart';
import 'package:pesalistas/core/fields/shopping_item_fields.dart';
import 'package:pesalistas/core/shopping_stores.dart';
import 'package:pesalistas/core/value_parsing.dart';
import 'package:pesalistas/widgets/design/app_surface.dart';
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
  String? selectedStoreLabel;

  List<String> get availableStoreLabels {
    final labels = widget.items.map(storeLabelForItem).toSet().toList();

    labels.sort((a, b) {
      if (a == 'No store') return 1;
      if (b == 'No store') return -1;
      return a.compareTo(b);
    });

    return labels;
  }

  String? get activeStoreLabel {
    final selected = selectedStoreLabel;

    if (selected == null) return null;
    if (!availableStoreLabels.contains(selected)) return null;

    return selected;
  }

  List<Map<String, dynamic>> get visibleItems {
    final store = activeStoreLabel;

    if (store == null) return widget.items;

    return widget.items.where((item) {
      return storeLabelForItem(item) == store;
    }).toList();
  }

  List<Map<String, dynamic>> get toBuyItems {
    return visibleItems.where((item) {
      return item[AppShoppingItemFields.checked] != true;
    }).toList();
  }

  List<Map<String, dynamic>> get boughtItems {
    return visibleItems.where((item) {
      return item[AppShoppingItemFields.checked] == true;
    }).toList();
  }

  int get allToBuyCount {
    return widget.items.where((item) {
      return item[AppShoppingItemFields.checked] != true;
    }).length;
  }

  int get allBoughtCount {
    return widget.items.where((item) {
      return item[AppShoppingItemFields.checked] == true;
    }).length;
  }

  int get visibleToBuyCount => toBuyItems.length;

  int get visibleBoughtCount => boughtItems.length;

  double get progress {
    final total = allToBuyCount + allBoughtCount;
    if (total == 0) return 0;
    return allBoughtCount / total;
  }

  bool isChecked(Map<String, dynamic> item) {
    return item[AppShoppingItemFields.checked] == true;
  }

  void toggleItem(Map<String, dynamic> item) {
    final itemId = item[AppShoppingItemFields.id].toString();

    if (isChecked(item)) {
      widget.onReopen(itemId);
    } else {
      widget.onComplete(itemId);
    }
  }

  String storeLabelForItem(Map<String, dynamic> item) {
    final explicitName = AppValueParsing.textOrNull(
      item[AppShoppingItemFields.storeName],
    );

    if (explicitName != null && explicitName.trim().isNotEmpty) {
      return explicitName.trim();
    }

    final storeKey = AppValueParsing.textOrNull(
      item[AppShoppingItemFields.storeKey],
    );

    if (storeKey == null || storeKey.trim().isEmpty) {
      return 'No store';
    }

    return AppShoppingStores.label(storeKey);
  }

  Map<String, List<Map<String, dynamic>>> groupItemsByStore(
    List<Map<String, dynamic>> sourceItems,
  ) {
    final grouped = <String, List<Map<String, dynamic>>>{};

    for (final item in sourceItems) {
      final store = storeLabelForItem(item);
      grouped.putIfAbsent(store, () => []);
      grouped[store]!.add(item);
    }

    return grouped;
  }

  void selectStore(String? store) {
    setState(() => selectedStoreLabel = store);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.items.isEmpty) {
      return EmptyItemsCard(
        icon: Icons.shopping_bag_outlined,
        title: 'No shopping items yet',
        subtitle: 'Add what you need to buy or generate a list from meals.',
        onCreate: widget.onCreate,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ShoppingSummaryCard(
          progress: progress,
          allToBuyCount: allToBuyCount,
          allBoughtCount: allBoughtCount,
          storeCount: availableStoreLabels.length,
          onClearBought: allBoughtCount == 0 ? null : widget.onClearBought,
          onClearAll: widget.onClearAll,
        ),
        const SizedBox(height: AppSpacing.md),
        _ShoppingStoreFilter(
          selectedStoreLabel: activeStoreLabel,
          storeLabels: availableStoreLabels,
          visibleToBuyCount: visibleToBuyCount,
          visibleBoughtCount: visibleBoughtCount,
          onSelected: selectStore,
        ),
        const SizedBox(height: AppSpacing.md),
        if (toBuyItems.isEmpty && activeStoreLabel != null)
          _NoStoreItemsCard(
            storeName: activeStoreLabel!,
            onShowAllStores: () => selectStore(null),
          )
        else ...[
          if (toBuyItems.isNotEmpty)
            _ShoppingSection(
              title: 'To buy',
              icon: Icons.shopping_bag_outlined,
              itemsByStore: groupItemsByStore(toBuyItems),
              showStoreHeaders: activeStoreLabel == null,
              onToggle: toggleItem,
              onEdit: widget.onEdit,
              onDelete: widget.onDelete,
            ),
          if (toBuyItems.isNotEmpty && boughtItems.isNotEmpty)
            const SizedBox(height: AppSpacing.lg),
          if (boughtItems.isNotEmpty)
            _ShoppingSection(
              title: 'Bought',
              icon: Icons.shopping_cart_checkout_rounded,
              itemsByStore: groupItemsByStore(boughtItems),
              showStoreHeaders: activeStoreLabel == null,
              onToggle: toggleItem,
              onEdit: widget.onEdit,
              onDelete: widget.onDelete,
            ),
        ],
      ],
    );
  }
}

class _ShoppingSummaryCard extends StatelessWidget {
  const _ShoppingSummaryCard({
    required this.progress,
    required this.allToBuyCount,
    required this.allBoughtCount,
    required this.storeCount,
    required this.onClearBought,
    required this.onClearAll,
  });

  final double progress;
  final int allToBuyCount;
  final int allBoughtCount;
  final int storeCount;
  final VoidCallback? onClearBought;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = (progress * 100).round();

    return AppSurface(
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.38),
      borderColor: theme.colorScheme.primary.withValues(alpha: 0.16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.shopping_basket_rounded,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shopping trip',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$allToBuyCount left • $allBoughtCount bought • $storeCount stores',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$percentage%',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              PopupMenuButton<_ShoppingListAction>(
                tooltip: 'Shopping actions',
                onSelected: (action) {
                  switch (action) {
                    case _ShoppingListAction.clearBought:
                      onClearBought?.call();
                      break;
                    case _ShoppingListAction.clearAll:
                      onClearAll();
                      break;
                  }
                },
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      value: _ShoppingListAction.clearBought,
                      enabled: onClearBought != null,
                      child: const Text('Clear bought items'),
                    ),
                    const PopupMenuItem(
                      value: _ShoppingListAction.clearAll,
                      child: Text('Clear all items'),
                    ),
                  ];
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: theme.colorScheme.surface.withValues(
                alpha: 0.75,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShoppingStoreFilter extends StatelessWidget {
  const _ShoppingStoreFilter({
    required this.selectedStoreLabel,
    required this.storeLabels,
    required this.visibleToBuyCount,
    required this.visibleBoughtCount,
    required this.onSelected,
  });

  final String? selectedStoreLabel;
  final List<String> storeLabels;
  final int visibleToBuyCount;
  final int visibleBoughtCount;
  final void Function(String? store) onSelected;

  String get summary {
    return '$visibleToBuyCount to buy • $visibleBoughtCount bought';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppSurface(
      padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
      child: Row(
        children: [
          Icon(Icons.storefront_outlined, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: selectedStoreLabel,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text(
                      'All stores',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  for (final store in storeLabels)
                    DropdownMenuItem<String?>(value: store, child: Text(store)),
                ],
                onChanged: onSelected,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            summary,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
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
    required this.itemsByStore,
    required this.showStoreHeaders,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final String title;
  final IconData icon;
  final Map<String, List<Map<String, dynamic>>> itemsByStore;
  final bool showStoreHeaders;
  final void Function(Map<String, dynamic> item) onToggle;
  final void Function(Map<String, dynamic> item) onEdit;
  final void Function(String itemId) onDelete;

  int get totalCount {
    return itemsByStore.values.fold<int>(
      0,
      (total, items) => total + items.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final storeEntries = itemsByStore.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 19, color: theme.colorScheme.primary),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '$title ($totalCount)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final storeEntry in storeEntries) ...[
          if (showStoreHeaders)
            _StoreShoppingGroup(
              storeName: storeEntry.key,
              items: storeEntry.value,
              onToggle: onToggle,
              onEdit: onEdit,
              onDelete: onDelete,
            )
          else
            for (final item in storeEntry.value)
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
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _StoreShoppingGroup extends StatelessWidget {
  const _StoreShoppingGroup({
    required this.storeName,
    required this.items,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final String storeName;
  final List<Map<String, dynamic>> items;
  final void Function(Map<String, dynamic> item) onToggle;
  final void Function(Map<String, dynamic> item) onEdit;
  final void Function(String itemId) onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppSurface(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 2),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.28),
      borderColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.42),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Row(
              children: [
                Icon(
                  Icons.storefront_outlined,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  '$storeName (${items.length})',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
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

class _NoStoreItemsCard extends StatelessWidget {
  const _NoStoreItemsCard({
    required this.storeName,
    required this.onShowAllStores,
  });

  final String storeName;
  final VoidCallback onShowAllStores;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      child: Row(
        children: [
          const Icon(Icons.shopping_bag_outlined, size: 34),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nothing to buy at $storeName',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Switch back to all stores to see the full shopping list.',
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: onShowAllStores,
                  icon: const Icon(Icons.storefront_outlined),
                  label: const Text('Show all stores'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _ShoppingListAction { clearBought, clearAll }
