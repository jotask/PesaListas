import 'package:flutter/material.dart';
import 'package:pesalistas/widgets/common/empty_info_card.dart';

class ChoreItemsView extends StatelessWidget {
  const ChoreItemsView({
    super.key,
    required this.items,
    required this.loading,
    required this.onCreate,
    required this.onComplete,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Map<String, dynamic>> items;
  final bool loading;
  final VoidCallback onCreate;
  final void Function(String itemId) onComplete;
  final void Function(Map<String, dynamic> item) onEdit;
  final void Function(String itemId) onDelete;

  String subtitleFor(Map<String, dynamic> item) {
    final parts = <String>[];

    if (item['description'] != null) {
      parts.add(item['description']);
    }

    if (item['recurrence_type'] != null) {
      parts.add('Repeats: ${item['recurrence_type']}');
    }

    if (item['next_due_at'] != null) {
      parts.add('Next due: ${item['next_due_at'].toString().split('T').first}');
    }

    return parts.isEmpty ? 'Chore' : parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return EmptyInfoCard(
        icon: Icons.cleaning_services,
        title: 'No chores yet',
        subtitle: 'Create your first chore.',
        trailing: const Icon(Icons.add),
        onTap: onCreate,
      );
    }

    return Column(
      children: [
        for (final item in items)
          Card(
            child: ListTile(
              onTap: () => onEdit(item),
              leading: IconButton(
                icon: const Icon(Icons.check_circle_outline),
                onPressed: () => onComplete(item['id']),
              ),
              title: Text(item['title'] ?? 'Untitled chore'),
              subtitle: Text(subtitleFor(item)),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => onDelete(item['id']),
              ),
            ),
          ),
      ],
    );
  }
}
