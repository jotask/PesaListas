import 'package:flutter/material.dart';

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
    return Card(
      child: ListTile(
        onTap: onEdit,
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(item['title'] ?? fallbackTitle),
        subtitle: Text(item['description'] ?? 'Tap to edit'),
        trailing: Wrap(
          spacing: 4,
          children: [
            IconButton(
              icon: const Icon(Icons.stars_outlined),
              onPressed: onVote,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
