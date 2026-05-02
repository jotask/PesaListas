import 'package:flutter/material.dart';
import 'package:pesalistas/core/item_fields.dart';
import 'package:pesalistas/widgets/list_detail/base_item_card.dart';
import 'package:pesalistas/widgets/list_detail/empty_items_card.dart';

class SimpleItemsView extends StatelessWidget {
  const SimpleItemsView({
    super.key,
    required this.items,
    required this.loading,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.cardIcon,
    required this.fallbackTitle,
    required this.defaultSubtitle,
    required this.onCreate,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Map<String, dynamic>> items;
  final bool loading;

  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;

  final IconData cardIcon;
  final String fallbackTitle;
  final String defaultSubtitle;

  final VoidCallback onCreate;
  final void Function(Map<String, dynamic> item) onEdit;
  final void Function(String itemId) onDelete;

  String subtitleFor(Map<String, dynamic> item) {
    final description = item[AppItemFields.description]?.toString();

    if (description != null && description.trim().isNotEmpty) {
      return description;
    }

    return defaultSubtitle;
  }

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
          BaseItemCard(
            title: item[AppItemFields.title]?.toString(),
            fallbackTitle: fallbackTitle,
            subtitle: subtitleFor(item),
            icon: cardIcon,
            onTap: () => onEdit(item),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => onDelete(item[AppItemFields.id].toString()),
                tooltip: 'Delete item',
              ),
            ],
          ),
      ],
    );
  }
}
