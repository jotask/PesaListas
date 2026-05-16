import 'package:flutter/material.dart';
import 'package:pesalistas/core/fields/item_fields.dart';
import 'package:pesalistas/core/fields/movie_fields.dart';
import 'package:pesalistas/core/item_vote_summary.dart';
import 'package:pesalistas/core/value_parsing.dart';
import 'package:pesalistas/core/vote_summary_fields.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';

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

  String? textOrNull(dynamic value) {
    final text = value?.toString().trim();

    if (text == null || text.isEmpty) {
      return null;
    }

    return text;
  }

  String get title {
    final movieTitle = textOrNull(movie?[AppMovieFields.title]);

    if (movieTitle != null) {
      return movieTitle;
    }

    final itemTitle = textOrNull(item[AppItemFields.title]);

    return itemTitle ?? fallbackTitle;
  }

  String? get description {
    return textOrNull(item[AppItemFields.description]);
  }

  String? get posterUrl {
    return textOrNull(movie?[AppMovieFields.posterUrl]);
  }

  String? get year {
    return textOrNull(movie?[AppMovieFields.year]);
  }

  String? get rating {
    return textOrNull(movie?[AppMovieFields.imdbRating]);
  }

  String? get runtime {
    return textOrNull(movie?[AppMovieFields.runtime]);
  }

  String? get genre {
    return textOrNull(movie?[AppMovieFields.genre]);
  }

  String? get plot {
    return textOrNull(movie?[AppMovieFields.plot]);
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
                  _MoviePoster(posterUrl: posterUrl),
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
                            _MovieScorePill(
                              averageText: averageText,
                              hasVotes: hasVotes,
                              label: scoreLabel,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _MovieMetaPill(
                              icon: statusIcon,
                              text: statusText,
                              filled: isWatched,
                            ),
                            if (year != null)
                              _MovieMetaPill(
                                icon: Icons.calendar_today_outlined,
                                text: year!,
                              ),
                            if (rating != null)
                              _MovieMetaPill(
                                icon: Icons.star_outline,
                                text: 'IMDb $rating',
                              ),
                            if (runtime != null)
                              _MovieMetaPill(
                                icon: Icons.schedule_outlined,
                                text: runtime!,
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
                  _MovieMetaPill(
                    icon: Icons.how_to_vote_outlined,
                    text: voteCountText(context),
                  ),
                  if (hasVotes)
                    _MovieMetaPill(
                      icon: Icons.functions,
                      text: context.l10n.totalPointsLabel(totalPoints),
                    ),
                  if (ownVote != null)
                    _MovieMetaPill(
                      icon: Icons.person,
                      text: context.l10n.yourVoteLabel(ownVote),
                      filled: true,
                    ),
                  if (!hasMovieData)
                    _MovieMetaPill(
                      icon: Icons.link_off_outlined,
                      text: 'No movie details',
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

class _MoviePoster extends StatelessWidget {
  const _MoviePoster({required this.posterUrl});

  final String? posterUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = posterUrl;

    if (url == null || url.isEmpty) {
      return _MoviePosterFallback(theme: theme);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        url,
        width: 86,
        height: 126,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return _MoviePosterFallback(theme: theme);
        },
      ),
    );
  }
}

class _MoviePosterFallback extends StatelessWidget {
  const _MoviePosterFallback({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 86,
      height: 126,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        Icons.movie_outlined,
        size: 34,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _MovieScorePill extends StatelessWidget {
  const _MovieScorePill({
    required this.averageText,
    required this.hasVotes,
    required this.label,
  });

  final String averageText;
  final bool hasVotes;
  final String label;

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
                label,
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

class _MovieMetaPill extends StatelessWidget {
  const _MovieMetaPill({
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
