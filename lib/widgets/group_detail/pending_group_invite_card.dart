import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/app_strings.dart';

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
        leading: CircleAvatar(child: Icon(Icons.mail_outline)),
        title: Text(invitation['invited_email'] ?? S.unknownEmail),
        subtitle: Text('Role: ${invitation['role'] ?? 'member'}'),
        trailing: IconButton(
          icon: Icon(Icons.close),
          tooltip: S.cancelInvitation,
          onPressed: onCancel,
        ),
      ),
    );
  }
}
