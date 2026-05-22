import 'package:flutter/material.dart';
import 'package:pesalistas/core/book_reading_status.dart';
import 'package:pesalistas/core/fields/book_fields.dart';
import 'package:pesalistas/core/fields/item_fields.dart';
import 'package:pesalistas/core/value_parsing.dart';
import 'package:pesalistas/core/fields/vote_summary_fields.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/widgets/common/app_network_image_thumbnail.dart';

class BookItemCard extends StatelessWidget {
  const BookItemCard({
    super.key,
    required this.item,
    required this.fallbackTitle,
    required this.onEdit,
    required this.onVote,
    required this.onViewVotes,
    required this.onDelete,
    required this.onStatusChanged,
  });

  final Map<String, dynamic> item;
  final String fallbackTitle;
  final VoidCallback onEdit;
  final VoidCallback onVote;
  final VoidCallback onViewVotes;
  final VoidCallback onDelete;
  final void Function(String status) onStatusChanged;

  Map<String, dynamic>? get book {
    final value = item[AppItemFields.book];

    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return null;
  }

  String get title {
    return AppValueParsing.textOrNull(book?[AppBookFields.title]) ??
        AppValueParsing.textOrNull(item[AppItemFields.title]) ??
        fallbackTitle;
  }

  String? get description {
    return AppValueParsing.textOrNull(item[AppItemFields.description]);
  }

  String? get authors {
    return AppValueParsing.textOrNull(book?[AppBookFields.authors]);
  }

  String? get coverUrl {
    return AppValueParsing.textOrNull(book?[AppBookFields.coverUrl]);
  }

  int? get firstPublishYear {
    return AppValueParsing.intOrNull(book?[AppBookFields.firstPublishYear]);
  }

  int? get editionCount {
    return AppValueParsing.intOrNull(book?[AppBookFields.editionCount]);
  }

  String? get openLibraryKey {
    return AppValueParsing.textOrNull(item[AppItemFields.bookOpenLibraryKey]);
  }

  int get voteCount {
    return AppValueParsing.intOrNull(item[AppVoteSummaryFields.voteCount]) ?? 0;
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

  String get averageText {
    if (!hasVotes) return '—';
    return averagePoints.toStringAsFixed(1);
  }

  String voteCountText(BuildContext context) {
    if (voteCount == 0) return context.l10n.noVotesYet;
    if (voteCount == 1) return context.l10n.voteCountOne;
    return context.l10n.voteCountMany(voteCount);
  }

  String get readingStatus {
    return AppBookReadingStatus.normalize(item[AppItemFields.status]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ownVote = myPoints;

    final meta = <Widget>[
      if (authors != null)
        _BookMetaPill(icon: Icons.person_outline, text: authors!),
      if (firstPublishYear != null)
        _BookMetaPill(
          icon: Icons.calendar_today_outlined,
          text: firstPublishYear.toString(),
        ),
      if (editionCount != null)
        _BookMetaPill(
          icon: Icons.library_books_outlined,
          text: '$editionCount edition(s)',
        ),
    ];

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
                    imageUrl: coverUrl,
                    width: 62,
                    height: 92,
                    borderRadius: 12,
                    fallbackIcon: Icons.menu_book_outlined,
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
                            _BookScorePill(
                              averageText: averageText,
                              hasVotes: hasVotes,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (meta.isNotEmpty)
                          Wrap(spacing: 8, runSpacing: 8, children: meta),
                        if (description != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                        if (book == null && openLibraryKey != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Book linked, but cached details were not loaded yet.',
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        _BookReadingStatusSelector(
                          currentStatus: readingStatus,
                          onChanged: onStatusChanged,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onVote,
                      icon: Icon(
                        ownVote == null
                            ? Icons.how_to_vote_outlined
                            : Icons.how_to_vote,
                      ),
                      label: Text(
                        ownVote == null
                            ? context.l10n.vote
                            : 'Your vote: $ownVote',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: onViewVotes,
                    icon: const Icon(Icons.bar_chart_outlined),
                    label: Text(voteCountText(context)),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    tooltip: context.l10n.delete,
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

class _BookScorePill extends StatelessWidget {
  const _BookScorePill({required this.averageText, required this.hasVotes});

  final String averageText;
  final bool hasVotes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: hasVotes
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_outline,
            size: 15,
            color: hasVotes
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            averageText,
            style: TextStyle(
              color: hasVotes
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookMetaPill extends StatelessWidget {
  const _BookMetaPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookReadingStatusSelector extends StatelessWidget {
  const _BookReadingStatusSelector({
    required this.currentStatus,
    required this.onChanged,
  });

  final String currentStatus;
  final void Function(String status) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalized = AppBookReadingStatus.normalize(currentStatus);

    return PopupMenuButton<String>(
      onSelected: onChanged,
      itemBuilder: (context) {
        return [
          for (final status in AppBookReadingStatus.values)
            PopupMenuItem(
              value: status,
              child: Row(
                children: [
                  Icon(AppBookReadingStatus.icon(status)),
                  const SizedBox(width: 10),
                  Text(AppBookReadingStatus.label(status)),
                  if (status == normalized) ...[
                    const Spacer(),
                    const Icon(Icons.check),
                  ],
                ],
              ),
            ),
        ];
      },
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                AppBookReadingStatus.icon(normalized),
                size: 16,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 6),
              Text(
                AppBookReadingStatus.label(normalized),
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.expand_more,
                size: 16,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
