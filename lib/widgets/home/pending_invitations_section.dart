import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/core/group_fields.dart';
import 'package:pesalistas/core/invitation_fields.dart';

class PendingInvitationsSection extends StatelessWidget {
  const PendingInvitationsSection({
    super.key,
    required this.invitations,
    required this.loading,
    required this.acceptingInvitation,
    required this.onAcceptInvitation,
    required this.onDeclineInvitation,
  });

  final List<Map<String, dynamic>> invitations;
  final bool loading;
  final bool acceptingInvitation;
  final void Function(String invitationId) onAcceptInvitation;
  final void Function(String invitationId) onDeclineInvitation;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text(context.l10n.loadingInvitations),
            ],
          ),
        ),
      );
    }

    if (invitations.isEmpty) {
      return SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InvitationsHeader(count: invitations.length),
            SizedBox(height: 12),
            for (final invitation in invitations)
              _InvitationTile(
                invitation: invitation,
                acceptingInvitation: acceptingInvitation,
                onAccept: () {
                  onAcceptInvitation(
                    invitation[AppInvitationFields.id].toString(),
                  );
                },
                onDecline: () {
                  onDeclineInvitation(
                    invitation[AppInvitationFields.id].toString(),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _InvitationsHeader extends StatelessWidget {
  const _InvitationsHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final label = count == 1
        ? '1 pending invitation'
        : '$count pending invitations';

    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: theme.colorScheme.secondaryContainer,
          child: Icon(
            Icons.mark_email_unread_outlined,
            size: 19,
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _InvitationTile extends StatelessWidget {
  const _InvitationTile({
    required this.invitation,
    required this.acceptingInvitation,
    required this.onAccept,
    required this.onDecline,
  });

  final Map<String, dynamic> invitation;
  final bool acceptingInvitation;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  Map<String, dynamic>? get group {
    final value = invitation['groups'];

    if (value is Map<String, dynamic>) {
      return value;
    }

    return null;
  }

  String groupName(BuildContext context) {
    final value = group?[AppGroupFields.name]?.toString();

    if (value == null || value.trim().isEmpty) {
      return context.l10n.sharedGroup;
    }

    return value.trim();
  }

  String role(BuildContext context) {
    final value = invitation[AppInvitationFields.role]?.toString();

    if (value == null || value.trim().isEmpty) {
      return context.l10n.member;
    }

    return value.trim();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.55,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            child: Text(
              groupName(context).characters.first.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  groupName(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 2),
                Text(context.l10n.invitedAsRole(role(context)), style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          SizedBox(width: 8),
          TextButton(
            onPressed: acceptingInvitation ? null : onDecline,
            child: Text(context.l10n.decline),
          ),
          SizedBox(width: 4),
          FilledButton(
            onPressed: acceptingInvitation ? null : onAccept,
            child: Text(context.l10n.accept),
          ),
        ],
      ),
    );
  }
}
