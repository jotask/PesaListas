import 'package:flutter/material.dart';
import 'package:pesalistas/core/fields/item_fields.dart';
import 'package:pesalistas/core/item_status.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/widgets/common/app_meta_pill.dart';
import 'package:pesalistas/widgets/list_detail/empty_items_card.dart';
import 'package:pesalistas/widgets/list_detail/movie_item_card.dart';

class MovieItemsView extends StatefulWidget {
  const MovieItemsView({
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

  @override
  State<MovieItemsView> createState() => _MovieItemsViewState();
}

class _MovieItemsViewState extends State<MovieItemsView> {
  MovieStatusFilter selectedFilter = MovieStatusFilter.all;

  bool isWatched(Map<String, dynamic> item) {
    return item[AppItemFields.status]?.toString() == AppItemStatus.done;
  }

  List<Map<String, dynamic>> get filteredItems {
    switch (selectedFilter) {
      case MovieStatusFilter.all:
        return widget.items;

      case MovieStatusFilter.toWatch:
        return widget.items.where((item) => !isWatched(item)).toList();

      case MovieStatusFilter.watched:
        return widget.items.where(isWatched).toList();
    }
  }

  int get toWatchCount {
    return widget.items.where((item) => !isWatched(item)).length;
  }

  int get watchedCount {
    return widget.items.where(isWatched).length;
  }

  void selectFilter(MovieStatusFilter filter) {
    setState(() => selectedFilter = filter);
  }

  void clearFilter() {
    setState(() => selectedFilter = MovieStatusFilter.all);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.items.isEmpty) {
      return EmptyItemsCard(
        icon: Icons.movie,
        title: context.l10n.noMoviesYet,
        subtitle: context.l10n.addAMovieToWatch,
        onCreate: widget.onCreate,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MovieSummaryCard(
          totalCount: widget.items.length,
          toWatchCount: toWatchCount,
          watchedCount: watchedCount,
        ),
        const SizedBox(height: 12),
        _MovieStatusFilterChips(
          selectedFilter: selectedFilter,
          totalCount: widget.items.length,
          toWatchCount: toWatchCount,
          watchedCount: watchedCount,
          onSelected: selectFilter,
        ),
        const SizedBox(height: 12),
        if (filteredItems.isEmpty)
          _NoMovieFilterResultsCard(onClear: clearFilter)
        else
          for (final item in filteredItems)
            MovieItemCard(
              item: item,
              fallbackTitle: context.l10n.untitledMovie,
              onEdit: () => widget.onEdit(item),
              onVote: () => widget.onVote(item),
              onViewVotes: () => widget.onViewVotes(item),
              onMarkWatched: () {
                widget.onComplete(item[AppItemFields.id].toString());
              },
              onMarkToWatch: () {
                widget.onReopen(item[AppItemFields.id].toString());
              },
              onDelete: () {
                widget.onDelete(item[AppItemFields.id].toString());
              },
            ),
      ],
    );
  }
}

enum MovieStatusFilter { all, toWatch, watched }

class _MovieSummaryCard extends StatelessWidget {
  const _MovieSummaryCard({
    required this.totalCount,
    required this.toWatchCount,
    required this.watchedCount,
  });

  final int totalCount;
  final int toWatchCount;
  final int watchedCount;

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
                Icons.local_movies_outlined,
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
                    icon: Icons.movie_filter_outlined,
                    label: '$toWatchCount to watch',
                  ),
                  AppMetaPill(
                    icon: Icons.done_all_outlined,
                    label: '$watchedCount watched',
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

class _MovieStatusFilterChips extends StatelessWidget {
  const _MovieStatusFilterChips({
    required this.selectedFilter,
    required this.totalCount,
    required this.toWatchCount,
    required this.watchedCount,
    required this.onSelected,
  });

  final MovieStatusFilter selectedFilter;
  final int totalCount;
  final int toWatchCount;
  final int watchedCount;
  final void Function(MovieStatusFilter filter) onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          selected: selectedFilter == MovieStatusFilter.all,
          label: Text('All $totalCount'),
          onSelected: (_) => onSelected(MovieStatusFilter.all),
        ),
        FilterChip(
          selected: selectedFilter == MovieStatusFilter.toWatch,
          label: Text('To watch $toWatchCount'),
          onSelected: (_) => onSelected(MovieStatusFilter.toWatch),
        ),
        FilterChip(
          selected: selectedFilter == MovieStatusFilter.watched,
          label: Text('Watched $watchedCount'),
          onSelected: (_) => onSelected(MovieStatusFilter.watched),
        ),
      ],
    );
  }
}

class _NoMovieFilterResultsCard extends StatelessWidget {
  const _NoMovieFilterResultsCard({required this.onClear});

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
                  const Text(
                    'No movies for this filter',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Try another filter or add a new movie.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: onClear,
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear filter'),
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
