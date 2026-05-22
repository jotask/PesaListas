import 'package:flutter/material.dart';
import 'package:pesalistas/core/book_reading_status.dart';
import 'package:pesalistas/core/fields/item_fields.dart';
import 'package:pesalistas/widgets/common/app_meta_pill.dart';
import 'package:pesalistas/widgets/list_detail/book_item_card.dart';
import 'package:pesalistas/widgets/list_detail/empty_items_card.dart';

class BooksItemsView extends StatefulWidget {
  const BooksItemsView({
    super.key,
    required this.items,
    required this.loading,
    required this.onCreate,
    required this.onComplete,
    required this.onReopen,
    required this.onEdit,
    required this.onDelete,
    required this.onVote,
    required this.onViewVotes,
    required this.onStatusChanged,
  });

  final List<Map<String, dynamic>> items;
  final bool loading;
  final VoidCallback onCreate;
  final void Function(String itemId) onComplete;
  final void Function(String itemId) onReopen;
  final void Function(Map<String, dynamic> item) onEdit;
  final void Function(String itemId) onDelete;
  final void Function(Map<String, dynamic> item) onVote;
  final void Function(Map<String, dynamic> item) onViewVotes;
  final void Function({
    required Map<String, dynamic> item,
    required String status,
  })
  onStatusChanged;

  @override
  State<BooksItemsView> createState() => _BooksItemsViewState();
}

class _BooksItemsViewState extends State<BooksItemsView> {
  BookStatusFilter selectedFilter = BookStatusFilter.all;

  String statusFor(Map<String, dynamic> item) {
    return AppBookReadingStatus.normalize(item[AppItemFields.status]);
  }

  List<Map<String, dynamic>> get filteredItems {
    switch (selectedFilter) {
      case BookStatusFilter.all:
        return widget.items;

      case BookStatusFilter.wishlist:
        return widget.items
            .where((item) => statusFor(item) == AppBookReadingStatus.wishlist)
            .toList();

      case BookStatusFilter.toRead:
        return widget.items
            .where((item) => statusFor(item) == AppBookReadingStatus.toRead)
            .toList();

      case BookStatusFilter.reading:
        return widget.items
            .where((item) => statusFor(item) == AppBookReadingStatus.reading)
            .toList();

      case BookStatusFilter.done:
        return widget.items
            .where((item) => statusFor(item) == AppBookReadingStatus.done)
            .toList();
    }
  }

  int countFor(String status) {
    return widget.items.where((item) => statusFor(item) == status).length;
  }

  void selectFilter(BookStatusFilter filter) {
    setState(() => selectedFilter = filter);
  }

  void clearFilter() {
    setState(() => selectedFilter = BookStatusFilter.all);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.items.isEmpty) {
      return EmptyItemsCard(
        icon: Icons.menu_book_outlined,
        title: 'No books yet',
        subtitle: 'Add your first book to read.',
        onCreate: widget.onCreate,
      );
    }

    final visibleItems = filteredItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BooksSummaryCard(
          wishlistCount: countFor(AppBookReadingStatus.wishlist),
          toReadCount: countFor(AppBookReadingStatus.toRead),
          readingCount: countFor(AppBookReadingStatus.reading),
          doneCount: countFor(AppBookReadingStatus.done),
          totalCount: widget.items.length,
        ),
        const SizedBox(height: 12),
        _BookStatusFilterChips(
          selectedFilter: selectedFilter,
          totalCount: widget.items.length,
          wishlistCount: countFor(AppBookReadingStatus.wishlist),
          toReadCount: countFor(AppBookReadingStatus.toRead),
          readingCount: countFor(AppBookReadingStatus.reading),
          doneCount: countFor(AppBookReadingStatus.done),
          onSelected: selectFilter,
        ),
        const SizedBox(height: 12),
        if (visibleItems.isEmpty)
          _NoBookFilterResultsCard(onClear: clearFilter)
        else
          for (final item in visibleItems)
            BookItemCard(
              item: item,
              fallbackTitle: 'Book',
              onEdit: () => widget.onEdit(item),
              onVote: () => widget.onVote(item),
              onViewVotes: () => widget.onViewVotes(item),
              onDelete: () =>
                  widget.onDelete(item[AppItemFields.id].toString()),
              onStatusChanged: (status) {
                widget.onStatusChanged(item: item, status: status);
              },
            ),
      ],
    );
  }
}

enum BookStatusFilter { all, wishlist, toRead, reading, done }

class _BooksSummaryCard extends StatelessWidget {
  const _BooksSummaryCard({
    required this.wishlistCount,
    required this.toReadCount,
    required this.readingCount,
    required this.doneCount,
    required this.totalCount,
  });

  final int wishlistCount;
  final int toReadCount;
  final int readingCount;
  final int doneCount;
  final int totalCount;

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
                Icons.menu_book_outlined,
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
                    icon: Icons.bookmark_border_outlined,
                    label: '$wishlistCount wishlist',
                  ),
                  AppMetaPill(
                    icon: Icons.menu_book_outlined,
                    label: '$toReadCount to read',
                  ),
                  AppMetaPill(
                    icon: Icons.auto_stories_outlined,
                    label: '$readingCount reading',
                  ),
                  AppMetaPill(
                    icon: Icons.done_all_outlined,
                    label: '$doneCount done',
                  ),
                  AppMetaPill(
                    icon: Icons.list_alt_outlined,
                    label: '$totalCount total',
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

class _BookStatusFilterChips extends StatelessWidget {
  const _BookStatusFilterChips({
    required this.selectedFilter,
    required this.totalCount,
    required this.wishlistCount,
    required this.toReadCount,
    required this.readingCount,
    required this.doneCount,
    required this.onSelected,
  });

  final BookStatusFilter selectedFilter;
  final int totalCount;
  final int wishlistCount;
  final int toReadCount;
  final int readingCount;
  final int doneCount;
  final void Function(BookStatusFilter filter) onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          selected: selectedFilter == BookStatusFilter.all,
          label: Text('All $totalCount'),
          onSelected: (_) => onSelected(BookStatusFilter.all),
        ),
        FilterChip(
          selected: selectedFilter == BookStatusFilter.wishlist,
          label: Text('Wishlist $wishlistCount'),
          onSelected: (_) => onSelected(BookStatusFilter.wishlist),
        ),
        FilterChip(
          selected: selectedFilter == BookStatusFilter.toRead,
          label: Text('To read $toReadCount'),
          onSelected: (_) => onSelected(BookStatusFilter.toRead),
        ),
        FilterChip(
          selected: selectedFilter == BookStatusFilter.reading,
          label: Text('Reading $readingCount'),
          onSelected: (_) => onSelected(BookStatusFilter.reading),
        ),
        FilterChip(
          selected: selectedFilter == BookStatusFilter.done,
          label: Text('Done $doneCount'),
          onSelected: (_) => onSelected(BookStatusFilter.done),
        ),
      ],
    );
  }
}

class _NoBookFilterResultsCard extends StatelessWidget {
  const _NoBookFilterResultsCard({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const CircleAvatar(child: Icon(Icons.filter_alt_off_outlined)),
            const SizedBox(width: 12),
            const Expanded(child: Text('No books match this filter.')),
            OutlinedButton(onPressed: onClear, child: const Text('Show all')),
          ],
        ),
      ),
    );
  }
}
