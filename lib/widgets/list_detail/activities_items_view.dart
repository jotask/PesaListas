import 'package:flutter/material.dart';
import 'package:pesalistas/core/fields/item_fields.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/widgets/list_detail/activity_item_card.dart';
import 'package:pesalistas/widgets/list_detail/empty_items_card.dart';
import 'package:pesalistas/widgets/list_detail/unread_item_highlight.dart';

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
    required this.onViewVotes,
  });

  final List<Map<String, dynamic>> items;
  final bool loading;
  final VoidCallback onCreate;
  final void Function(String itemId) onComplete;
  final void Function(Map<String, dynamic> item) onEdit;
  final void Function(String itemId) onDelete;
  final void Function(Map<String, dynamic> item) onVote;
  final void Function(Map<String, dynamic> item) onViewVotes;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return EmptyItemsCard(
        icon: Icons.local_activity_outlined,
        title: context.l10n.noActivitiesYet,
        subtitle: context.l10n.addSomethingFunToDo,
        onCreate: onCreate,
      );
    }

    return Column(
      children: [
        for (final item in items)
          UnreadItemHighlight(
            item: item,
            child: ActivityItemCard(
              item: item,
              fallbackTitle: context.l10n.untitledActivity,
              onEdit: () => onEdit(item),
              onVote: () => onVote(item),
              onViewVotes: () => onViewVotes(item),
              onDelete: () => onDelete(item[AppItemFields.id].toString()),
            ),
          ),
      ],
    );
  }
}
