import 'package:flutter/material.dart';
import 'package:pesalistas/core/item_fields.dart';
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

  String titleFor(Map<String, dynamic> item) {
    final value = item[AppItemFields.title]?.toString();

    if (value == null || value.trim().isEmpty) {
      return fallbackTitle;
    }

    return value.trim();
  }

  String subtitleFor(Map<String, dynamic> item) {
    final description = item[AppItemFields.description]?.toString();

    if (description != null && description.trim().isNotEmpty) {
      return description.trim();
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
          _SimpleItemCard(
            title: titleFor(item),
            subtitle: subtitleFor(item),
            icon: cardIcon,
            onEdit: () => onEdit(item),
            onDelete: () => onDelete(item[AppItemFields.id].toString()),
          ),
      ],
    );
  }
}

class _SimpleItemCard extends StatelessWidget {
  const _SimpleItemCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onEdit,
    required this.onDelete,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(icon, color: theme.colorScheme.onPrimaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit'),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Delete item',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
