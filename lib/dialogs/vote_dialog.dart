import 'package:flutter/material.dart';

class VoteDialogResult {
  const VoteDialogResult({required this.points, this.comment});

  final int points;
  final String? comment;
}

class VoteDialog extends StatefulWidget {
  const VoteDialog({super.key, this.initialPoints = 5, this.initialComment});

  final int initialPoints;
  final String? initialComment;

  @override
  State<VoteDialog> createState() => _VoteDialogState();
}

class _VoteDialogState extends State<VoteDialog> {
  late int points;
  late final TextEditingController commentController;

  @override
  void initState() {
    super.initState();
    points = widget.initialPoints;
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
        points: points,
        comment: comment.isEmpty ? null : comment,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Your vote'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$points / 10',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          Slider(
            min: 0,
            max: 10,
            divisions: 10,
            value: points.toDouble(),
            label: points.toString(),
            onChanged: (value) {
              setState(() => points = value.round());
            },
          ),
          TextField(
            controller: commentController,
            autofocus: false,
            decoration: const InputDecoration(
              labelText: 'Comment',
              hintText: 'Optional',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: submit, child: const Text('Save vote')),
      ],
    );
  }
}
