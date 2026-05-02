import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.item,
    required this.onComplete,
    required this.onDelete,
    required this.onEdit,
  });

  final Map<String, dynamic> item;
  final VoidCallback onComplete;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final isDone = item['status'] == 'done';

    return Card(
      child: ListTile(
        onTap: onEdit,
        leading: IconButton(
          icon: Icon(
            isDone ? Icons.check_circle : Icons.radio_button_unchecked,
          ),
          onPressed: isDone ? null : onComplete,
        ),
        title: Text(
          item['title'] ?? 'Untitled item',
          style: TextStyle(
            decoration: isDone ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(item['description'] ?? item['status'] ?? 'Open'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
