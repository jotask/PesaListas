import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/core/item_fields.dart';
import 'package:pesalistas/core/value_parsing.dart';
import 'package:pesalistas/core/vote_summary_fields.dart';

class VotableItemCard extends StatelessWidget {
  const VotableItemCard({
    super.key,
    required this.item,
    required this.icon,
    required this.fallbackTitle,
    required this.onEdit,
    required this.onVote,
    required this.onViewVotes,
    required this.onDelete,
  });

  final Map<String, dynamic> item;
  final IconData icon;
  final String fallbackTitle;
  final VoidCallback onEdit;
  final VoidCallback onVote;
  final VoidCallback onViewVotes;
  final VoidCallback onDelete;

  String get title {
    final value = item[AppItemFields.title]?.toString();

    if (value == null || value.trim().isEmpty) {
      return fallbackTitle;
    }

    return value.trim();
  }

  String? get description {
    final value = item[AppItemFields.description]?.toString();

    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return value.trim();
  }

  int get voteCount {
    return AppValueParsing.intOrNull(item[AppVoteSummaryFields.voteCount]) ?? 0;
  }

  int get totalPoints {
    return AppValueParsing.intOrNull(item[AppVoteSummaryFields.totalPoints]) ??
        0;
  }

  int? get myPoints {
    return AppValueParsing.intOrNull(item[AppVoteSummaryFields.myPoints]);
  }

  double get averagePoints {
    final value = item[AppVoteSummaryFields.averagePoints];

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  bool get hasVotes => voteCount > 0;

  String voteCountText(BuildContext context) {
    if (voteCount == 0) return context.l10n.noVotesYet;
    if (voteCount == 1) return context.l10n.voteCountOne;
    return context.l10n.voteCountMany(voteCount);
  }

  String get averageText {
    if (!hasVotes) return '—';
    return averagePoints.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ownVote = myPoints;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ScoreBadge(averageText: averageText, hasVotes: hasVotes),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(icon, size: 20, color: theme.colorScheme.primary),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (description != null) ...[
                      SizedBox(height: 6),
                      Text(
                        description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoChip(
                          icon: Icons.how_to_vote_outlined,
                          label: voteCountText(context),
                        ),
                        if (hasVotes)
                          _InfoChip(
                            icon: Icons.functions,
                            label: context.l10n.totalPointsLabel(totalPoints),
                          ),
                        if (ownVote != null)
                          _InfoChip(
                            icon: Icons.person,
                            label: context.l10n.yourVoteLabel(ownVote),
                            filled: true,
                          ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: onVote,
                          icon: Icon(
                            ownVote == null ? Icons.star_border : Icons.star,
                          ),
                          label: Text(
                            ownVote == null
                                ? context.l10n.vote
                                : context.l10n.changeVote,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: hasVotes ? onViewVotes : null,
                          icon: Icon(Icons.visibility_outlined),
                          label: Text(context.l10n.votes),
                        ),
                        IconButton(
                          onPressed: onEdit,
                          icon: Icon(Icons.edit_outlined),
                          tooltip: context.l10n.editItem,
                        ),
                        IconButton(
                          onPressed: onDelete,
                          icon: Icon(Icons.delete_outline),
                          tooltip: context.l10n.deleteItem,
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

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.averageText, required this.hasVotes});

  final String averageText;
  final bool hasVotes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 58,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: hasVotes
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.star,
            size: 20,
            color: hasVotes
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: 4),
          Text(
            averageText,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: hasVotes
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            context.l10n.averageShort,
            style: TextStyle(
              fontSize: 11,
              color: hasVotes
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: filled
            ? theme.colorScheme.secondaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: filled
                ? theme.colorScheme.onSecondaryContainer
                : theme.colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: filled ? FontWeight.w700 : FontWeight.w500,
              color: filled
                  ? theme.colorScheme.onSecondaryContainer
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
