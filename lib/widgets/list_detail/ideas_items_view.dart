import 'package:flutter/material.dart';
import 'package:pesalistas/widgets/common/empty_info_card.dart';
import 'package:pesalistas/widgets/list_detail/votable_item_card.dart';

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
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return EmptyInfoCard(
        icon: Icons.lightbulb_outline,
        title: 'No ideas yet',
        subtitle: 'Add your first idea.',
        trailing: const Icon(Icons.add),
        onTap: onCreate,
      );
    }

    return Column(
      children: [
        for (final item in items)
          VotableItemCard(
            item: item,
            icon: Icons.lightbulb_outline,
            fallbackTitle: 'Untitled idea',
            onEdit: () => onEdit(item),
            onVote: () => onVote(item),
            onDelete: () => onDelete(item['id']),
          ),
      ],
    );
  }
}
