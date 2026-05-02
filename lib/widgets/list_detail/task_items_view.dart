import 'package:flutter/material.dart';
import 'package:pesalistas/widgets/common/empty_info_card.dart';
import 'package:pesalistas/widgets/list_detail/item_card.dart';

class TaskItemsView extends StatelessWidget {
  const TaskItemsView({
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

  String buildSubtitle(Map<String, dynamic> item) {
    final desc = item['description'];
    final deadline = item['deadline_at'];
    final priority = item['priority'];

    final parts = <String>[];

    if (desc != null && desc.toString().isNotEmpty) {
      parts.add(desc);
    }

    if (priority != null && priority > 0) {
      parts.add('Priority: $priority');
    }

    if (deadline != null) {
      parts.add('Due: ${deadline.toString().split('T').first}');
    }

    return parts.isEmpty ? 'Open' : parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return EmptyInfoCard(
        icon: Icons.checklist,
        title: 'No tasks yet',
        subtitle: 'Create your first task.',
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
                icon: Icon(
                  item['status'] == 'done'
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                ),
                onPressed: item['status'] == 'done'
                    ? null
                    : () => onComplete(item['id']),
              ),
              title: Text(
                item['title'] ?? 'Untitled task',
                style: TextStyle(
                  decoration: item['status'] == 'done'
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
              subtitle: Text(buildSubtitle(item)),
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
