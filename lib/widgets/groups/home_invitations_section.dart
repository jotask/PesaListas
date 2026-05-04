import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/app_strings.dart';
import 'package:pesalistas/widgets/groups/pending_invite_card.dart';

class HomeInvitationsSection extends StatelessWidget {
  const HomeInvitationsSection({
    super.key,
    required this.invitations,
    required this.acceptingInvitation,
    required this.onAcceptInvitation,
  });

  final List<Map<String, dynamic>> invitations;
  final bool acceptingInvitation;
  final void Function(String invitationId) onAcceptInvitation;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InvitationsHeader(count: invitations.length),
        SizedBox(height: 12),
        if (invitations.isEmpty)
          Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.mark_email_read_outlined),
              ),
              title: Text(S.noPendingInvitations),
              subtitle: Text(S.groupInvitesWillAppearHere),
            ),
          )
        else
          for (final invitation in invitations)
            PendingInviteCard(
              invitation: invitation,
              onAccept: acceptingInvitation
                  ? () {}
                  : () => onAcceptInvitation(invitation['id'].toString()),
            ),
      ],
    );
  }
}

class _InvitationsHeader extends StatelessWidget {
  const _InvitationsHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            S.pendingInvitations,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        if (count > 0)
          Container(
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error,
              borderRadius: BorderRadius.circular(999),
            ),
            alignment: Alignment.center,
            child: Text(
              count > 9 ? '9+' : count.toString(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onError,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}
