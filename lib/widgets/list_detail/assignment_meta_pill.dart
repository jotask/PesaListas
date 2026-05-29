import 'package:flutter/material.dart';
import 'package:pesalistas/core/fields/item_assignee_fields.dart';
import 'package:pesalistas/core/item_assignment_scope.dart';
import 'package:pesalistas/core/fields/item_fields.dart';
import 'package:pesalistas/core/fields/member_fields.dart';
import 'package:pesalistas/core/fields/profile_fields.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AssignmentMetaPill extends StatelessWidget {
  const AssignmentMetaPill({super.key, required this.item});

  final Map<String, dynamic> item;

  String get assignmentScope {
    final value = item[AppItemFields.assignmentScope]?.toString();

    if (value == null || value.trim().isEmpty) {
      return AppItemAssignmentScopes.none;
    }

    if (!AppItemAssignmentScopes.isValid(value)) {
      return AppItemAssignmentScopes.none;
    }

    return value;
  }

  List<Map<String, dynamic>> get assignees {
    final value = item[AppItemFields.assignees];

    if (value is! List) {
      return [];
    }

    return value.whereType<Map<String, dynamic>>().toList();
  }

  Map<String, dynamic>? memberFromAssignee(Map<String, dynamic> assignee) {
    final member = assignee[AppMemberFields.groupMembers];

    if (member is Map<String, dynamic>) {
      return member;
    }

    return null;
  }

  Map<String, dynamic>? profileFromAssignee(Map<String, dynamic> assignee) {
    final member = memberFromAssignee(assignee);
    final profile = member?[AppMemberFields.profiles];

    if (profile is Map<String, dynamic>) {
      return profile;
    }

    return null;
  }

  String? avatarUrlFromAssignee(Map<String, dynamic> assignee) {
    final profile = profileFromAssignee(assignee);
    final value = profile?[AppProfileFields.avatarUrl]?.toString();

    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return value.trim();
  }

  String memberNameFromAssignee(Map<String, dynamic> assignee) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final assigneeUserId = assignee[AppItemAssigneeFields.userId]?.toString();

    if (assigneeUserId != null && assigneeUserId == currentUserId) {
      return 'You';
    }

    final profile = profileFromAssignee(assignee);
    final displayName = profile?[AppProfileFields.displayName]?.toString();

    if (displayName != null && displayName.trim().isNotEmpty) {
      return displayName.trim();
    }

    if (assigneeUserId != null && assigneeUserId.length >= 8) {
      return 'Member ${assigneeUserId.substring(0, 8)}';
    }

    return 'Member';
  }

  String initialsForAssignee(Map<String, dynamic> assignee) {
    final name = memberNameFromAssignee(assignee).trim();

    if (name.isEmpty) return '?';

    final parts = name
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .toList();

    if (parts.isEmpty) return '?';

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  String? assignmentText() {
    switch (assignmentScope) {
      case AppItemAssignmentScopes.all:
        return 'Everyone';

      case AppItemAssignmentScopes.specific:
        if (assignees.isEmpty) {
          return null;
        }

        if (assignees.length == 1) {
          return memberNameFromAssignee(assignees.first);
        }

        return '${assignees.length} members';

      case AppItemAssignmentScopes.none:
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = assignmentText();

    if (text == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (assignmentScope == AppItemAssignmentScopes.all)
            _AssignmentGroupAvatar()
          else
            _AssignmentAvatarStack(
              assignees: assignees,
              initialsBuilder: initialsForAssignee,
              avatarUrlBuilder: avatarUrlFromAssignee,
            ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              'Assigned to $text',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignmentGroupAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CircleAvatar(
      radius: 11,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Icon(
        Icons.groups_outlined,
        size: 14,
        color: theme.colorScheme.onPrimaryContainer,
      ),
    );
  }
}

class _AssignmentAvatarStack extends StatelessWidget {
  const _AssignmentAvatarStack({
    required this.assignees,
    required this.initialsBuilder,
    required this.avatarUrlBuilder,
  });

  final List<Map<String, dynamic>> assignees;
  final String Function(Map<String, dynamic> assignee) initialsBuilder;
  final String? Function(Map<String, dynamic> assignee) avatarUrlBuilder;

  @override
  Widget build(BuildContext context) {
    final visibleAssignees = assignees.take(3).toList();

    if (visibleAssignees.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: 22.0 + ((visibleAssignees.length - 1) * 14.0),
      height: 22,
      child: Stack(
        children: [
          for (var index = 0; index < visibleAssignees.length; index++)
            Positioned(
              left: index * 14.0,
              child: _AssignmentAvatar(
                assignee: visibleAssignees[index],
                initials: initialsBuilder(visibleAssignees[index]),
                avatarUrl: avatarUrlBuilder(visibleAssignees[index]),
              ),
            ),
        ],
      ),
    );
  }
}

class _AssignmentAvatar extends StatelessWidget {
  const _AssignmentAvatar({
    required this.assignee,
    required this.initials,
    required this.avatarUrl,
  });

  final Map<String, dynamic> assignee;
  final String initials;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = avatarUrl;

    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: theme.colorScheme.surface, width: 1.5),
      ),
      child: CircleAvatar(
        radius: 10,
        backgroundColor: theme.colorScheme.primaryContainer,
        backgroundImage: imageUrl == null ? null : NetworkImage(imageUrl),
        child: imageUrl == null
            ? Text(
                initials,
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              )
            : null,
      ),
    );
  }
}
