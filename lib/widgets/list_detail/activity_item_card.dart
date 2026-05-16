import 'package:flutter/material.dart';
import 'package:pesalistas/core/fields/item_fields.dart';
import 'package:pesalistas/core/item_vote_summary.dart';
import 'package:pesalistas/core/value_parsing.dart';
import 'package:pesalistas/core/vote_summary_fields.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';

class ActivityItemCard extends StatelessWidget {
  const ActivityItemCard({
    super.key,
    required this.item,
    required this.fallbackTitle,
    required this.onEdit,
    required this.onVote,
    required this.onViewVotes,
    required this.onDelete,
  });

  final Map<String, dynamic> item;
  final String fallbackTitle;
  final VoidCallback onEdit;
  final VoidCallback onVote;
  final VoidCallback onViewVotes;
  final VoidCallback onDelete;

  String? textOrNull(dynamic value) {
    final text = value?.toString().trim();

    if (text == null || text.isEmpty) {
      return null;
    }

    return text;
  }

  String get title {
    return textOrNull(item[AppItemFields.title]) ?? fallbackTitle;
  }

  String? get description {
    return textOrNull(item[AppItemFields.description]);
  }

  int get voteCount => voteSummary.voteCount;

  int get totalPoints => voteSummary.totalPoints;

  int? get myPoints => voteSummary.myPoints;

  bool get hasVotes => voteSummary.hasVotes;

  String get averageText => voteSummary.averageText;

  String voteCountText(BuildContext context) {
    return voteSummary.voteCountText(context);
  }

  AppItemVoteSummary get voteSummary {
    return AppItemVoteSummary(item);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ownVote = myPoints;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.local_activity_outlined,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  height: 1.12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _ActivityScorePill(
                              averageText: averageText,
                              hasVotes: hasVotes,
                            ),
                          ],
                        ),
                        if (description != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            description!,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ActivityMetaPill(
                    icon: Icons.groups_2_outlined,
                    text: voteCountText(context),
                  ),
                  if (hasVotes)
                    _ActivityMetaPill(
                      icon: Icons.functions,
                      text: context.l10n.totalPointsLabel(totalPoints),
                    ),
                  if (ownVote != null)
                    _ActivityMetaPill(
                      icon: Icons.person,
                      text: context.l10n.yourVoteLabel(ownVote),
                      filled: true,
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: onVote,
                    icon: Icon(
                      ownVote == null
                          ? Icons.local_activity_outlined
                          : Icons.local_activity,
                    ),
                    label: Text(
                      ownVote == null ? 'Show interest' : 'Change interest',
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: hasVotes ? onViewVotes : null,
                    icon: const Icon(Icons.visibility_outlined),
                    label: Text(context.l10n.votes),
                  ),
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: context.l10n.editItem,
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    tooltip: context.l10n.deleteItem,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityScorePill extends StatelessWidget {
  const _ActivityScorePill({required this.averageText, required this.hasVotes});

  final String averageText;
  final bool hasVotes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final backgroundColor = hasVotes
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surfaceContainerHighest;

    final foregroundColor = hasVotes
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 15, color: foregroundColor),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                averageText,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'Interest',
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityMetaPill extends StatelessWidget {
  const _ActivityMetaPill({
    required this.icon,
    required this.text,
    this.filled = false,
  });

  final IconData icon;
  final String text;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final backgroundColor = filled
        ? theme.colorScheme.secondaryContainer
        : theme.colorScheme.surfaceContainerHighest;

    final foregroundColor = filled
        ? theme.colorScheme.onSecondaryContainer
        : theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foregroundColor),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: foregroundColor,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
