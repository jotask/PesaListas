import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';

class VoteDialogResult {
  const VoteDialogResult({
    required this.points,
    this.comment,
    this.removeVote = false,
  });

  final int points;
  final String? comment;
  final bool removeVote;
}

class VoteDialog extends StatefulWidget {
  const VoteDialog({
    super.key,
    this.initialPoints = 5,
    this.initialComment,
    this.canRemove = false,
    this.title,
    this.subtitle,
    this.scoreLabel,
    this.commentLabel,
    this.commentHint,
    this.removeLabel,
    this.saveLabel,
  });

  final int initialPoints;
  final String? initialComment;
  final bool canRemove;

  final String? title;
  final String? subtitle;
  final String? scoreLabel;
  final String? commentLabel;
  final String? commentHint;
  final String? removeLabel;
  final String? saveLabel;

  @override
  State<VoteDialog> createState() => _VoteDialogState();
}

class _VoteDialogState extends State<VoteDialog> {
  late double points;
  late final TextEditingController commentController;

  @override
  void initState() {
    super.initState();

    points = widget.initialPoints.toDouble();
    commentController = TextEditingController(
      text: widget.initialComment ?? '',
    );
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  void submit() {
    final comment = commentController.text.trim();

    Navigator.of(context).pop(
      VoteDialogResult(
        points: points.round(),
        comment: comment.isEmpty ? null : comment,
      ),
    );
  }

  void removeVote() {
    Navigator.of(
      context,
    ).pop(VoteDialogResult(points: points.round(), removeVote: true));
  }

  @override
  Widget build(BuildContext context) {
    final roundedPoints = points.round();

    final title =
        widget.title ??
        (widget.canRemove ? context.l10n.changeVote : context.l10n.vote);

    final scoreLabel = widget.scoreLabel ?? context.l10n.vote;

    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.subtitle != null) ...[
              Text(
                widget.subtitle!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
            ],
            Text(
              scoreLabel,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$roundedPoints / 10',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: points,
              min: 1,
              max: 10,
              divisions: 9,
              label: roundedPoints.toString(),
              onChanged: (value) {
                setState(() => points = value);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: commentController,
              decoration: InputDecoration(
                labelText: widget.commentLabel ?? context.l10n.comment,
                hintText: widget.commentHint ?? context.l10n.optional,
              ),
              minLines: 1,
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        if (widget.canRemove)
          TextButton(
            onPressed: removeVote,
            child: Text(widget.removeLabel ?? context.l10n.removeVote),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
        ElevatedButton(
          onPressed: submit,
          child: Text(widget.saveLabel ?? context.l10n.save),
        ),
      ],
    );
  }
}
