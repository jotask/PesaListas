import 'package:flutter/material.dart';
import 'package:pesalistas/core/fields/item_fields.dart';
import 'package:pesalistas/core/fields/movie_fields.dart';
import 'package:pesalistas/core/item_vote_summary.dart';
import 'package:pesalistas/core/value_parsing.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/widgets/common/app_meta_pill.dart';
import 'package:pesalistas/widgets/common/app_network_image_thumbnail.dart';
import 'package:pesalistas/widgets/common/app_score_pill.dart';
import 'package:pesalistas/core/item_text.dart';

class MovieItemCard extends StatelessWidget {
  const MovieItemCard({
    super.key,
    required this.item,
    required this.fallbackTitle,
    required this.onEdit,
    required this.onVote,
    required this.onViewVotes,
    required this.onMarkWatched,
    required this.onMarkToWatch,
    required this.onDelete,
  });

  final Map<String, dynamic> item;
  final String fallbackTitle;
  final VoidCallback onEdit;
  final VoidCallback onVote;
  final VoidCallback onViewVotes;
  final VoidCallback onDelete;
  final VoidCallback onMarkWatched;
  final VoidCallback onMarkToWatch;

  Map<String, dynamic>? get movie {
    final value = item[AppItemFields.movie];

    if (value is Map<String, dynamic>) {
      return value;
    }

    return null;
  }

  String get title {
    final movieTitle = AppValueParsing.textOrNull(movie?[AppMovieFields.title]);

    if (movieTitle != null) {
      return movieTitle;
    }

    return AppItemText.title(item, fallback: fallbackTitle);
  }

  String? get description {
    return AppItemText.description(item);
  }

  String? get posterUrl {
    return AppValueParsing.textOrNull(movie?[AppMovieFields.posterUrl]);
  }

  String? get year {
    return AppValueParsing.textOrNull(movie?[AppMovieFields.year]);
  }

  String? get rating {
    return AppValueParsing.textOrNull(movie?[AppMovieFields.imdbRating]);
  }

  String? get runtime {
    return AppValueParsing.textOrNull(movie?[AppMovieFields.runtime]);
  }

  String? get genre {
    return AppValueParsing.textOrNull(movie?[AppMovieFields.genre]);
  }

  String? get plot {
    return AppValueParsing.textOrNull(movie?[AppMovieFields.plot]);
  }

  bool get hasMovieData {
    return movie != null;
  }

  bool get isWatched {
    return item[AppItemFields.status]?.toString() == 'done';
  }

  String get statusText {
    return isWatched ? 'Watched' : 'To watch';
  }

  IconData get statusIcon {
    return isWatched ? Icons.done_all_outlined : Icons.movie_filter_outlined;
  }

  String get scoreLabel {
    return isWatched ? 'Rating' : 'Interest';
  }

  int get voteCount => voteSummary.voteCount;

  int get totalPoints => voteSummary.totalPoints;

  int? get myPoints => voteSummary.myPoints;

  bool get hasVotes => voteSummary.hasVotes;

  String get averageText => voteSummary.averageText;

  String voteCountText(BuildContext context) {
    return voteSummary.voteCountText(context);
  }

  String get voteActionText {
    if (isWatched) {
      return myPoints == null ? 'Rate' : 'Change rating';
    }

    return myPoints == null ? 'Want to watch' : 'Change interest';
  }

  AppItemVoteSummary get voteSummary {
    return AppItemVoteSummary(item);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ownVote = myPoints;
    final bodyText = plot ?? description;

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
                  AppNetworkImageThumbnail(
                    imageUrl: posterUrl,
                    width: 86,
                    height: 126,
                    borderRadius: 14,
                    fallbackIcon: Icons.movie_outlined,
                  ),
                  const SizedBox(width: 14),
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
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            AppScorePill(
                              scoreText: averageText,
                              hasScore: hasVotes,
                              label: scoreLabel,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            AppMetaPill(
                              icon: statusIcon,
                              label: statusText,
                              filled: isWatched,
                            ),
                            if (year != null)
                              AppMetaPill(
                                icon: Icons.calendar_today_outlined,
                                label: year!,
                              ),
                            if (rating != null)
                              AppMetaPill(
                                icon: Icons.star_outline,
                                label: 'IMDb $rating',
                              ),
                            if (runtime != null)
                              AppMetaPill(
                                icon: Icons.schedule_outlined,
                                label: runtime!,
                              ),
                          ],
                        ),
                        if (genre != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            genre!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (bodyText != null) ...[
                const SizedBox(height: 12),
                Text(
                  bodyText,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  AppMetaPill(
                    icon: Icons.how_to_vote_outlined,
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
                  if (!hasMovieData)
                    AppMetaPill(
                      icon: Icons.link_off_outlined,
                      label: 'No movie details',
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: onVote,
                    icon: Icon(
                      ownVote == null ? Icons.star_border : Icons.star,
                    ),
                    label: Text(voteActionText),
                  ),
                  OutlinedButton.icon(
                    onPressed: hasVotes ? onViewVotes : null,
                    icon: const Icon(Icons.visibility_outlined),
                    label: Text(context.l10n.votes),
                  ),
                  OutlinedButton.icon(
                    onPressed: isWatched ? onMarkToWatch : onMarkWatched,
                    icon: Icon(
                      isWatched ? Icons.undo : Icons.done_all_outlined,
                    ),
                    label: Text(isWatched ? 'Mark to watch' : 'Mark watched'),
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
