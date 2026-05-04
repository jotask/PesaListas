import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/app_strings.dart';
import 'package:pesalistas/core/group_fields.dart';
import 'package:pesalistas/core/invitation_fields.dart';

class PendingInviteCard extends StatelessWidget {
  const PendingInviteCard({
    super.key,
    required this.invitation,
    required this.onAccept,
  });

  final Map<String, dynamic> invitation;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    final group =
        invitation[AppInvitationFields.groups] as Map<String, dynamic>?;
    final groupName =
        group?[AppGroupFields.name]?.toString() ?? S.groupInvitation;
    final role = invitation[AppInvitationFields.role]?.toString() ?? 'member';

    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Icon(Icons.mail_outline)),
        title: Text(groupName),
        subtitle: Text('Invited as $role'),
        trailing: ElevatedButton(
          onPressed: onAccept,
          child: Text(S.accept),
        ),
      ),
    );
  }
}
