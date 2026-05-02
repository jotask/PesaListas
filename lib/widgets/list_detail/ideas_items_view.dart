import 'package:flutter/material.dart';
import 'package:pesalistas/widgets/list_detail/votable_items_view.dart';

class IdeasItemsView extends StatelessWidget {
  const IdeasItemsView({
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
      emptyIcon: Icons.lightbulb_outline,
      emptyTitle: 'No ideas yet',
      emptySubtitle: 'Add your first idea.',
      cardIcon: Icons.lightbulb_outline,
      fallbackTitle: 'Untitled idea',
      onCreate: onCreate,
      onEdit: onEdit,
      onDelete: onDelete,
      onVote: onVote,
    );
  }
}
