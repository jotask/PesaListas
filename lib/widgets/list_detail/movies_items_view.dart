import 'package:flutter/material.dart';
import 'package:pesalistas/widgets/list_detail/votable_items_view.dart';

class MovieItemsView extends StatelessWidget {
  const MovieItemsView({
    super.key,
    required this.items,
    required this.loading,
    required this.onCreate,
    required this.onComplete,
    required this.onEdit,
    required this.onDelete,
    required this.onVote,
  });

  final List<Map<String, dynamic>> items;
  final bool loading;
  final VoidCallback onCreate;
  final void Function(String itemId) onComplete;
  final void Function(Map<String, dynamic> item) onEdit;
  final void Function(String itemId) onDelete;
  final void Function(Map<String, dynamic> item) onVote;

  @override
  Widget build(BuildContext context) {
    return VotableItemsView(
      items: items,
      loading: loading,
      emptyIcon: Icons.movie,
      emptyTitle: 'No movies yet',
      emptySubtitle: 'Add a movie to watch.',
      cardIcon: Icons.movie,
      fallbackTitle: 'Untitled movie',
      onCreate: onCreate,
      onEdit: onEdit,
      onDelete: onDelete,
      onVote: onVote,
    );
  }
}
