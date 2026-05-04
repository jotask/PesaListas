import 'package:flutter/material.dart';
import 'package:pesalistas/core/group_fields.dart';
import 'package:pesalistas/core/invitation_fields.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';

class PendingInvitationsSection extends StatelessWidget {
  const PendingInvitationsSection({
    super.key,
    required this.invitations,
    required this.loading,
    required this.processingInvitation,
    required this.onAcceptInvitation,
    required this.onDeclineInvitation,
  });

  final List<Map<String, dynamic>> invitations;
  final bool loading;
  final bool processingInvitation;
  final void Function(String invitationId) onAcceptInvitation;
  final void Function(String invitationId) onDeclineInvitation;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Text(context.l10n.loadingInvitations),
            ],
          ),
        ),
      );
    }

    if (invitations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InvitationsHeader(count: invitations.length),
            const SizedBox(height: 12),
            for (final invitation in invitations)
              _InvitationTile(
                invitation: invitation,
                processingInvitation: processingInvitation,
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
        ? context.l10n.pendingInvitations
        : context.l10n.sectionCount(context.l10n.pendingInvitations, count);

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
        const SizedBox(width: 10),
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
    required this.processingInvitation,
    required this.onAccept,
    required this.onDecline,
  });

  final Map<String, dynamic> invitation;
  final bool processingInvitation;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  Map<String, dynamic>? get group {
    final value = invitation[AppInvitationFields.groups];

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
    final resolvedGroupName = groupName(context);
    final resolvedRole = role(context);

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
              resolvedGroupName.characters.first.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resolvedGroupName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.invitedAsRole(resolvedRole),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: processingInvitation ? null : onDecline,
            child: Text(context.l10n.decline),
          ),
          const SizedBox(width: 4),
          FilledButton(
            onPressed: processingInvitation ? null : onAccept,
            child: Text(context.l10n.accept),
          ),
        ],
      ),
    );
  }
}
