import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/core/item_fields.dart';
import 'package:pesalistas/widgets/list_detail/chore_item_card.dart';
import 'package:pesalistas/widgets/list_detail/empty_items_card.dart';

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

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return EmptyItemsCard(
        icon: Icons.cleaning_services,
        title: context.l10n.noChoresYet,
        subtitle: context.l10n.createYourFirstChore,
        onCreate: onCreate,
      );
    }

    return Column(
      children: [
        for (final item in items)
          ChoreItemCard(
            item: item,
            onComplete: () => onComplete(item[AppItemFields.id].toString()),
            onEdit: () => onEdit(item),
            onDelete: () => onDelete(item[AppItemFields.id].toString()),
          ),
      ],
    );
  }
}
