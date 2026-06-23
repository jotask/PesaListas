import 'package:flutter/material.dart';
import 'package:pesalistas/core/fields/group_fields.dart';
import 'package:pesalistas/core/fields/invitation_fields.dart';

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
      return const _InvitationsLoadingCard();
    }

    if (invitations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFECE7DC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InvitationsHeader(count: invitations.length),
          const SizedBox(height: 14),
          for (var index = 0; index < invitations.length; index++) ...[
            _InvitationTile(
              invitation: invitations[index],
              processingInvitation: processingInvitation,
              onAccept: () {
                onAcceptInvitation(
                  invitations[index][AppInvitationFields.id].toString(),
                );
              },
              onDecline: () {
                onDeclineInvitation(
                  invitations[index][AppInvitationFields.id].toString(),
                );
              },
            ),
            if (index != invitations.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _InvitationsLoadingCard extends StatelessWidget {
  const _InvitationsLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFECE7DC)),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: Color(0xFF19A873),
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Loading invitations...',
            style: TextStyle(
              color: Color(0xFF727A83),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InvitationsHeader extends StatelessWidget {
  const _InvitationsHeader({required this.count});

  final int count;

  String get title {
    if (count == 1) {
      return 'Pending invitation';
    }

    return '$count pending invitations';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFF3478F6).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.mark_email_unread_outlined,
            color: Color(0xFF2563EB),
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF26363B),
                  fontSize: 18,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Someone invited you to a shared space',
                style: TextStyle(
                  color: Color(0xFF727A83),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
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

  String get resolvedGroupName {
    final value = group?[AppGroupFields.name]?.toString();

    if (value == null || value.trim().isEmpty) {
      return 'Shared group';
    }

    return value.trim();
  }

  String get resolvedRole {
    final value = invitation[AppInvitationFields.role]?.toString();

    if (value == null || value.trim().isEmpty) {
      return 'member';
    }

    return value.trim();
  }

  String get initial {
    final text = resolvedGroupName.trim();

    if (text.isEmpty) {
      return 'S';
    }

    return text.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF4),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFECE7DC)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF19A873).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Color(0xFF0F7F67),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
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
                      style: const TextStyle(
                        color: Color(0xFF26363B),
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Invited as $resolvedRole',
                      style: const TextStyle(
                        color: Color(0xFF727A83),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: processingInvitation ? null : onDecline,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF727A83),
                    side: const BorderSide(color: Color(0xFFE1DDD3)),
                    minimumSize: const Size(0, 42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: processingInvitation ? null : onAccept,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF19A873),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(
                      0xFF19A873,
                    ).withValues(alpha: 0.45),
                    minimumSize: const Size(0, 42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  child: const Text('Accept'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
