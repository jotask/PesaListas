import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/app_strings.dart';

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
  });

  final int initialPoints;
  final String? initialComment;
  final bool canRemove;

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

    return AlertDialog(
      title: Text(widget.canRemove ? S.changeVote : S.vote),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            SizedBox(height: 12),
            TextField(
              controller: commentController,
              decoration: InputDecoration(
                labelText: S.comment,
                hintText: S.optional,
              ),
              minLines: 1,
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        if (widget.canRemove)
          TextButton(onPressed: removeVote, child: Text(S.removeVote)),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(S.cancel),
        ),
        ElevatedButton(onPressed: submit, child: Text(S.save)),
      ],
    );
  }
}
