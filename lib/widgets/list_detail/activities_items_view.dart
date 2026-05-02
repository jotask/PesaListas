import 'package:flutter/material.dart';
import 'package:pesalistas/widgets/list_detail/votable_items_view.dart';

class ActivitiesItemsView extends StatelessWidget {
  const ActivitiesItemsView({
    super.key,
    required this.items,
    required this.loading,
    required this.onCreate,
    required this.onComplete,
    required this.onEdit,
    required this.onDelete,
    required this.onVote,
    required this.onViewVotes,
  });

  final List<Map<String, dynamic>> items;
  final bool loading;
  final VoidCallback onCreate;
  final void Function(String itemId) onComplete;
  final void Function(Map<String, dynamic> item) onEdit;
  final void Function(String itemId) onDelete;
  final void Function(Map<String, dynamic> item) onVote;
  final void Function(Map<String, dynamic> item) onViewVotes;

  @override
  Widget build(BuildContext context) {
    return VotableItemsView(
      items: items,
      loading: loading,
      emptyIcon: Icons.local_activity_outlined,
      emptyTitle: 'No activities yet',
      emptySubtitle: 'Add something fun to do.',
      cardIcon: Icons.local_activity_outlined,
      fallbackTitle: 'Untitled activity',
      onCreate: onCreate,
      onEdit: onEdit,
      onDelete: onDelete,
      onVote: onVote,
      onViewVotes: onViewVotes,
    );
  }
}
