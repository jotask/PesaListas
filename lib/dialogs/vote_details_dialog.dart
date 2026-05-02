import 'package:flutter/material.dart';
import 'package:pesalistas/core/value_parsing.dart';
import 'package:pesalistas/core/vote_fields.dart';

class VoteDetailsDialog extends StatelessWidget {
  const VoteDetailsDialog({
    super.key,
    required this.votes,
    required this.currentUserId,
  });

  final List<Map<String, dynamic>> votes;
  final String currentUserId;

  int get voteCount => votes.length;

  int get totalPoints {
    var total = 0;

    for (final vote in votes) {
      total += AppValueParsing.intOrNull(vote[AppVoteFields.points]) ?? 0;
    }

    return total;
  }

  double get averagePoints {
    if (voteCount == 0) return 0;

    return totalPoints / voteCount;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Votes'),
      content: SizedBox(
        width: double.maxFinite,
        child: votes.isEmpty
            ? const Text('No votes yet.')
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _VoteSummaryHeader(
                      voteCount: voteCount,
                      totalPoints: totalPoints,
                      averagePoints: averagePoints,
                    ),
                    const SizedBox(height: 12),
                    for (final vote in votes)
                      _VoteRow(vote: vote, currentUserId: currentUserId),
                  ],
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _VoteSummaryHeader extends StatelessWidget {
  const _VoteSummaryHeader({
    required this.voteCount,
    required this.totalPoints,
    required this.averagePoints,
  });

  final int voteCount;
  final int totalPoints;
  final double averagePoints;

  @override
  Widget build(BuildContext context) {
    final voteLabel = voteCount == 1 ? 'vote' : 'votes';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: _SummaryValue(
                label: 'Average',
                value: averagePoints.toStringAsFixed(1),
              ),
            ),
            Expanded(
              child: _SummaryValue(
                label: 'Votes',
                value: '$voteCount $voteLabel',
              ),
            ),
            Expanded(
              child: _SummaryValue(
                label: 'Total',
                value: totalPoints.toString(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _VoteRow extends StatelessWidget {
  const _VoteRow({required this.vote, required this.currentUserId});

  final Map<String, dynamic> vote;
  final String currentUserId;

  bool get isMine {
    return vote[AppVoteFields.userId]?.toString() == currentUserId;
  }

  int get points {
    return AppValueParsing.intOrNull(vote[AppVoteFields.points]) ?? 0;
  }

  String? get comment {
    final value = vote[AppVoteFields.comment]?.toString();

    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return value.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            points.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(isMine ? 'You' : 'Member'),
        subtitle: Text(comment ?? 'No comment'),
      ),
    );
  }
}
