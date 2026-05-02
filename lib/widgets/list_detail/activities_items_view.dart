import 'package:flutter/material.dart';
import 'package:pesalistas/widgets/common/empty_info_card.dart';

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
        icon: Icons.local_activity_outlined,
        title: 'No activities yet',
        subtitle: 'Add something fun to do.',
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
              leading: const CircleAvatar(
                child: Icon(Icons.local_activity_outlined),
              ),
              title: Text(item['title'] ?? 'Untitled activity'),
              subtitle: Text(item['description'] ?? 'Tap to edit'),
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
