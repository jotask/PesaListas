import 'package:flutter/material.dart';
import 'package:pesalistas/widgets/list_detail/base_item_card.dart';

class VotableItemCard extends StatelessWidget {
  const VotableItemCard({
    super.key,
    required this.item,
    required this.icon,
    required this.fallbackTitle,
    required this.onEdit,
    required this.onVote,
    required this.onDelete,
  });

  final Map<String, dynamic> item;
  final IconData icon;
  final String fallbackTitle;
  final VoidCallback onEdit;
  final VoidCallback onVote;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final title = item['title']?.toString();
    final description = item['description']?.toString();

    return BaseItemCard(
      title: title,
      fallbackTitle: fallbackTitle,
      subtitle: description == null || description.isEmpty
          ? 'Tap to edit'
          : description,
      icon: icon,
      onTap: onEdit,
      actions: [
        IconButton(
          icon: const Icon(Icons.stars_outlined),
          onPressed: onVote,
          tooltip: 'Vote',
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
          tooltip: 'Delete item',
        ),
      ],
    );
  }
}
