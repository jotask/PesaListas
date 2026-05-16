import 'package:flutter/material.dart';
import 'package:pesalistas/core/item_text.dart';
import 'package:pesalistas/core/item_vote_summary.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/widgets/common/app_meta_pill.dart';
import 'package:pesalistas/widgets/common/app_score_pill.dart';

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

  String get title {
    return AppItemText.title(item, fallback: fallbackTitle);
  }

  String? get description {
    return AppItemText.description(item);
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
                            AppScorePill(
                              scoreText: averageText,
                              hasScore: hasVotes,
                              label: 'Interest',
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
                  AppMetaPill(
                    icon: Icons.groups_2_outlined,
                    label: voteCountText(context),
                  ),
                  if (hasVotes)
                    AppMetaPill(
                      icon: Icons.functions,
                      label: context.l10n.totalPointsLabel(totalPoints),
                    ),
                  if (ownVote != null)
                    AppMetaPill(
                      icon: Icons.person,
                      label: context.l10n.yourVoteLabel(ownVote),
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
