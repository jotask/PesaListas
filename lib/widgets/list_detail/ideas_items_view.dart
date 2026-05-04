import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/app_strings.dart';
import 'package:pesalistas/widgets/list_detail/votable_items_view.dart';

class IdeasItemsView extends StatelessWidget {
  const IdeasItemsView({
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
    return VotableItemsView(
      items: items,
      loading: loading,
      emptyIcon: Icons.lightbulb_outline,
      emptyTitle: S.noIdeasYet,
      emptySubtitle: S.addYourFirstIdea,
      cardIcon: Icons.lightbulb_outline,
      fallbackTitle: S.untitledIdea,
      onCreate: onCreate,
      onEdit: onEdit,
      onDelete: onDelete,
      onVote: onVote,
      onViewVotes: onViewVotes,
    );
  }
}
