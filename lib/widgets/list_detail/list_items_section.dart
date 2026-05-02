import 'package:flutter/material.dart';
import 'package:pesalistas/widgets/list_detail/items_view_factory.dart';

class ListItemsSection extends StatelessWidget {
  const ListItemsSection({
    super.key,
    required this.listType,
    required this.items,
    required this.loading,
    required this.onCreate,
    required this.onComplete,
    required this.onReopen,
    required this.onEdit,
    required this.onDelete,
    required this.onVote,
    required this.onViewVotes,
  });

  final String listType;
  final List<Map<String, dynamic>> items;
  final bool loading;

  final VoidCallback onCreate;
  final void Function(String itemId) onComplete;
  final void Function(String itemId) onReopen;
  final void Function(Map<String, dynamic> item) onEdit;
  final void Function(String itemId) onDelete;
  final void Function(Map<String, dynamic> item) onVote;
  final void Function(Map<String, dynamic> item) onViewVotes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Items',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ItemsViewFactory(
          listType: listType,
          items: items,
          loading: loading,
          onCreate: onCreate,
          onComplete: onComplete,
          onReopen: onReopen,
          onEdit: onEdit,
          onDelete: onDelete,
          onVote: onVote,
          onViewVotes: onViewVotes,
        ),
      ],
    );
  }
}
