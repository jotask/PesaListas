import 'package:flutter/material.dart';
import 'package:pesalistas/core/item_fields.dart';
import 'package:pesalistas/widgets/list_detail/empty_items_card.dart';
import 'package:pesalistas/widgets/list_detail/votable_item_card.dart';

class VotableItemsView extends StatelessWidget {
  const VotableItemsView({
    super.key,
    required this.items,
    required this.loading,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.cardIcon,
    required this.fallbackTitle,
    required this.onCreate,
    required this.onEdit,
    required this.onDelete,
    required this.onVote,
    required this.onViewVotes,
  });

  final List<Map<String, dynamic>> items;
  final bool loading;

  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;

  final IconData cardIcon;
  final String fallbackTitle;

  final VoidCallback onCreate;
  final void Function(Map<String, dynamic> item) onEdit;
  final void Function(String itemId) onDelete;
  final void Function(Map<String, dynamic> item) onVote;
  final void Function(Map<String, dynamic> item) onViewVotes;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return EmptyItemsCard(
        icon: emptyIcon,
        title: emptyTitle,
        subtitle: emptySubtitle,
        onCreate: onCreate,
      );
    }

    return Column(
      children: [
        for (final item in items)
          VotableItemCard(
            item: item,
            icon: cardIcon,
            fallbackTitle: fallbackTitle,
            onEdit: () => onEdit(item),
            onVote: () => onVote(item),
            onViewVotes: () => onViewVotes(item),
            onDelete: () => onDelete(item[AppItemFields.id].toString()),
          ),
      ],
    );
  }
}
