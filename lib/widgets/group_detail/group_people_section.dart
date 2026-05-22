import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/core/fields/invitation_fields.dart';
import 'package:pesalistas/core/fields/member_fields.dart';
import 'package:pesalistas/core/fields/profile_fields.dart';
import 'package:pesalistas/widgets/common/empty_info_card.dart';

class GroupPeopleSection extends StatelessWidget {
  const GroupPeopleSection({
    super.key,
    required this.members,
    required this.pendingInvitations,
    required this.loadingMembers,
    required this.loadingInvitations,
    required this.invitingMember,
    required this.onInvite,
    required this.onCancelInvitation,
  });

  final List<Map<String, dynamic>> members;
  final List<Map<String, dynamic>> pendingInvitations;

  final bool loadingMembers;
  final bool loadingInvitations;
  final bool invitingMember;

  final VoidCallback onInvite;
  final void Function(String invitationId) onCancelInvitation;

  bool get isLoading => loadingMembers || loadingInvitations;

  @override
  Widget build(BuildContext context) {
    final totalPeopleItems = members.length + pendingInvitations.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PeopleHeader(
          memberCount: members.length,
          pendingInviteCount: pendingInvitations.length,
          invitingMember: invitingMember,
          onInvite: onInvite,
        ),
        SizedBox(height: 12),
        if (isLoading)
          SizedBox(
            height: 132,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (totalPeopleItems == 0)
          EmptyInfoCard(
            icon: Icons.people_outline,
            title: context.l10n.noPeopleYet,
            subtitle: context.l10n.inviteSomeoneToShareThisGroup,
            trailing: Icon(Icons.person_add_alt_1),
            onTap: invitingMember ? null : onInvite,
          )
        else
          SizedBox(
            height: 142,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final member in members) _MemberPersonCard(member: member),
                for (final invitation in pendingInvitations)
                  _PendingInvitePersonCard(
                    invitation: invitation,
                    onCancel: () => onCancelInvitation(
                      invitation[AppInvitationFields.id].toString(),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PeopleHeader extends StatelessWidget {
  const _PeopleHeader({
    required this.memberCount,
    required this.pendingInviteCount,
    required this.invitingMember,
    required this.onInvite,
  });

  final int memberCount;
  final int pendingInviteCount;
  final bool invitingMember;
  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) {
    final subtitleParts = <String>[
      memberCount == 1
          ? context.l10n.memberCountOne
          : context.l10n.memberCountMany(memberCount),
    ];

    if (pendingInviteCount > 0) {
      subtitleParts.add(
        pendingInviteCount == 1
            ? context.l10n.pendingInviteCountOne
            : context.l10n.pendingInviteCountMany(pendingInviteCount),
      );
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            context.l10n.people,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Text(
          subtitleParts.join(' • '),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        SizedBox(width: 8),
        _InviteIconButton(
          pendingInviteCount: pendingInviteCount,
          invitingMember: invitingMember,
          onPressed: onInvite,
        ),
      ],
    );
  }
}

class _InviteIconButton extends StatelessWidget {
  const _InviteIconButton({
    required this.pendingInviteCount,
    required this.invitingMember,
    required this.onPressed,
  });

  final int pendingInviteCount;
  final bool invitingMember;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: invitingMember ? null : onPressed,
          icon: Icon(Icons.person_add_alt_1),
          tooltip: context.l10n.inviteMember,
        ),
        if (pendingInviteCount > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.circular(999),
              ),
              alignment: Alignment.center,
              child: Text(
                pendingInviteCount > 9 ? '9+' : pendingInviteCount.toString(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onError,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _MemberPersonCard extends StatelessWidget {
  const _MemberPersonCard({required this.member});

  final Map<String, dynamic> member;

  Map<String, dynamic>? get profile {
    final profileValue = member[AppMemberFields.profiles];

    if (profileValue is Map<String, dynamic>) {
      return profileValue;
    }

    return null;
  }

  String displayName(BuildContext context) {
    final displayName = profile?[AppProfileFields.displayName]?.toString();
    final username = profile?[AppProfileFields.username]?.toString();

    if (displayName != null && displayName.trim().isNotEmpty) {
      return displayName;
    }

    if (username != null && username.trim().isNotEmpty) {
      return username;
    }

    return context.l10n.unknownUser;
  }

  String? get avatarUrl {
    final value = profile?[AppProfileFields.avatarUrl]?.toString();

    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return value.trim();
  }

  String get role {
    return member[AppMemberFields.role]?.toString() ?? 'member';
  }

  String initials(BuildContext context) {
    final name = displayName(context).trim();

    if (name.isEmpty || name == context.l10n.unknownUser) {
      return '?';
    }

    final words = name.split(RegExp(r'\s+'));

    if (words.length == 1) {
      return words.first.substring(0, 1).toUpperCase();
    }

    return '${words.first.substring(0, 1)}${words.last.substring(0, 1)}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      child: Card(
        margin: const EdgeInsets.only(right: 12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ProfileAvatar(
                  avatarUrl: avatarUrl,
                  fallbackText: initials(context),
                ),
                SizedBox(height: 10),
                Text(
                  displayName(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  role,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.avatarUrl, required this.fallbackText});

  final String? avatarUrl;
  final String fallbackText;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl;

    if (url == null) {
      return CircleAvatar(
        radius: 28,
        child: Text(
          fallbackText,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }

    return ClipOval(
      child: SizedBox(
        width: 56,
        height: 56,
        child: Image.network(
          url,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return CircleAvatar(
              radius: 28,
              child: Text(
                fallbackText,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;

            return CircleAvatar(
              radius: 28,
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PendingInvitePersonCard extends StatelessWidget {
  const _PendingInvitePersonCard({
    required this.invitation,
    required this.onCancel,
  });

  final Map<String, dynamic> invitation;
  final VoidCallback onCancel;

  String email(BuildContext context) {
    return invitation[AppInvitationFields.invitedEmail]?.toString() ??
        invitation[AppInvitationFields.email]?.toString() ??
        context.l10n.unknownEmail;
  }

  String get role {
    return invitation[AppInvitationFields.role]?.toString() ?? 'member';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 156,
      child: Card(
        margin: const EdgeInsets.only(right: 12),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.secondaryContainer,
                    child: Icon(
                      Icons.mail_outline,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    email(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text(
                    context.l10n.pendingRole(role),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Positioned(
              right: 2,
              top: 2,
              child: IconButton(
                icon: Icon(Icons.close, size: 18),
                tooltip: context.l10n.cancelInvitation,
                onPressed: onCancel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
