import 'package:flutter/material.dart';
import 'package:pesalistas/core/item_fields.dart';
import 'package:pesalistas/core/value_parsing.dart';
import 'package:pesalistas/core/vote_summary_fields.dart';
import 'package:pesalistas/widgets/list_detail/base_item_card.dart';

class VotableItemCard extends StatelessWidget {
  const VotableItemCard({
    super.key,
    required this.item,
    required this.icon,
    required this.fallbackTitle,
    required this.onEdit,
    required this.onVote,
    required this.onDelete,
  });

  final Map<String, dynamic> item;
  final IconData icon;
  final String fallbackTitle;
  final VoidCallback onEdit;
  final VoidCallback onVote;
  final VoidCallback onDelete;

  String buildSubtitle() {
    final description = item[AppItemFields.description]?.toString();
    final voteText = buildVoteText();

    final parts = <String>[];

    if (description != null && description.trim().isNotEmpty) {
      parts.add(description.trim());
    }

    parts.add(voteText);

    return parts.join(' • ');
  }

  String buildVoteText() {
    final voteCount =
        AppValueParsing.intOrNull(item[AppVoteSummaryFields.voteCount]) ?? 0;

    final totalPoints =
        AppValueParsing.intOrNull(item[AppVoteSummaryFields.totalPoints]) ?? 0;

    final myPoints = AppValueParsing.intOrNull(
      item[AppVoteSummaryFields.myPoints],
    );

    final averageValue = item[AppVoteSummaryFields.averagePoints];
    final average = averageValue is num
        ? averageValue.toDouble()
        : double.tryParse(averageValue?.toString() ?? '') ?? 0.0;

    if (voteCount == 0) {
      return 'No votes yet';
    }

    final voteLabel = voteCount == 1 ? 'vote' : 'votes';

    final parts = <String>[
      'Avg ${average.toStringAsFixed(1)}',
      '$voteCount $voteLabel',
      'Total $totalPoints',
    ];

    if (myPoints != null) {
      parts.add('Your vote $myPoints');
    }

    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final myPoints = AppValueParsing.intOrNull(
      item[AppVoteSummaryFields.myPoints],
    );

    return BaseItemCard(
      title: item[AppItemFields.title]?.toString(),
      fallbackTitle: fallbackTitle,
      subtitle: buildSubtitle(),
      icon: icon,
      onTap: onEdit,
      actions: [
        IconButton(
          icon: Icon(myPoints == null ? Icons.star_border : Icons.star),
          onPressed: onVote,
          tooltip: myPoints == null ? 'Vote' : 'Edit your vote',
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
          tooltip: 'Delete item',
        ),
      ],
    );
  }
}
