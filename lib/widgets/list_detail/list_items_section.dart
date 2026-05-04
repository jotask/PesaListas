import 'package:flutter/material.dart';
import 'package:pesalistas/core/item_fields.dart';
import 'package:pesalistas/core/item_status.dart';
import 'package:pesalistas/core/list_types.dart';
import 'package:pesalistas/core/shopping_item_fields.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/widgets/list_detail/items_view_factory.dart';

class ListItemsSection extends StatefulWidget {
  const ListItemsSection({
    super.key,
    required this.listType,
    required this.items,
    required this.loading,
    required this.showStatusSummary,
    required this.onCreate,
    required this.onComplete,
    required this.onReopen,
    required this.onEdit,
    required this.onDelete,
    required this.onVote,
    required this.onViewVotes,
    required this.onViewRecipeDetails,
    required this.onDeleteRecipe,
    required this.onGenerateShoppingFromMealPlans,
    required this.onClearBoughtShoppingItems,
    required this.onClearAllShoppingItems,
  });

  final String listType;
  final List<Map<String, dynamic>> items;
  final bool loading;
  final bool showStatusSummary;

  final VoidCallback onCreate;
  final void Function(String itemId) onComplete;
  final void Function(String itemId) onReopen;
  final void Function(Map<String, dynamic> item) onEdit;
  final void Function(String itemId) onDelete;
  final void Function(Map<String, dynamic> item) onVote;
  final void Function(Map<String, dynamic> item) onViewVotes;
  final void Function(Map<String, dynamic> recipe) onViewRecipeDetails;
  final void Function(String recipeId) onDeleteRecipe;
  final VoidCallback onGenerateShoppingFromMealPlans;
  final VoidCallback onClearBoughtShoppingItems;
  final VoidCallback onClearAllShoppingItems;

  @override
  State<ListItemsSection> createState() => _ListItemsSectionState();
}

class _ListItemsSectionState extends State<ListItemsSection> {
  ItemStatusFilter selectedFilter = ItemStatusFilter.all;

  int get totalCount => widget.items.length;

  int get doneCount {
    return widget.items.where(isItemDone).length;
  }

  int get openCount {
    return totalCount - doneCount;
  }

  List<Map<String, dynamic>> get filteredItems {
    if (!widget.showStatusSummary) {
      return widget.items;
    }

    switch (selectedFilter) {
      case ItemStatusFilter.all:
        return widget.items;

      case ItemStatusFilter.open:
        return widget.items.where((item) => !isItemDone(item)).toList();

      case ItemStatusFilter.done:
        return widget.items.where(isItemDone).toList();
    }
  }

  bool get hasActiveFilter {
    return widget.showStatusSummary && selectedFilter != ItemStatusFilter.all;
  }

  String get emptyFilteredTitle {
    switch (selectedFilter) {
      case ItemStatusFilter.all:
        return context.l10n.noItemsYet;

      case ItemStatusFilter.open:
        return context.l10n.noOpenItems;

      case ItemStatusFilter.done:
        return context.l10n.noDoneItems;
    }
  }

  String get emptyFilteredSubtitle {
    switch (selectedFilter) {
      case ItemStatusFilter.all:
        return context.l10n.addYourFirstItem;

      case ItemStatusFilter.open:
        return context.l10n.everythingInThisListIsDone;

      case ItemStatusFilter.done:
        return context.l10n.nothingHasBeenCompletedYet;
    }
  }

  void selectFilter(ItemStatusFilter filter) {
    setState(() => selectedFilter = filter);
  }

  void clearFilter() {
    setState(() => selectedFilter = ItemStatusFilter.all);
  }

  bool isItemDone(Map<String, dynamic> item) {
    if (widget.listType == AppListTypes.shopping.value) {
      return item[AppShoppingItemFields.checked] == true;
    }

    return AppItemStatus.isDone(item[AppItemFields.status]);
  }

  @override
  Widget build(BuildContext context) {
    final visibleItems = filteredItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showStatusSummary) ...[
          _StatusFilterChips(
            selectedFilter: selectedFilter,
            totalCount: totalCount,
            openCount: openCount,
            doneCount: doneCount,
            onSelected: selectFilter,
          ),
          const SizedBox(height: 12),
        ],
        if (!widget.loading &&
            widget.items.isNotEmpty &&
            visibleItems.isEmpty &&
            hasActiveFilter)
          _NoFilteredItemsCard(
            title: emptyFilteredTitle,
            subtitle: emptyFilteredSubtitle,
            onClearFilter: clearFilter,
          )
        else
          ItemsViewFactory(
            listType: widget.listType,
            items: visibleItems,
            loading: widget.loading,
            onCreate: widget.onCreate,
            onComplete: widget.onComplete,
            onReopen: widget.onReopen,
            onEdit: widget.onEdit,
            onDelete: widget.onDelete,
            onVote: widget.onVote,
            onViewVotes: widget.onViewVotes,
            onViewRecipeDetails: widget.onViewRecipeDetails,
            onDeleteRecipe: widget.onDeleteRecipe,
            onGenerateShoppingFromMealPlans:
                widget.onGenerateShoppingFromMealPlans,
            onClearAll: widget.onClearAllShoppingItems,
          ),
      ],
    );
  }
}

enum ItemStatusFilter { all, open, done }

class _StatusFilterChips extends StatelessWidget {
  const _StatusFilterChips({
    required this.selectedFilter,
    required this.totalCount,
    required this.openCount,
    required this.doneCount,
    required this.onSelected,
  });

  final ItemStatusFilter selectedFilter;
  final int totalCount;
  final int openCount;
  final int doneCount;
  final void Function(ItemStatusFilter filter) onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          selected: selectedFilter == ItemStatusFilter.all,
          label: Text(context.l10n.allCount(totalCount)),
          onSelected: (_) => onSelected(ItemStatusFilter.all),
        ),
        FilterChip(
          selected: selectedFilter == ItemStatusFilter.open,
          label: Text(context.l10n.openCount(openCount)),
          onSelected: (_) => onSelected(ItemStatusFilter.open),
        ),
        FilterChip(
          selected: selectedFilter == ItemStatusFilter.done,
          label: Text(context.l10n.doneCount(doneCount)),
          onSelected: (_) => onSelected(ItemStatusFilter.done),
        ),
      ],
    );
  }
}

class _NoFilteredItemsCard extends StatelessWidget {
  const _NoFilteredItemsCard({
    required this.title,
    required this.subtitle,
    required this.onClearFilter,
  });

  final String title;
  final String subtitle;
  final VoidCallback onClearFilter;

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
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: onClearFilter,
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
