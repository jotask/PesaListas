import 'package:flutter/material.dart';
import 'package:pesalistas/core/group_fields.dart';
import 'package:pesalistas/core/invitation_fields.dart';
import 'package:pesalistas/core/member_fields.dart';
import 'package:pesalistas/core/profile_fields.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';

class GroupOverviewCard extends StatelessWidget {
  const GroupOverviewCard({
    super.key,
    required this.group,
    required this.members,
    required this.pendingInvitations,
    required this.onInvite,
    required this.onBack,
    required this.onEdit,
    required this.onCancelInvitation,
  });

  final Map<String, dynamic> group;
  final List<Map<String, dynamic>> members;
  final List<Map<String, dynamic>> pendingInvitations;
  final VoidCallback onInvite;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final void Function(String invitationId) onCancelInvitation;

  String groupName(BuildContext context) {
    final value = group[AppGroupFields.name]?.toString();

    if (value == null || value.trim().isEmpty) {
      return context.l10n.sharedSpace;
    }

    return value.trim();
  }

  String? get groupDescription {
    final value = group[AppGroupFields.description]?.toString();

    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return value.trim();
  }

  String peopleSummary(BuildContext context) {
    final memberCount = members.length;
    final inviteCount = pendingInvitations.length;

    final memberText = context.l10n.sectionCount(
      context.l10n.member,
      memberCount,
    );

    if (inviteCount == 0) {
      return memberText;
    }

    final inviteText = context.l10n.sectionCount(
      context.l10n.pendingInvite,
      inviteCount,
    );

    return '$memberText • $inviteText';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(8, 4, 16, 12),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            border: Border(
              bottom: BorderSide(
                color: theme.dividerColor.withValues(alpha: 0.4),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 40,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back),
                    tooltip: context.l10n.back,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.groups_2_outlined,
                        size: 22,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        groupName(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: context.l10n.editGroup,
                    ),
                    const SizedBox(width: 4),
                    FilledButton.icon(
                      onPressed: onInvite,
                      icon: const Icon(Icons.person_add_alt_1, size: 18),
                      label: Text(context.l10n.invite),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 8),
                child: Text(
                  groupDescription ??
                      context.l10n.sharedSpaceForListsAndPlanning,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _PeoplePreview(
                        members: members,
                        pendingInvitations: pendingInvitations,
                        onCancelInvitation: onCancelInvitation,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        peopleSummary(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PeoplePreview extends StatelessWidget {
  const _PeoplePreview({
    required this.members,
    required this.pendingInvitations,
    required this.onCancelInvitation,
  });

  final List<Map<String, dynamic>> members;
  final List<Map<String, dynamic>> pendingInvitations;
  final void Function(String invitationId) onCancelInvitation;

  static const int maxVisibleMembers = 5;

  void showPendingInvitations(BuildContext context) {
    if (pendingInvitations.isEmpty) return;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              Text(
                context.l10n.pendingInvitations,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              for (final invitation in pendingInvitations)
                _PendingInvitationTile(
                  invitation: invitation,
                  onCancel: () {
                    Navigator.of(context).pop();
                    onCancelInvitation(
                      invitation[AppInvitationFields.id].toString(),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  String pendingTooltip(BuildContext context) {
    final emails = pendingInvitations
        .take(3)
        .map((invite) {
          return invite[AppInvitationFields.invitedEmail]?.toString() ??
              context.l10n.pendingInvite;
        })
        .join('\n');

    if (pendingInvitations.length <= 3) {
      return emails;
    }

    return '$emails\n+${pendingInvitations.length - 3}';
  }

  @override
  Widget build(BuildContext context) {
    final visibleMembers = members.take(maxVisibleMembers).toList();
    final extraMembers = members.length - visibleMembers.length;

    return SizedBox(
      height: 34,
      child: Row(
        children: [
          for (final member in visibleMembers)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Tooltip(
                message: _MemberDisplay.nameFor(context, member),
                child: _TinyAvatar(
                  name: _MemberDisplay.nameFor(context, member),
                  avatarUrl: _MemberDisplay.avatarUrlFor(member),
                ),
              ),
            ),
          if (extraMembers > 0)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _CountAvatar(label: '+$extraMembers'),
            ),
          if (pendingInvitations.isNotEmpty)
            Tooltip(
              message: pendingTooltip(context),
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () => showPendingInvitations(context),
                child: _PendingAvatar(count: pendingInvitations.length),
              ),
            ),
        ],
      ),
    );
  }
}

class _PendingInvitationTile extends StatelessWidget {
  const _PendingInvitationTile({
    required this.invitation,
    required this.onCancel,
  });

  final Map<String, dynamic> invitation;
  final VoidCallback onCancel;

  String email(BuildContext context) {
    final value = invitation[AppInvitationFields.invitedEmail]?.toString();

    if (value == null || value.trim().isEmpty) {
      return context.l10n.unknownEmail;
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
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.mail_outline)),
        title: Text(
          email(context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(context.l10n.invitedAsRole(role(context))),
        trailing: IconButton(
          onPressed: onCancel,
          icon: const Icon(Icons.close),
          tooltip: context.l10n.cancelInvitation,
        ),
      ),
    );
  }
}

class _MemberDisplay {
  const _MemberDisplay._();

  static Map<String, dynamic>? profileFor(Map<String, dynamic> member) {
    final raw = member[AppMemberFields.profiles];

    if (raw is Map<String, dynamic>) {
      return raw;
    }

    return null;
  }

  static String nameFor(BuildContext context, Map<String, dynamic> member) {
    final profile = profileFor(member);

    final displayName = profile?[AppProfileFields.displayName]?.toString();
    if (displayName != null && displayName.trim().isNotEmpty) {
      return displayName.trim();
    }

    final username = profile?[AppProfileFields.username]?.toString();
    if (username != null && username.trim().isNotEmpty) {
      return username.trim();
    }

    return context.l10n.member;
  }

  static String? avatarUrlFor(Map<String, dynamic> member) {
    final profile = profileFor(member);
    final avatarUrl = profile?[AppProfileFields.avatarUrl]?.toString();

    if (avatarUrl == null || avatarUrl.trim().isEmpty) {
      return null;
    }

    return avatarUrl.trim();
  }
}

class _TinyAvatar extends StatelessWidget {
  const _TinyAvatar({required this.name, this.avatarUrl});

  final String name;
  final String? avatarUrl;

  String get initials {
    final parts = name
        .split(RegExp(r'\s+'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return '?';

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl;

    return CircleAvatar(
      radius: 17,
      backgroundImage: url == null ? null : NetworkImage(url),
      child: url == null
          ? Text(
              initials,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            )
          : null,
    );
  }
}

class _CountAvatar extends StatelessWidget {
  const _CountAvatar({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CircleAvatar(
      radius: 17,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _PendingAvatar extends StatelessWidget {
  const _PendingAvatar({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CircleAvatar(
      radius: 17,
      backgroundColor: theme.colorScheme.secondaryContainer,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            Icons.mail_outline,
            size: 17,
            color: theme.colorScheme.onSecondaryContainer,
          ),
          Positioned(
            right: -8,
            top: -8,
            child: Container(
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                borderRadius: BorderRadius.circular(999),
              ),
              alignment: Alignment.center,
              child: Text(
                count > 9 ? '9+' : count.toString(),
                style: TextStyle(
                  color: theme.colorScheme.onError,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
