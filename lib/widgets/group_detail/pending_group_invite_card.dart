import 'package:flutter/material.dart';

class PendingGroupInviteCard extends StatelessWidget {
  const PendingGroupInviteCard({
    super.key,
    required this.invitation,
    required this.onCancel,
  });

  final Map<String, dynamic> invitation;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.mail_outline)),
        title: Text(invitation['invited_email'] ?? 'Unknown email'),
        subtitle: Text('Role: ${invitation['role'] ?? 'member'}'),
        trailing: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Cancel invitation',
          onPressed: onCancel,
        ),
      ),
    );
  }
}
